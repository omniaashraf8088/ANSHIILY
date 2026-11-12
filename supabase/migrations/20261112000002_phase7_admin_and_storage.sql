-- ==============================================================================
-- ANSHIILY (أنشئلي) - Phase 7 Master Database Migration (Hardened & Audited)
-- Storage Buckets, Admin Users (RBAC), System Audit Logs & Function Security
-- Project: wwfhoogtnwyavyvuabbw
-- ==============================================================================

-- 1. Security Hardening for SECURITY DEFINER Functions
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, username, credits, is_premium)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'full_name', 'مستخدم أنشئلي'),
        new.raw_user_meta_data->>'username',
        10,
        false
    )
    ON CONFLICT (id) DO UPDATE
    SET
        full_name = EXCLUDED.full_name,
        username = COALESCE(EXCLUDED.username, public.profiles.username);
    RETURN new;
END;
$$;

-- 2. Create Canonical Storage Buckets (6 Buckets)
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('designs', 'designs', true),
    ('avatars', 'avatars', true),
    ('templates', 'templates', true),
    ('project-previews', 'project-previews', true),
    ('user-uploads', 'user-uploads', false),
    ('exported-designs', 'exported-designs', false)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

-- 3. Storage RLS Policies (Clean, Idempotent, No Silent Error Suppression)
-- A. Public Buckets Read Policies
DROP POLICY IF EXISTS "Public can view designs" ON storage.objects;
CREATE POLICY "Public can view designs" ON storage.objects
    FOR SELECT USING (bucket_id = 'designs');

DROP POLICY IF EXISTS "Public can view avatars" ON storage.objects;
CREATE POLICY "Public can view avatars" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Public can view templates" ON storage.objects;
CREATE POLICY "Public can view templates" ON storage.objects
    FOR SELECT USING (bucket_id = 'templates');

DROP POLICY IF EXISTS "Public can view project previews" ON storage.objects;
CREATE POLICY "Public can view project previews" ON storage.objects
    FOR SELECT USING (bucket_id = 'project-previews');

-- B. Authenticated User Upload Policies (Folder-Isolated)
DROP POLICY IF EXISTS "Users can upload their own designs" ON storage.objects;
CREATE POLICY "Users can upload their own designs" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'designs' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users can update their own designs" ON storage.objects;
CREATE POLICY "Users can update their own designs" ON storage.objects
    FOR UPDATE TO authenticated
    USING (bucket_id = 'designs' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users can delete their own designs" ON storage.objects;
CREATE POLICY "Users can delete their own designs" ON storage.objects
    FOR DELETE TO authenticated
    USING (bucket_id = 'designs' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
CREATE POLICY "Users can upload their own avatar" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
CREATE POLICY "Users can update their own avatar" ON storage.objects
    FOR UPDATE TO authenticated
    USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

-- C. Private Buckets Policies (User-Isolated)
DROP POLICY IF EXISTS "Users can manage user-uploads" ON storage.objects;
CREATE POLICY "Users can manage user-uploads" ON storage.objects
    FOR ALL TO authenticated
    USING (bucket_id = 'user-uploads' AND (storage.foldername(name))[1] = auth.uid()::text)
    WITH CHECK (bucket_id = 'user-uploads' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users can manage exported designs" ON storage.objects;
CREATE POLICY "Users can manage exported designs" ON storage.objects
    FOR ALL TO authenticated
    USING (bucket_id = 'exported-designs' AND (storage.foldername(name))[1] = auth.uid()::text)
    WITH CHECK (bucket_id = 'exported-designs' AND (storage.foldername(name))[1] = auth.uid()::text);

-- 4. Admin Users Table & RBAC
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL DEFAULT 'ADMIN' CHECK (role IN ('SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER', 'SUPPORT', 'ANALYST')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Helper function to check admin role
CREATE OR REPLACE FUNCTION public.check_is_admin(user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.admin_users 
        WHERE id = user_id AND is_active = true
    );
$$;

CREATE OR REPLACE FUNCTION public.check_is_super_admin(user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.admin_users 
        WHERE id = user_id AND role = 'SUPER_ADMIN' AND is_active = true
    );
$$;

-- RLS Policies for admin_users
DROP POLICY IF EXISTS "Admin users can view admin list" ON public.admin_users;
CREATE POLICY "Admin users can view admin list" ON public.admin_users
    FOR SELECT TO authenticated
    USING (public.check_is_admin(auth.uid()));

DROP POLICY IF EXISTS "Only Super Admins can insert admin users" ON public.admin_users;
CREATE POLICY "Only Super Admins can insert admin users" ON public.admin_users
    FOR INSERT TO authenticated
    WITH CHECK (public.check_is_super_admin(auth.uid()));

DROP POLICY IF EXISTS "Only Super Admins can update admin users" ON public.admin_users;
CREATE POLICY "Only Super Admins can update admin users" ON public.admin_users
    FOR UPDATE TO authenticated
    USING (public.check_is_super_admin(auth.uid()))
    WITH CHECK (public.check_is_super_admin(auth.uid()));

DROP POLICY IF EXISTS "Only Super Admins can delete admin users" ON public.admin_users;
CREATE POLICY "Only Super Admins can delete admin users" ON public.admin_users
    FOR DELETE TO authenticated
    USING (public.check_is_super_admin(auth.uid()));

-- 5. System Audit Logs Table (Immutable Audit Trail)
CREATE TABLE IF NOT EXISTS public.system_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    actor_email TEXT NOT NULL,
    action TEXT NOT NULL,
    target_type TEXT,
    target_id TEXT,
    details JSONB DEFAULT '{}'::jsonb,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.system_audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view audit logs" ON public.system_audit_logs;
CREATE POLICY "Admins can view audit logs" ON public.system_audit_logs
    FOR SELECT TO authenticated
    USING (public.check_is_admin(auth.uid()));

DROP POLICY IF EXISTS "Authenticated users can write audit logs" ON public.system_audit_logs;
CREATE POLICY "Authenticated users can write audit logs" ON public.system_audit_logs
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = actor_id);

-- 6. Categories & Templates Admin Management Policies
DROP POLICY IF EXISTS "Admins can insert categories" ON public.design_categories;
CREATE POLICY "Admins can insert categories" ON public.design_categories
    FOR INSERT TO authenticated
    WITH CHECK (public.check_is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins can update categories" ON public.design_categories;
CREATE POLICY "Admins can update categories" ON public.design_categories
    FOR UPDATE TO authenticated
    USING (public.check_is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins can delete categories" ON public.design_categories;
CREATE POLICY "Admins can delete categories" ON public.design_categories
    FOR DELETE TO authenticated
    USING (public.check_is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins can insert templates" ON public.design_templates;
CREATE POLICY "Admins can insert templates" ON public.design_templates
    FOR INSERT TO authenticated
    WITH CHECK (public.check_is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins can update templates" ON public.design_templates;
CREATE POLICY "Admins can update templates" ON public.design_templates
    FOR UPDATE TO authenticated
    USING (public.check_is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins can delete templates" ON public.design_templates;
CREATE POLICY "Admins can delete templates" ON public.design_templates
    FOR DELETE TO authenticated
    USING (public.check_is_admin(auth.uid()));

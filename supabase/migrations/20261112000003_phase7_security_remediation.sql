-- ==============================================================================
-- ANSHIILY (أنشئلي) - Phase 7 Comprehensive Security Remediation Migration
-- Remediates:
-- 1. SUPER_ADMIN Bootstrap Function Privilege Escalation Vulnerability
-- 2. Granular Role-Based Access Control (RBAC) RLS Policies
-- 3. Storage Privacy for User Designs Bucket
-- 4. System Audit Log Integrity & Anti-Forgery Protection
-- 5. Migration Idempotency & Safe Storage Bucket Management
-- ==============================================================================

-- ==============================================================================
-- 1. STORAGE BUCKET PRIVACY & MIGRATION SAFETY (Findings 3 & 5)
-- ==============================================================================
-- Create canonical buckets safely without overwriting visibility on conflict
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('designs', 'designs', false),
    ('avatars', 'avatars', true),
    ('templates', 'templates', true),
    ('project-previews', 'project-previews', true),
    ('user-uploads', 'user-uploads', false),
    ('exported-designs', 'exported-designs', false)
ON CONFLICT (id) DO NOTHING;

-- Enforce explicit privacy rules on existing buckets:
-- User designs MUST remain strictly private
UPDATE storage.buckets SET public = false WHERE id IN ('designs', 'user-uploads', 'exported-designs');
UPDATE storage.buckets SET public = true WHERE id IN ('templates', 'project-previews', 'avatars');

-- Revoke public view policy on designs
DROP POLICY IF EXISTS "Public can view designs" ON storage.objects;

-- User-isolated SELECT policy on designs (private user designs)
DROP POLICY IF EXISTS "Users can view their own designs" ON storage.objects;
CREATE POLICY "Users can view their own designs" ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'designs' 
        AND (
            (storage.foldername(name))[1] = auth.uid()::text
            OR EXISTS (
                SELECT 1 FROM public.admin_users 
                WHERE id = auth.uid() AND is_active = true
            )
        )
    );

-- User-isolated INSERT, UPDATE, DELETE policies on designs
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


-- ==============================================================================
-- 2. RBAC HELPER FUNCTIONS (Finding 2)
-- ==============================================================================
-- Ensure admin_users table exists
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL DEFAULT 'ADMIN' CHECK (role IN ('SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER', 'SUPPORT', 'ANALYST')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Helper 1: General Active Admin Check
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

-- Helper 2: Strict Super Admin Check
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

-- Helper 3: Active Admin Role Query
CREATE OR REPLACE FUNCTION public.get_admin_role(user_id UUID)
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT role FROM public.admin_users 
    WHERE id = user_id AND is_active = true;
$$;

-- Helper 4: Role Multi-Match Helper
CREATE OR REPLACE FUNCTION public.has_any_admin_role(user_id UUID, allowed_roles TEXT[])
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.admin_users 
        WHERE id = user_id 
          AND is_active = true 
          AND role = ANY(allowed_roles)
    );
$$;

-- Helper 5: Content Management Privilege (SUPER_ADMIN, ADMIN, CONTENT_MANAGER)
CREATE OR REPLACE FUNCTION public.can_manage_content(user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT public.has_any_admin_role(user_id, ARRAY['SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER']);
$$;

-- Helper 6: Support Management Privilege (SUPER_ADMIN, ADMIN, SUPPORT)
CREATE OR REPLACE FUNCTION public.can_manage_support(user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT public.has_any_admin_role(user_id, ARRAY['SUPER_ADMIN', 'ADMIN', 'SUPPORT']);
$$;


-- ==============================================================================
-- 3. GRANULAR RLS POLICIES FOR CONTENT & ROLES (Finding 2)
-- ==============================================================================

-- A. design_categories Policies:
-- Only SUPER_ADMIN, ADMIN, and CONTENT_MANAGER can mutate categories.
-- ANALYST and SUPPORT have read-only access.
DROP POLICY IF EXISTS "Admins can insert categories" ON public.design_categories;
CREATE POLICY "Authorized roles can insert categories" ON public.design_categories
    FOR INSERT TO authenticated
    WITH CHECK (public.can_manage_content(auth.uid()));

DROP POLICY IF EXISTS "Admins can update categories" ON public.design_categories;
CREATE POLICY "Authorized roles can update categories" ON public.design_categories
    FOR UPDATE TO authenticated
    USING (public.can_manage_content(auth.uid()))
    WITH CHECK (public.can_manage_content(auth.uid()));

DROP POLICY IF EXISTS "Admins can delete categories" ON public.design_categories;
CREATE POLICY "Authorized roles can delete categories" ON public.design_categories
    FOR DELETE TO authenticated
    USING (public.can_manage_content(auth.uid()));

-- B. design_templates Policies:
-- Only SUPER_ADMIN, ADMIN, and CONTENT_MANAGER can mutate templates.
-- ANALYST and SUPPORT have read-only access.
DROP POLICY IF EXISTS "Admins can insert templates" ON public.design_templates;
CREATE POLICY "Authorized roles can insert templates" ON public.design_templates
    FOR INSERT TO authenticated
    WITH CHECK (public.can_manage_content(auth.uid()));

DROP POLICY IF EXISTS "Admins can update templates" ON public.design_templates;
CREATE POLICY "Authorized roles can update templates" ON public.design_templates
    FOR UPDATE TO authenticated
    USING (public.can_manage_content(auth.uid()))
    WITH CHECK (public.can_manage_content(auth.uid()));

DROP POLICY IF EXISTS "Admins can delete templates" ON public.design_templates;
CREATE POLICY "Authorized roles can delete templates" ON public.design_templates
    FOR DELETE TO authenticated
    USING (public.can_manage_content(auth.uid()));

-- C. admin_users Policies:
-- Any active admin can read the admin team directory.
-- ONLY SUPER_ADMIN can insert, update, or delete administrator records.
DROP POLICY IF EXISTS "Admin users can view admin list" ON public.admin_users;
CREATE POLICY "Active admins can view admin list" ON public.admin_users
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


-- ==============================================================================
-- 4. SYSTEM AUDIT LOG INTEGRITY & ANTI-FORGERY (Finding 4)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.system_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE SET NULL,
    actor_email TEXT NOT NULL,
    action TEXT NOT NULL,
    target_type TEXT,
    target_id TEXT,
    details JSONB DEFAULT '{}'::jsonb,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.system_audit_logs ENABLE ROW LEVEL SECURITY;

-- 1. Read: Any active admin can view audit logs
DROP POLICY IF EXISTS "Admins can view audit logs" ON public.system_audit_logs;
CREATE POLICY "Admins can view audit logs" ON public.system_audit_logs
    FOR SELECT TO authenticated
    USING (public.check_is_admin(auth.uid()));

-- 2. Drop the overly permissive write policy
DROP POLICY IF EXISTS "Authenticated users can write audit logs" ON public.system_audit_logs;

-- 3. Strict Insert: Only verified active admins can insert audit records for their own identity
DROP POLICY IF EXISTS "Only verified admins can insert audit logs" ON public.system_audit_logs;
CREATE POLICY "Only verified admins can insert audit logs" ON public.system_audit_logs
    FOR INSERT TO authenticated
    WITH CHECK (
        public.check_is_admin(auth.uid()) 
        AND (actor_id IS NULL OR actor_id = auth.uid())
    );

-- 4. Audit Log Immutability: Prohibit all UPDATE and DELETE operations
DROP POLICY IF EXISTS "No one can update audit logs" ON public.system_audit_logs;
DROP POLICY IF EXISTS "No one can delete audit logs" ON public.system_audit_logs;

-- 5. Trusted Server-Side Audit Procedure (SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.log_system_audit_event(
    p_action TEXT,
    p_target_type TEXT DEFAULT NULL,
    p_target_id TEXT DEFAULT NULL,
    p_details JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_actor_id UUID := auth.uid();
    v_actor_email TEXT;
    v_log_id UUID;
BEGIN
    IF v_actor_id IS NOT NULL THEN
        SELECT email INTO v_actor_email FROM auth.users WHERE id = v_actor_id;
        IF NOT public.check_is_admin(v_actor_id) THEN
            RAISE EXCEPTION 'Forbidden: Ordinary users cannot write system audit logs.';
        END IF;
    ELSE
        IF current_user IN ('postgres', 'service_role') THEN
            v_actor_email := 'system@internal';
        ELSE
            RAISE EXCEPTION 'Unauthorized audit logging attempt.';
        END IF;
    END IF;

    INSERT INTO public.system_audit_logs (
        actor_id,
        actor_email,
        action,
        target_type,
        target_id,
        details
    ) VALUES (
        v_actor_id,
        COALESCE(v_actor_email, 'unknown'),
        p_action,
        p_target_type,
        p_target_id,
        p_details
    ) RETURNING id INTO v_log_id;

    RETURN v_log_id;
END;
$$;


-- ==============================================================================
-- 5. SUPER_ADMIN BOOTSTRAP FUNCTION HARDENING (Finding 1)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.bootstrap_super_admin(admin_email TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    target_user_id UUID;
    calling_role TEXT;
    result_message TEXT;
BEGIN
    -- Strict caller check
    calling_role := current_user;
    IF calling_role NOT IN ('postgres', 'service_role', 'supabase_admin') THEN
        RAISE EXCEPTION 'CRITICAL SECURITY VIOLATION: bootstrap_super_admin may only be executed directly by database administrator or service_role. Calling role: %', calling_role;
    END IF;

    -- Look up user in auth.users
    SELECT id INTO target_user_id 
    FROM auth.users 
    WHERE email = LOWER(TRIM(admin_email));

    IF target_user_id IS NULL THEN
        RAISE EXCEPTION 'User with email % does not exist in auth.users. Please register the account first.', admin_email;
    END IF;

    -- Upsert SUPER_ADMIN
    INSERT INTO public.admin_users (id, email, role, is_active)
    VALUES (target_user_id, LOWER(TRIM(admin_email)), 'SUPER_ADMIN', true)
    ON CONFLICT (email) DO UPDATE
    SET 
        role = 'SUPER_ADMIN',
        is_active = true,
        updated_at = timezone('utc'::text, now());

    -- Grant premium credits to profile
    UPDATE public.profiles
    SET is_premium = true, credits = 9999
    WHERE id = target_user_id;

    -- Record event in audit logs
    INSERT INTO public.system_audit_logs (actor_id, actor_email, action, target_type, target_id, details)
    VALUES (
        target_user_id,
        LOWER(TRIM(admin_email)),
        'BOOTSTRAP_SUPER_ADMIN',
        'admin_users',
        target_user_id::text,
        jsonb_build_object(
            'role', 'SUPER_ADMIN',
            'assigned_by', calling_role,
            'assigned_at', timezone('utc'::text, now())
        )
    );

    result_message := format('SUPER_ADMIN successfully assigned to %s (UUID: %s)', admin_email, target_user_id);
    RETURN result_message;
END;
$$;

-- Revoke execute from public/anon/authenticated
REVOKE ALL ON FUNCTION public.bootstrap_super_admin(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.bootstrap_super_admin(TEXT) FROM anon;
REVOKE ALL ON FUNCTION public.bootstrap_super_admin(TEXT) FROM authenticated;

-- Grant execute exclusively to trusted admin roles
GRANT EXECUTE ON FUNCTION public.bootstrap_super_admin(TEXT) TO postgres;
GRANT EXECUTE ON FUNCTION public.bootstrap_super_admin(TEXT) TO service_role;

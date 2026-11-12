-- ==============================================================================
-- ANSHIILY (أنشئلي) - Phase 7 Database Migration
-- Storage Buckets, Admin Users & System Audit Logs
-- Project: wwfhoogtnwyavyvuabbw
-- ==============================================================================

-- 1. Create All 5 Storage Buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('avatars', 'avatars', true),
    ('user-uploads', 'user-uploads', false),
    ('project-previews', 'project-previews', true),
    ('exported-designs', 'exported-designs', false),
    ('templates', 'templates', true)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

-- 2. Storage RLS Policies
DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can view avatars" ON storage.objects;
    CREATE POLICY "Public can view avatars" ON storage.objects
        FOR SELECT USING (bucket_id = 'avatars');

    DROP POLICY IF EXISTS "Users can upload their avatar" ON storage.objects;
    CREATE POLICY "Users can upload their avatar" ON storage.objects
        FOR INSERT TO authenticated
        WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

    DROP POLICY IF EXISTS "Public can view project previews" ON storage.objects;
    CREATE POLICY "Public can view project previews" ON storage.objects
        FOR SELECT USING (bucket_id = 'project-previews');

    DROP POLICY IF EXISTS "Public can view templates" ON storage.objects;
    CREATE POLICY "Public can view templates" ON storage.objects
        FOR SELECT USING (bucket_id = 'templates');

    DROP POLICY IF EXISTS "Users can manage user-uploads" ON storage.objects;
    CREATE POLICY "Users can manage user-uploads" ON storage.objects
        FOR ALL TO authenticated
        USING (bucket_id = 'user-uploads' AND (storage.foldername(name))[1] = auth.uid()::text);

    DROP POLICY IF EXISTS "Users can view exported designs" ON storage.objects;
    CREATE POLICY "Users can view exported designs" ON storage.objects
        FOR ALL TO authenticated
        USING (bucket_id = 'exported-designs' AND (storage.foldername(name))[1] = auth.uid()::text);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 3. Admin Users Table (RBAC)
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL DEFAULT 'ADMIN', -- 'SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER', 'SUPPORT', 'ANALYST'
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Admins can view admin users" ON public.admin_users;
    CREATE POLICY "Admins can view admin users" ON public.admin_users
        FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 4. System Audit Logs Table
CREATE TABLE IF NOT EXISTS public.system_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID,
    actor_email TEXT,
    action TEXT NOT NULL,
    target_type TEXT,
    target_id TEXT,
    details JSONB DEFAULT '{}'::jsonb,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.system_audit_logs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Allow authenticated users to read audit logs" ON public.system_audit_logs;
    CREATE POLICY "Allow authenticated users to read audit logs" ON public.system_audit_logs
        FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL;
END $$;

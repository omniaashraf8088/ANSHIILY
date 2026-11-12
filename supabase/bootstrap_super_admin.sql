-- ==============================================================================
-- ANSHIILY (أنشئلي) - Secure SUPER_ADMIN Bootstrap Procedure (Hardened)
-- ==============================================================================
-- This script provides an authorized, idempotent procedure to bootstrap or assign
-- the initial SUPER_ADMIN role in the ANSHIILY platform.
--
-- SECURITY CONTROLS:
-- 1. Explicitly revokes EXECUTE from PUBLIC, anon, and authenticated roles.
-- 2. Restricts execution strictly to database superuser (postgres) or service_role.
-- 3. Defends against unauthorized PostgREST RPC invocation.
-- 4. Records the bootstrap event in immutable system_audit_logs.
--
-- INSTRUCTIONS:
-- 1. Ensure the user has registered in auth.users (via Flutter mobile app or Supabase Auth).
-- 2. Execute the procedure below with the verified administrator email:
--    SELECT public.bootstrap_super_admin('omnia52481019@gmail.com');
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
    -- 0. DEFENSE IN DEPTH: Strict role enforcement
    calling_role := current_user;
    IF calling_role NOT IN ('postgres', 'service_role', 'supabase_admin') THEN
        RAISE EXCEPTION 'CRITICAL SECURITY VIOLATION: bootstrap_super_admin may only be executed directly by database administrator or service_role. Calling role: %', calling_role;
    END IF;

    -- 1. Look up user by email in auth.users
    SELECT id INTO target_user_id 
    FROM auth.users 
    WHERE email = LOWER(TRIM(admin_email));

    IF target_user_id IS NULL THEN
        RAISE EXCEPTION 'User with email % does not exist in auth.users. Please register the account first.', admin_email;
    END IF;

    -- 2. Insert or promote to SUPER_ADMIN in public.admin_users
    INSERT INTO public.admin_users (id, email, role, is_active)
    VALUES (target_user_id, LOWER(TRIM(admin_email)), 'SUPER_ADMIN', true)
    ON CONFLICT (email) DO UPDATE
    SET 
        role = 'SUPER_ADMIN',
        is_active = true,
        updated_at = timezone('utc'::text, now());

    -- 3. Also grant is_premium to profile for administrative design testing
    UPDATE public.profiles
    SET is_premium = true, credits = 9999
    WHERE id = target_user_id;

    -- 4. Record the bootstrap event in audit logs
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

-- CRITICAL PRIVILEGE HARDENING:
-- In PostgreSQL, functions created with CREATE FUNCTION have EXECUTE granted to PUBLIC by default.
-- We explicitly revoke EXECUTE from PUBLIC, anon, and authenticated to prevent PostgREST RPC abuse.
REVOKE ALL ON FUNCTION public.bootstrap_super_admin(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.bootstrap_super_admin(TEXT) FROM anon;
REVOKE ALL ON FUNCTION public.bootstrap_super_admin(TEXT) FROM authenticated;

-- Grant EXECUTE exclusively to trusted administrative roles
GRANT EXECUTE ON FUNCTION public.bootstrap_super_admin(TEXT) TO postgres;
GRANT EXECUTE ON FUNCTION public.bootstrap_super_admin(TEXT) TO service_role;

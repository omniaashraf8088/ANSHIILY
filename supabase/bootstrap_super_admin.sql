-- ==============================================================================
-- ANSHIILY (أنشئلي) - Secure SUPER_ADMIN Bootstrap Procedure
-- ==============================================================================
-- This script provides an authorized, idempotent procedure to bootstrap or assign
-- the initial SUPER_ADMIN role in the ANSHIILY platform.
--
-- INSTRUCTIONS:
-- 1. Ensure the user has registered in auth.users (via Flutter mobile app or Supabase Auth).
-- 2. Execute the procedure below with the verified administrator email:
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.bootstrap_super_admin(admin_email TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    target_user_id UUID;
    result_message TEXT;
BEGIN
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
        jsonb_build_object('role', 'SUPER_ADMIN', 'assigned_at', now())
    );

    result_message := format('SUPER_ADMIN successfully assigned to %s (UUID: %s)', admin_email, target_user_id);
    RETURN result_message;
END;
$$;

-- Example execution:
-- SELECT public.bootstrap_super_admin('omnia52481019@gmail.com');

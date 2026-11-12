-- ==============================================================================
-- ANSHIILY (أنشئلي) - Phase 6 Database Migration
-- Professional Export Engine & Subscription Security Policies
-- ==============================================================================

-- 1. Ensure Subscriptions Table Exists with Indexes
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL DEFAULT 'free', -- 'free', 'premium', 'pro'
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'canceled', 'expired', 'trialing'
    current_period_start TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_status ON public.subscriptions (user_id, status);

-- 2. Ensure Export Jobs Table Exists
CREATE TABLE IF NOT EXISTS public.export_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
    export_format TEXT NOT NULL, -- 'png', 'jpg', 'pdf'
    status TEXT NOT NULL DEFAULT 'completed',
    output_url TEXT,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_export_jobs_user_id ON public.export_jobs (user_id);

-- 3. RLS Policies for Subscriptions
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view their own subscription" ON public.subscriptions;
    CREATE POLICY "Users can view their own subscription"
        ON public.subscriptions FOR SELECT
        USING (auth.uid() = user_id);

    DROP POLICY IF EXISTS "Users can insert their own subscription" ON public.subscriptions;
    CREATE POLICY "Users can insert their own subscription"
        ON public.subscriptions FOR INSERT
        WITH CHECK (auth.uid() = user_id);

    DROP POLICY IF EXISTS "Users can update their own subscription" ON public.subscriptions;
    CREATE POLICY "Users can update their own subscription"
        ON public.subscriptions FOR UPDATE
        USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 4. RLS Policies for Export Jobs
ALTER TABLE public.export_jobs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view their own export jobs" ON public.export_jobs;
    CREATE POLICY "Users can view their own export jobs"
        ON public.export_jobs FOR SELECT
        USING (auth.uid() = user_id);

    DROP POLICY IF EXISTS "Users can insert their own export jobs" ON public.export_jobs;
    CREATE POLICY "Users can insert their own export jobs"
        ON public.export_jobs FOR INSERT
        WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;


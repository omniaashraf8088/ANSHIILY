-- ==============================================================================
-- ANSHIILY (أنشئلي) - Phase 4 Complete Database Schema & AI Engine Architecture
-- Comprehensive Migration for wwfhoogtnwyavyvuabbw
-- ==============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. User Profiles Table (Ensuring all columns exist)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL DEFAULT '',
    username TEXT UNIQUE,
    avatar_url TEXT,
    bio TEXT,
    credits INTEGER NOT NULL DEFAULT 10,
    is_premium BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
    CREATE POLICY "Public profiles are viewable by everyone"
        ON public.profiles FOR SELECT USING (true);

    DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
    CREATE POLICY "Users can insert their own profile"
        ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

    DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
    CREATE POLICY "Users can update their own profile"
        ON public.profiles FOR UPDATE USING (auth.uid() = id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 3. Projects / Designs Table
CREATE TABLE IF NOT EXISTS public.designs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    prompt TEXT NOT NULL,
    image_url TEXT,
    status TEXT NOT NULL DEFAULT 'draft',
    style TEXT,
    aspect_ratio TEXT DEFAULT '1:1',
    is_public BOOLEAN NOT NULL DEFAULT false,
    template_id UUID,
    document_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Ensure document_data and template_id exist if table pre-existed
ALTER TABLE public.designs ADD COLUMN IF NOT EXISTS template_id UUID;
ALTER TABLE public.designs ADD COLUMN IF NOT EXISTS document_data JSONB DEFAULT '{}'::jsonb;

ALTER TABLE public.designs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view their own designs or public ones" ON public.designs;
    CREATE POLICY "Users can view their own designs or public ones"
        ON public.designs FOR SELECT
        USING (auth.uid() = user_id OR is_public = true);

    DROP POLICY IF EXISTS "Users can create their own designs" ON public.designs;
    CREATE POLICY "Users can create their own designs"
        ON public.designs FOR INSERT
        WITH CHECK (auth.uid() = user_id);

    DROP POLICY IF EXISTS "Users can update their own designs" ON public.designs;
    CREATE POLICY "Users can update their own designs"
        ON public.designs FOR UPDATE
        USING (auth.uid() = user_id);

    DROP POLICY IF EXISTS "Users can delete their own designs" ON public.designs;
    CREATE POLICY "Users can delete their own designs"
        ON public.designs FOR DELETE
        USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- Create projects view for transparent compatibility
CREATE OR REPLACE VIEW public.projects AS
    SELECT * FROM public.designs;

-- 4. Project Pages Table (Granular Multi-Page Document Model)
CREATE TABLE IF NOT EXISTS public.project_pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.designs(id) ON DELETE CASCADE,
    page_number INTEGER NOT NULL DEFAULT 1,
    width DOUBLE PRECISION NOT NULL DEFAULT 1080,
    height DOUBLE PRECISION NOT NULL DEFAULT 1080,
    background_color TEXT,
    background_image TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.project_pages ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can manage pages of their own projects" ON public.project_pages;
    CREATE POLICY "Users can manage pages of their own projects"
        ON public.project_pages FOR ALL
        USING (
            EXISTS (
                SELECT 1 FROM public.designs
                WHERE public.designs.id = project_pages.project_id
                AND public.designs.user_id = auth.uid()
            )
        );
EXCEPTION WHEN others THEN NULL;
END $$;

-- 5. Project Elements Table (Granular Layer/Component Architecture)
CREATE TABLE IF NOT EXISTS public.project_elements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    page_id UUID NOT NULL REFERENCES public.project_pages(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES public.designs(id) ON DELETE CASCADE,
    element_type TEXT NOT NULL, -- 'text', 'image', 'shape', 'decorative'
    content TEXT NOT NULL,
    x DOUBLE PRECISION NOT NULL DEFAULT 0,
    y DOUBLE PRECISION NOT NULL DEFAULT 0,
    width DOUBLE PRECISION NOT NULL DEFAULT 100,
    height DOUBLE PRECISION NOT NULL DEFAULT 40,
    rotation DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    opacity DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    z_index INTEGER NOT NULL DEFAULT 0,
    is_locked BOOLEAN NOT NULL DEFAULT false,
    style JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.project_elements ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can manage elements of their own projects" ON public.project_elements;
    CREATE POLICY "Users can manage elements of their own projects"
        ON public.project_elements FOR ALL
        USING (
            EXISTS (
                SELECT 1 FROM public.designs
                WHERE public.designs.id = project_elements.project_id
                AND public.designs.user_id = auth.uid()
            )
        );
EXCEPTION WHEN others THEN NULL;
END $$;

-- 6. Design Categories Table
CREATE TABLE IF NOT EXISTS public.design_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_ar TEXT NOT NULL,
    name_en TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description_ar TEXT,
    description_en TEXT,
    icon_name TEXT DEFAULT 'brush',
    cover_image TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.design_categories ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Active design categories are viewable by everyone" ON public.design_categories;
    CREATE POLICY "Active design categories are viewable by everyone"
        ON public.design_categories FOR SELECT
        USING (is_active = true);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 7. Design Templates Table
CREATE TABLE IF NOT EXISTS public.design_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES public.design_categories(id) ON DELETE SET NULL,
    category_slug TEXT NOT NULL,
    name_ar TEXT NOT NULL,
    name_en TEXT NOT NULL,
    description_ar TEXT,
    description_en TEXT,
    thumbnail_url TEXT NOT NULL,
    preview_url TEXT NOT NULL,
    width DOUBLE PRECISION NOT NULL DEFAULT 1080,
    height DOUBLE PRECISION NOT NULL DEFAULT 1080,
    page_count INTEGER NOT NULL DEFAULT 1,
    is_premium BOOLEAN NOT NULL DEFAULT false,
    is_featured BOOLEAN NOT NULL DEFAULT false,
    popularity_score INTEGER NOT NULL DEFAULT 0,
    document_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.design_templates ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public templates are viewable by everyone" ON public.design_templates;
    CREATE POLICY "Public templates are viewable by everyone"
        ON public.design_templates FOR SELECT
        USING (true);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 8. User Uploads Table
CREATE TABLE IF NOT EXISTS public.user_uploads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    width INTEGER,
    height INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.user_uploads ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can manage their own uploads" ON public.user_uploads;
    CREATE POLICY "Users can manage their own uploads"
        ON public.user_uploads FOR ALL
        USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 9. Subscriptions Table
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL DEFAULT 'free',
    status TEXT NOT NULL DEFAULT 'active',
    current_period_start TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view their own subscription" ON public.subscriptions;
    CREATE POLICY "Users can view their own subscription"
        ON public.subscriptions FOR SELECT
        USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 10. Export Jobs Table
CREATE TABLE IF NOT EXISTS public.export_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.designs(id) ON DELETE CASCADE,
    export_format TEXT NOT NULL, -- 'png', 'pdf', 'svg', 'json'
    status TEXT NOT NULL DEFAULT 'pending',
    output_url TEXT,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.export_jobs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view and create their own export jobs" ON public.export_jobs;
    CREATE POLICY "Users can view and create their own export jobs"
        ON public.export_jobs FOR ALL
        USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 11. Human Assistance Requests Table
CREATE TABLE IF NOT EXISTS public.human_assistance_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.designs(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open',
    designer_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.human_assistance_requests ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can manage their own assistance requests" ON public.human_assistance_requests;
    CREATE POLICY "Users can manage their own assistance requests"
        ON public.human_assistance_requests FOR ALL
        USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 12. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'system',
    is_read BOOLEAN NOT NULL DEFAULT false,
    data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can manage their own notifications" ON public.notifications;
    CREATE POLICY "Users can manage their own notifications"
        ON public.notifications FOR ALL
        USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 13. AI Generation Usage Tracking Table
CREATE TABLE IF NOT EXISTS public.ai_generation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    provider TEXT NOT NULL DEFAULT 'openai',
    model TEXT NOT NULL DEFAULT 'gpt-4o',
    prompt TEXT NOT NULL,
    category TEXT,
    dimensions TEXT,
    status TEXT NOT NULL DEFAULT 'completed',
    tokens_used INTEGER DEFAULT 0,
    latency_ms INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.ai_generation_logs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view their own AI generation logs" ON public.ai_generation_logs;
    CREATE POLICY "Users can view their own AI generation logs"
        ON public.ai_generation_logs FOR SELECT
        USING (auth.uid() = user_id);

    DROP POLICY IF EXISTS "Users can insert their own AI generation logs" ON public.ai_generation_logs;
    CREATE POLICY "Users can insert their own AI generation logs"
        ON public.ai_generation_logs FOR INSERT
        WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL;
END $$;

-- 14. Provision Storage Buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('avatars', 'avatars', true),
    ('user-uploads', 'user-uploads', false),
    ('project-previews', 'project-previews', true),
    ('exported-designs', 'exported-designs', false)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies for user-uploads (Private, user-isolated)
DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
    CREATE POLICY "Users can upload their own files"
        ON storage.objects FOR INSERT
        TO authenticated
        WITH CHECK (bucket_id = 'user-uploads' AND (storage.foldername(name))[1] = auth.uid()::text);

    DROP POLICY IF EXISTS "Users can read their own files" ON storage.objects;
    CREATE POLICY "Users can read their own files"
        ON storage.objects FOR SELECT
        TO authenticated
        USING (bucket_id = 'user-uploads' AND (storage.foldername(name))[1] = auth.uid()::text);
EXCEPTION WHEN others THEN NULL;
END $$;


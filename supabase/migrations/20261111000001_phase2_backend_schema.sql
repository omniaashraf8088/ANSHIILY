-- ==============================================================================
-- ANSHIILY (أنشئلي) - Phase 2 Database Migration & Schema
-- From Idea to Design | من فكرة إلى تصميم
-- Project: wwfhoogtnwyavyvuabbw
-- ==============================================================================

-- 1. Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create User Profiles Table
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

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone"
    ON public.profiles FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- 3. Automatic Profile Creation Trigger on Auth Signup
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Create Categories Table
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_ar TEXT NOT NULL,
    name_en TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    icon_name TEXT DEFAULT 'brush',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Categories are viewable by everyone" ON public.categories;
CREATE POLICY "Categories are viewable by everyone"
    ON public.categories FOR SELECT
    USING (true);

-- Seed Categories
INSERT INTO public.categories (name_ar, name_en, slug, icon_name)
VALUES
    ('شعارات وعلامات تجارية', 'Logos & Branding', 'logos', 'brush'),
    ('منشورات سوشيال ميديا', 'Social Media Posts', 'social', 'share'),
    ('واجهات مستخدم وتطبيقات', 'UI/UX & Mobile', 'uiux', 'smartphone'),
    ('بوسترات وإعلانات', 'Posters & Ads', 'posters', 'image'),
    ('بطاقات عمل ودعوات', 'Business Cards & Invites', 'cards', 'credit_card')
ON CONFLICT (slug) DO NOTHING;

-- 5. Create Designs / Projects Table
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
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Enable RLS on designs
ALTER TABLE public.designs ENABLE ROW LEVEL SECURITY;

-- Designs Policies
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

-- 6. Create Projects View for compatibility
CREATE OR REPLACE VIEW public.projects AS
    SELECT * FROM public.designs;

-- 7. Supabase Storage Setup (Buckets & RLS)
INSERT INTO storage.buckets (id, name, public)
VALUES ('designs', 'designs', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies for designs
DROP POLICY IF EXISTS "Authenticated users can upload design files" ON storage.objects;
CREATE POLICY "Authenticated users can upload design files"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'designs' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users can update their own design files" ON storage.objects;
CREATE POLICY "Users can update their own design files"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (bucket_id = 'designs' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users can delete their own design files" ON storage.objects;
CREATE POLICY "Users can delete their own design files"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'designs' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Design files are publicly accessible" ON storage.objects;
CREATE POLICY "Design files are publicly accessible"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'designs');


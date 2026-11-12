-- ==============================================================================
-- ANSHIILY (أنشئلي) - Phase 3 Database Migration
-- Design Categories & Structured Template Library
-- ==============================================================================

-- 1. Create Design Categories Table
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

-- Enable RLS
ALTER TABLE public.design_categories ENABLE ROW LEVEL SECURITY;

-- Category Policies
DROP POLICY IF EXISTS "Active design categories are viewable by everyone" ON public.design_categories;
CREATE POLICY "Active design categories are viewable by everyone"
    ON public.design_categories FOR SELECT
    USING (is_active = true);

-- 2. Create Design Templates Table with Structured Document Data
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

-- Enable RLS
ALTER TABLE public.design_templates ENABLE ROW LEVEL SECURITY;

-- Template Policies (Public Read)
DROP POLICY IF EXISTS "Public templates are viewable by everyone" ON public.design_templates;
CREATE POLICY "Public templates are viewable by everyone"
    ON public.design_templates FOR SELECT
    USING (true);

-- 3. Seed Initial 10 Expandable Design Categories
INSERT INTO public.design_categories (name_ar, name_en, slug, description_ar, description_en, icon_name, cover_image, display_order)
VALUES
    ('تصاميم منصات التواصل', 'Social Media Designs', 'social-media', 'قوالب انستغرام، فيسبوك، وتيك توك احترافية', 'Templates for Instagram, Facebook, and TikTok', 'share', 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?auto=format&fit=crop&w=800&q=80', 1),
    ('التسويق والإعلانات', 'Marketing & Advertising', 'marketing', 'حملات إعلانية، بانرات، ولافتات ترويجية جذابة', 'Advertising campaigns, banners, and promotional designs', 'campaign', 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=800&q=80', 2),
    ('البروشورات', 'Brochures', 'brochures', 'كتيبات ومطويات تسويقية ثنائية وثلاثية الطيات', 'Bi-fold and tri-fold marketing brochures', 'menu_book', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80', 3),
    ('الفلايرات الدعائية', 'Flyers', 'flyers', 'منشورات ورقية ورقمية للفعاليات والأنشطة', 'Digital and print flyers for events and promotions', 'feed', 'https://images.unsplash.com/photo-1586281380349-632531db7ed4?auto=format&fit=crop&w=800&q=80', 4),
    ('المستندات المهنية', 'Business Documents', 'business-documents', 'فواتير، مراسلات رسمية، وسير ذاتية فاخرة', 'Invoices, letterheads, and executive resumes', 'description', 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=800&q=80', 5),
    ('المخططات والجداول', 'Planners', 'planners', 'مخططات يومية، أسبوعية، ومنظمات أهداف سنوية', 'Daily, weekly planners and goal organizers', 'calendar_today', 'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?auto=format&fit=crop&w=800&q=80', 6),
    ('العروض التقديمية', 'Presentations', 'presentations', 'شرائح باوربوينت وعروض أعمال بأناقة عالية', 'Modern presentation decks and pitch decks', 'slideshow', 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=800&q=80', 7),
    ('بطاقات الدعوة والتهنئة', 'Invitations', 'invitations', 'دعوات أعراس، مناسبات، وبطاقات معايدة راقية', 'Wedding invites, celebrations, and greeting cards', 'mail', 'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=800&q=80', 8),
    ('التصاميم التعليمية', 'Educational Designs', 'educational', 'ملصقات ومخططات بصرية للمدارس والجامعات', 'Infographics and visual aids for schools and universities', 'school', 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=800&q=80', 9),
    ('التصاميم الشخصية', 'Personal Designs', 'personal', 'أغلفة مذكرات، خلفيات شاشة، وبطاقات ذكريات', 'Wallpapers, journal covers, and memory albums', 'person', 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?auto=format&fit=crop&w=800&q=80', 10)
ON CONFLICT (slug) DO UPDATE
SET
    name_ar = EXCLUDED.name_ar,
    name_en = EXCLUDED.name_en,
    description_ar = EXCLUDED.description_ar,
    description_en = EXCLUDED.description_en,
    icon_name = EXCLUDED.icon_name,
    cover_image = EXCLUDED.cover_image,
    display_order = EXCLUDED.display_order;

-- 4. Seed Representative Structured Templates with Editable Elements
INSERT INTO public.design_templates (
    category_slug,
    name_ar,
    name_en,
    description_ar,
    description_en,
    thumbnail_url,
    preview_url,
    width,
    height,
    page_count,
    is_premium,
    is_featured,
    popularity_score,
    document_data
) VALUES
(
    'social-media',
    'بوست انستغرام فخم بالخط الكوفي',
    'Luxury Kufic Instagram Post',
    'قالب مربع راقٍ بتدرجات كحلية وذهبية مع مساحات نصوص قابلة للتعديل وصورة مركزية.',
    'Square luxury template with navy and gold gradients, editable typography, and photo frame.',
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
    1080,
    1080,
    1,
    false,
    true,
    98,
    '{"pages": [{"id": "page_1", "background": {"color": "#0B132B"}, "elements": [{"id": "el_1", "type": "text", "content": "أصالة وإبداع", "x": 100, "y": 180, "width": 880, "height": 120, "style": {"fontSize": 48, "color": "#D4AF37", "fontFamily": "Tajawal", "fontWeight": "bold", "textAlign": "center"}}, {"id": "el_2", "type": "text", "content": "حوّل شغفك إلى واقع ملموس مع أرقى الحلول الإبداعية المبتكرة", "x": 140, "y": 320, "width": 800, "height": 100, "style": {"fontSize": 24, "color": "#F6E9D8", "fontFamily": "Tajawal", "textAlign": "center"}}, {"id": "el_3", "type": "image", "content": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80", "x": 140, "y": 440, "width": 800, "height": 500, "style": {"borderRadius": 24}}]}]}'::jsonb
),
(
    'marketing',
    'بانر ترويجي لعروض نهاية الموسم',
    'End of Season Promo Banner',
    'تصميم ترويجي عريض للإعلانات وحملات التخفيضات مع شارات خصم بارزة.',
    'Wide promotional design for sales campaigns with prominent discount badges.',
    'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=1200&q=80',
    1200,
    628,
    1,
    true,
    true,
    95,
    '{"pages": [{"id": "page_1", "background": {"color": "#111B38"}, "elements": [{"id": "el_1", "type": "text", "content": "خصم يصل إلى 50%", "x": 80, "y": 120, "width": 600, "height": 90, "style": {"fontSize": 52, "color": "#D4AF37", "fontWeight": "bold"}}, {"id": "el_2", "type": "text", "content": "لفترة محدودة - استمتع بأقوى العروض الحصرية", "x": 80, "y": 230, "width": 550, "height": 60, "style": {"fontSize": 22, "color": "#F6E9D8"}}]}]}'::jsonb
),
(
    'presentations',
    'عرض تقديمي استثماري للشركات الناشئة',
    'Pitch Deck Presentation Slide',
    'سلسلة شرائح متناسقة لعرض نماذج الأعمال، الإحصائيات، وخطط النمو للمستثمرين.',
    'Consistent presentation deck for business models, metrics, and growth plans.',
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80',
    1920,
    1080,
    3,
    true,
    true,
    92,
    '{"pages": [{"id": "slide_1", "background": {"color": "#0B132B"}, "elements": [{"id": "title", "type": "text", "content": "استراتيجية النمو 2027", "x": 160, "y": 300, "width": 1200, "height": 140, "style": {"fontSize": 64, "color": "#D4AF37", "fontWeight": "bold"}}, {"id": "subtitle", "type": "text", "content": "رؤية مستقبلية نحو التوسع والريادة", "x": 160, "y": 460, "width": 1000, "height": 80, "style": {"fontSize": 32, "color": "#F6E9D8"}}]}]}'::jsonb
),
(
    'invitations',
    'بطاقة دعوة زفاف ملكية فاخرة',
    'Royal Wedding Invitation Card',
    'بطاقة رأسية فخمة بنقوش وزخارف ذهبية عربية أنيقة مع نصوص دعوة قابلة للتخصيص.',
    'Vertical luxury invitation with ornate golden motifs and custom typography.',
    'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80',
    1080,
    1920,
    1,
    false,
    true,
    97,
    '{"pages": [{"id": "page_1", "background": {"color": "#0B132B"}, "elements": [{"id": "header", "type": "text", "content": "دعوة زفاف خاصة", "x": 100, "y": 280, "width": 880, "height": 100, "style": {"fontSize": 44, "color": "#D4AF37", "textAlign": "center"}}, {"id": "names", "type": "text", "content": "أحمد & مريم", "x": 100, "y": 420, "width": 880, "height": 120, "style": {"fontSize": 56, "color": "#F6E9D8", "textAlign": "center"}}]}]}'::jsonb
),
(
    'brochures',
    'بروشور تعريفي لخدمات معمارية',
    'Architectural Studio Tri-fold Brochure',
    'مطوية ثلاثية الصفحات تستعرض المشاريع الهندسية وخدمات التصميم الداخلي.',
    'Tri-fold brochure highlighting architectural projects and interior services.',
    'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=1200&q=80',
    1920,
    1080,
    2,
    true,
    false,
    88,
    '{"pages": [{"id": "panel_1", "background": {"color": "#0E1830"}, "elements": [{"id": "title", "type": "text", "content": "الإبداع الهندسي الحديث", "x": 120, "y": 200, "width": 600, "height": 100, "style": {"fontSize": 40, "color": "#D4AF37"}}]}]}'::jsonb
),
(
    'business-documents',
    'سيرة ذاتية تنفيذية راقية',
    'Executive Modern Resume',
    'نموذج سيرة ذاتية رسمي منسق بأسلوب حديث يبرز الخبرات والمهارات القيادية.',
    'Official modern resume layout emphasizing executive leadership and skills.',
    'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=1200&q=80',
    1240,
    1754,
    1,
    false,
    false,
    86,
    '{"pages": [{"id": "page_1", "background": {"color": "#111B38"}, "elements": [{"id": "name", "type": "text", "content": "محمد خالد العتيبي", "x": 100, "y": 140, "width": 800, "height": 90, "style": {"fontSize": 48, "color": "#D4AF37"}}, {"id": "role", "type": "text", "content": "مدير تطوير الأعمال الرقمية", "x": 100, "y": 240, "width": 800, "height": 60, "style": {"fontSize": 24, "color": "#F6E9D8"}}]}]}'::jsonb
);


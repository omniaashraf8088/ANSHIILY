'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { HardDrive, Lock, Globe, Copy, Check, ShieldCheck, Database } from 'lucide-react';

export function StorageModule() {
  const { t } = useAdmin();
  const [copied, setCopied] = useState(false);

  const buckets = [
    {
      name: 'avatars',
      descriptionAr: 'صور الحسابات والملفات الشخصية للمستخدمين',
      descriptionEn: 'User profile pictures and avatars',
      isPublic: true,
      allowedMime: 'image/jpeg, image/png, image/webp',
    },
    {
      name: 'user-uploads',
      descriptionAr: 'ملفات وصور المستخدمين الخاصة المرفوعة للمحرر',
      descriptionEn: 'User-uploaded brand assets & canvas images',
      isPublic: false,
      allowedMime: 'image/*',
    },
    {
      name: 'project-previews',
      descriptionAr: 'الصور المصغرة ومعاينات مشاريع التصميم',
      descriptionEn: 'Project thumbnails and design preview renders',
      isPublic: true,
      allowedMime: 'image/png, image/jpeg',
    },
    {
      name: 'exported-designs',
      descriptionAr: 'ملفات التصدير النهائية بجودة الطباعة (PNG, JPG, PDF)',
      descriptionEn: 'Final 300 DPI exports (PNG, JPG, PDF v1.5)',
      isPublic: false,
      allowedMime: 'image/png, image/jpeg, application/pdf',
    },
    {
      name: 'templates',
      descriptionAr: 'صور ومصغرات قوالب أنشئلي الرسمية',
      descriptionEn: 'Official ANSHIILY templates and master covers',
      isPublic: true,
      allowedMime: 'image/*',
    },
  ];

  const bucketSql = `-- ANSHIILY Complete Storage Setup for wwfhoogtnwyavyvuabbw
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('avatars', 'avatars', true),
    ('user-uploads', 'user-uploads', false),
    ('project-previews', 'project-previews', true),
    ('exported-designs', 'exported-designs', false),
    ('templates', 'templates', true)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies for Storage
DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can view avatars" ON storage.objects;
    CREATE POLICY "Public can view avatars" ON storage.objects
        FOR SELECT USING (bucket_id = 'avatars');

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
END $$;`;

  const copyToClipboard = () => {
    navigator.clipboard.writeText(bucketSql);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="p-4 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 flex items-center justify-between">
        <div>
          <h3 className="font-bold text-sm text-[#F6E9D8] flex items-center gap-2">
            <HardDrive className="w-4 h-4 text-[#D4AF37]" />
            {t('أحواض التخزين السحابي (Supabase Storage)', 'Supabase Cloud Storage Buckets')}
          </h3>
          <p className="text-xs text-[#F6E9D8]/60 mt-0.5">
            {t(
              'تهيئة أحواض الصور، المعاينات، وملفات الـ PDF مع سياسات الأمان RLS',
              'Storage buckets for user assets, thumbnails, and 300 DPI high-res exports'
            )}
          </p>
        </div>
        <button
          onClick={copyToClipboard}
          className="px-3.5 py-1.5 rounded-xl bg-[#0B132B] border border-[#D4AF37]/40 text-[#D4AF37] hover:border-[#D4AF37] font-semibold text-xs flex items-center gap-1.5 transition-all"
        >
          {copied ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
          <span>{copied ? t('تم النسخ!', 'Copied SQL!') : t('نسخ كود SQL لـ Supabase', 'Copy Storage SQL')}</span>
        </button>
      </div>

      {/* Buckets Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {buckets.map((b) => (
          <div
            key={b.name}
            className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 hover:border-[#D4AF37]/50 transition-all flex flex-col justify-between"
          >
            <div>
              <div className="flex items-center justify-between mb-3">
                <span className="font-mono text-xs font-bold text-[#F3E5AB] flex items-center gap-1.5">
                  <HardDrive className="w-3.5 h-3.5 text-[#D4AF37]" />
                  {b.name}
                </span>
                <span
                  className={`flex items-center gap-1 text-[10px] px-2 py-0.5 rounded-full font-bold ${
                    b.isPublic
                      ? 'bg-sky-500/15 text-sky-400 border border-sky-500/30'
                      : 'bg-amber-500/15 text-amber-400 border border-amber-500/30'
                  }`}
                >
                  {b.isPublic ? <Globe className="w-3 h-3" /> : <Lock className="w-3 h-3" />}
                  {b.isPublic ? 'PUBLIC' : 'PRIVATE'}
                </span>
              </div>
              <p className="text-xs text-[#F6E9D8] font-medium leading-relaxed mb-1">
                {t(b.descriptionAr, b.descriptionEn)}
              </p>
            </div>

            <div className="pt-3 mt-3 border-t border-[#D4AF37]/10 flex items-center justify-between text-[11px] text-[#F6E9D8]/50">
              <span>MIME: {b.allowedMime}</span>
              <span className="text-emerald-400 font-mono">RLS Protected</span>
            </div>
          </div>
        ))}
      </div>

      {/* SQL Snippet Preview Box */}
      <div className="p-5 rounded-2xl bg-[#0B132B] border border-[#D4AF37]/20 space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Database className="w-4 h-4 text-[#D4AF37]" />
            <h4 className="text-xs font-bold text-[#F3E5AB]">
              {t('كود تهيئة الأحواض وسياسات الأمان في Supabase SQL Editor', 'Storage Buckets SQL Initialization')}
            </h4>
          </div>
          <button
            onClick={copyToClipboard}
            className="text-xs text-[#D4AF37] hover:underline flex items-center gap-1"
          >
            <Copy className="w-3 h-3" />
            <span>{copied ? 'Copied' : 'Copy'}</span>
          </button>
        </div>
        <pre className="p-4 rounded-xl bg-[#111C3D] text-[11px] font-mono text-[#F3E5AB] border border-[#D4AF37]/15 overflow-x-auto leading-relaxed">
          {bucketSql}
        </pre>
      </div>
    </div>
  );
}


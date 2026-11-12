'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { DesignTemplate, DesignCategory } from '@/lib/types';
import { createClient } from '@/lib/supabase/client';
import { FileBox, Plus, Crown, Sparkles, Code2, Trash2, X, Star } from 'lucide-react';

interface TemplatesModuleProps {
  templates: DesignTemplate[];
  categories: DesignCategory[];
  onRefresh: () => void;
}

export function TemplatesModule({ templates, categories, onRefresh }: TemplatesModuleProps) {
  const { t, hasPermission } = useAdmin();
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [previewDoc, setPreviewDoc] = useState<DesignTemplate | null>(null);
  const [isAdding, setIsAdding] = useState(false);

  // New template form
  const [nameAr, setNameAr] = useState('');
  const [nameEn, setNameEn] = useState('');
  const [catSlug, setCatSlug] = useState('logos');
  const [isPro, setIsPro] = useState(false);
  const [isFeatured, setIsFeatured] = useState(false);
  const [width, setWidth] = useState(1080);
  const [height, setHeight] = useState(1080);
  const [thumbnailUrl, setThumbnailUrl] = useState('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800');
  const [loading, setLoading] = useState(false);

  const canEdit = hasPermission(['SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER']);
  const supabase = createClient();

  const filteredTemplates = templates.filter((tpl) => {
    if (selectedCategory === 'all') return true;
    return tpl.category_slug === selectedCategory;
  });

  const handleCreateTemplate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!nameAr || !nameEn) return;
    setLoading(true);
    try {
      const defaultDocumentData = {
        id: `tpl-${Date.now()}`,
        title: nameAr,
        aspectRatio: `${width}:${height}`,
        pages: [
          {
            id: 'page_1',
            background: { type: 'solid', color: '#0B132B' },
            elements: [
              {
                id: 'el_title',
                type: 'text',
                content: nameAr,
                x: width * 0.1,
                y: height * 0.4,
                width: width * 0.8,
                height: 80,
                style: {
                  fontSize: 48,
                  fontWeight: 'bold',
                  color: '#D4AF37',
                  textAlign: 'center',
                },
              },
            ],
          },
        ],
      };

      await supabase.from('design_templates').insert({
        name_ar: nameAr,
        name_en: nameEn,
        category_slug: catSlug,
        thumbnail_url: thumbnailUrl,
        preview_url: thumbnailUrl,
        width: width,
        height: height,
        is_premium: isPro,
        is_featured: isFeatured,
        document_data: defaultDocumentData,
      });

      setNameAr('');
      setNameEn('');
      setIsAdding(false);
      onRefresh();
    } catch (err) {
      console.error('Error creating template', err);
    } finally {
      setLoading(false);
    }
  };

  const handleTogglePremium = async (id: string, current: boolean) => {
    if (!canEdit) return;
    try {
      await supabase.from('design_templates').update({ is_premium: !current }).eq('id', id);
      onRefresh();
    } catch (err) {
      console.error('Error updating template', err);
    }
  };

  const handleDelete = async (id: string) => {
    if (!canEdit) return;
    if (!confirm(t('حذف هذا القالب نهائياً؟', 'Delete this template permanently?'))) return;
    try {
      await supabase.from('design_templates').delete().eq('id', id);
      onRefresh();
    } catch (err) {
      console.error('Error deleting template', err);
    }
  };

  return (
    <div className="space-y-6">
      {/* Top Filter & Actions */}
      <div className="p-4 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 flex flex-col md:flex-row items-center justify-between gap-4">
        {/* Category Pill Filters */}
        <div className="flex items-center gap-2 overflow-x-auto w-full md:w-auto pb-2 md:pb-0">
          <button
            onClick={() => setSelectedCategory('all')}
            className={`px-3 py-1.5 rounded-xl text-xs font-medium whitespace-nowrap transition-all ${
              selectedCategory === 'all'
                ? 'bg-[#D4AF37] text-[#0B132B] font-bold'
                : 'bg-[#0B132B] text-[#F6E9D8]/70 hover:text-[#F3E5AB] border border-[#D4AF37]/20'
            }`}
          >
            {t('جميع الأقسام', 'All Categories')} ({templates.length})
          </button>
          {categories.map((c) => (
            <button
              key={c.id}
              onClick={() => setSelectedCategory(c.slug)}
              className={`px-3 py-1.5 rounded-xl text-xs font-medium whitespace-nowrap transition-all ${
                selectedCategory === c.slug
                  ? 'bg-[#D4AF37] text-[#0B132B] font-bold'
                  : 'bg-[#0B132B] text-[#F6E9D8]/70 hover:text-[#F3E5AB] border border-[#D4AF37]/20'
              }`}
            >
              {c.name_ar}
            </button>
          ))}
        </div>

        {canEdit && (
          <button
            onClick={() => setIsAdding(!isAdding)}
            className="px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#AA8C2C] text-[#0B132B] font-bold text-xs shadow hover:brightness-110 transition-all flex items-center gap-1.5 shrink-0"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>{t('إضافة قالب جديد', 'New Template')}</span>
          </button>
        )}
      </div>

      {/* Add Template Modal */}
      {isAdding && (
        <form
          onSubmit={handleCreateTemplate}
          className="p-5 rounded-2xl bg-[#111C3D] border border-[#D4AF37]/40 space-y-4"
        >
          <div className="flex items-center justify-between">
            <h4 className="font-bold text-xs text-[#F3E5AB]">
              {t('إضافة قالب احترافي جديد', 'Add Professional Template')}
            </h4>
            <button onClick={() => setIsAdding(false)} className="text-[#F6E9D8]/50 hover:text-[#F6E9D8]">
              <X className="w-4 h-4" />
            </button>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-xs">
            <div>
              <label className="block text-[#F6E9D8]/70 mb-1">{t('العنوان بالعربية', 'Arabic Title')}</label>
              <input
                type="text"
                required
                value={nameAr}
                onChange={(e) => setNameAr(e.target.value)}
                placeholder="شعار ذهبي فاخر"
                className="w-full px-3 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-[#F6E9D8] focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
            <div>
              <label className="block text-[#F6E9D8]/70 mb-1">{t('العنوان بالإنجليزية', 'English Title')}</label>
              <input
                type="text"
                required
                value={nameEn}
                onChange={(e) => setNameEn(e.target.value)}
                placeholder="Luxury Gold Emblem"
                className="w-full px-3 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-[#F6E9D8] focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
            <div>
              <label className="block text-[#F6E9D8]/70 mb-1">{t('القسم', 'Category')}</label>
              <select
                value={catSlug}
                onChange={(e) => setCatSlug(e.target.value)}
                className="w-full px-3 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-[#F6E9D8] focus:outline-none focus:border-[#D4AF37]"
              >
                {categories.map((c) => (
                  <option key={c.id} value={c.slug}>
                    {c.name_ar} ({c.name_en})
                  </option>
                ))}
              </select>
            </div>
          </div>
          <div className="flex items-center gap-6 pt-2 text-xs">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={isPro}
                onChange={(e) => setIsPro(e.target.checked)}
                className="rounded accent-[#D4AF37]"
              />
              <span className="text-[#F6E9D8]">{t('قالب Pro مخصص للمشتركين', 'Pro Members Only')}</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={isFeatured}
                onChange={(e) => setIsFeatured(e.target.checked)}
                className="rounded accent-[#D4AF37]"
              />
              <span className="text-[#F6E9D8]">{t('عرض في الواجهة الرئيسية (Featured)', 'Featured on Home')}</span>
            </label>
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 rounded-lg bg-[#D4AF37] text-[#0B132B] text-xs font-bold hover:brightness-110"
            >
              {loading ? t('جار النشر...', 'Publishing...') : t('نشر القالب', 'Publish Template')}
            </button>
          </div>
        </form>
      )}

      {/* Templates Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {filteredTemplates.map((tpl) => (
          <div
            key={tpl.id}
            className="rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 hover:border-[#D4AF37]/60 overflow-hidden transition-all group flex flex-col justify-between"
          >
            {/* Image Preview */}
            <div className="relative aspect-square bg-[#0B132B] overflow-hidden flex items-center justify-center">
              {tpl.thumbnail_url ? (
                <img
                  src={tpl.thumbnail_url}
                  alt={tpl.name_ar}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
              ) : (
                <FileBox className="w-12 h-12 text-[#D4AF37]/30" />
              )}
              {/* Badges */}
              <div className="absolute top-2.5 start-2.5 flex items-center gap-1.5">
                {tpl.is_premium && (
                  <span className="px-2 py-0.5 rounded-md bg-[#7A0E2C]/90 text-[#F3E5AB] font-bold text-[10px] border border-[#D4AF37]/40 flex items-center gap-1 shadow">
                    <Crown className="w-3 h-3 text-[#D4AF37]" /> PRO
                  </span>
                )}
                {tpl.is_featured && (
                  <span className="px-2 py-0.5 rounded-md bg-[#0B132B]/90 text-[#D4AF37] text-[10px] border border-[#D4AF37]/40 flex items-center gap-1 shadow">
                    <Star className="w-3 h-3 fill-[#D4AF37]" />
                  </span>
                )}
              </div>
            </div>

            {/* Content */}
            <div className="p-4 flex-1 flex flex-col justify-between">
              <div>
                <p className="text-[10px] font-mono text-[#D4AF37]/80 uppercase">
                  #{tpl.category_slug}
                </p>
                <h4 className="font-bold text-xs text-[#F6E9D8] mt-1">{tpl.name_ar}</h4>
                <p className="text-[11px] text-[#F6E9D8]/60">{tpl.name_en}</p>
                <p className="text-[10px] text-[#F6E9D8]/40 mt-1">
                  {tpl.width} x {tpl.height} px
                </p>
              </div>

              {/* Actions */}
              <div className="flex items-center justify-between pt-3 mt-3 border-t border-[#D4AF37]/10 text-xs">
                <button
                  onClick={() => setPreviewDoc(tpl)}
                  title={t('عرض محتويات الطبقات JSON', 'Inspect JSON Document')}
                  className="flex items-center gap-1 text-[11px] text-[#D4AF37] hover:underline"
                >
                  <Code2 className="w-3.5 h-3.5" />
                  <span>JSON Layers</span>
                </button>
                {canEdit && (
                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => handleTogglePremium(tpl.id, tpl.is_premium)}
                      title={tpl.is_premium ? 'Free Tier' : 'Pro Tier'}
                      className="p-1 rounded bg-[#0B132B] text-[#D4AF37] hover:brightness-125"
                    >
                      <Crown className="w-3 h-3" />
                    </button>
                    <button
                      onClick={() => handleDelete(tpl.id)}
                      title={t('حذف', 'Delete')}
                      className="p-1 rounded bg-[#0B132B] text-rose-400 hover:bg-[#7A0E2C]/30"
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* JSON Viewer Modal */}
      {previewDoc && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="w-full max-w-2xl bg-[#0B132B] border border-[#D4AF37]/40 rounded-2xl p-6 max-h-[85vh] flex flex-col">
            <div className="flex items-center justify-between pb-3 border-b border-[#D4AF37]/20">
              <h3 className="font-bold text-sm text-[#F3E5AB]">
                {previewDoc.name_ar} - {t('بنية المستند متعدد الطبقات', 'Multi-layer Document JSON')}
              </h3>
              <button onClick={() => setPreviewDoc(null)} className="text-[#F6E9D8]/50 hover:text-[#F6E9D8]">
                <X className="w-5 h-5" />
              </button>
            </div>
            <pre className="flex-1 overflow-y-auto p-4 my-4 rounded-xl bg-[#111C3D] border border-[#D4AF37]/20 text-[11px] font-mono text-[#F3E5AB] leading-relaxed">
              {JSON.stringify(previewDoc.document_data, null, 2)}
            </pre>
            <div className="flex justify-end">
              <button
                onClick={() => setPreviewDoc(null)}
                className="px-4 py-2 rounded-xl bg-[#D4AF37] text-[#0B132B] font-bold text-xs"
              >
                {t('إغلاق', 'Close')}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

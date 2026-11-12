'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { DesignCategory } from '@/lib/types';
import { createClient } from '@/lib/supabase/client';
import { FolderTree, Plus, Edit2, Trash2, Check, X, Eye, EyeOff } from 'lucide-react';

interface CategoriesModuleProps {
  categories: DesignCategory[];
  onRefresh: () => void;
}

export function CategoriesModule({ categories, onRefresh }: CategoriesModuleProps) {
  const { t, hasPermission } = useAdmin();
  const [isAdding, setIsAdding] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  // Form states
  const [nameAr, setNameAr] = useState('');
  const [nameEn, setNameEn] = useState('');
  const [slug, setSlug] = useState('');
  const [iconName, setIconName] = useState('brush');
  const [displayOrder, setDisplayOrder] = useState(1);
  const [loading, setLoading] = useState(false);

  const canEdit = hasPermission(['SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER']);
  const supabase = createClient();

  const handleCreateCategory = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!nameAr || !nameEn || !slug) return;
    setLoading(true);
    try {
      await supabase.from('design_categories').insert({
        name_ar: nameAr,
        name_en: nameEn,
        slug: slug.toLowerCase().trim(),
        icon_name: iconName,
        display_order: displayOrder,
        is_active: true,
      });
      setNameAr('');
      setNameEn('');
      setSlug('');
      setIsAdding(false);
      onRefresh();
    } catch (err) {
      console.error('Error creating category', err);
    } finally {
      setLoading(false);
    }
  };

  const handleToggleActive = async (id: string, currentStatus: boolean) => {
    if (!canEdit) return;
    try {
      await supabase.from('design_categories').update({ is_active: !currentStatus }).eq('id', id);
      onRefresh();
    } catch (err) {
      console.error('Error toggling category', err);
    }
  };

  const handleDeleteCategory = async (id: string) => {
    if (!canEdit) return;
    if (!confirm(t('هل أنت متأكد من حذف هذا القسم؟', 'Are you sure you want to delete this category?'))) return;
    try {
      await supabase.from('design_categories').delete().eq('id', id);
      onRefresh();
    } catch (err) {
      console.error('Error deleting category', err);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header bar */}
      <div className="p-4 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 flex items-center justify-between">
        <div>
          <h3 className="font-bold text-sm text-[#F6E9D8] flex items-center gap-2">
            <FolderTree className="w-4 h-4 text-[#D4AF37]" />
            {t('أقسام وتصنيفات التصاميم', 'Design Categories')}
          </h3>
          <p className="text-xs text-[#F6E9D8]/60 mt-0.5">
            {t('تحديد التصنيفات المتاحة في تطبيق الهاتف والمحرر الذكي', 'Manage available design categories across mobile app and AI generator')}
          </p>
        </div>
        {canEdit && (
          <button
            onClick={() => setIsAdding(!isAdding)}
            className="px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#AA8C2C] text-[#0B132B] font-bold text-xs shadow hover:brightness-110 transition-all flex items-center gap-1.5"
          >
            {isAdding ? <X className="w-3.5 h-3.5" /> : <Plus className="w-3.5 h-3.5" />}
            <span>{isAdding ? t('إلغاء', 'Cancel') : t('إضافة تصنيف جديد', 'New Category')}</span>
          </button>
        )}
      </div>

      {/* Add Form modal / drawer */}
      {isAdding && (
        <form
          onSubmit={handleCreateCategory}
          className="p-5 rounded-2xl bg-[#111C3D] border border-[#D4AF37]/40 space-y-4 animate-in fade-in"
        >
          <h4 className="font-bold text-xs text-[#F3E5AB]">
            {t('إضافة قسم جديد إلى قاعدة البيانات', 'Add New Category to Supabase')}
          </h4>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3 text-xs">
            <div>
              <label className="block text-[#F6E9D8]/70 mb-1">{t('الاسم بالعربية', 'Arabic Name')}</label>
              <input
                type="text"
                required
                value={nameAr}
                onChange={(e) => setNameAr(e.target.value)}
                placeholder="مثال: هوية بصرية"
                className="w-full px-3 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-[#F6E9D8] focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
            <div>
              <label className="block text-[#F6E9D8]/70 mb-1">{t('الاسم بالإنجليزية', 'English Name')}</label>
              <input
                type="text"
                required
                value={nameEn}
                onChange={(e) => setNameEn(e.target.value)}
                placeholder="e.g. Visual Identity"
                className="w-full px-3 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-[#F6E9D8] focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
            <div>
              <label className="block text-[#F6E9D8]/70 mb-1">{t('المعرف الفريد (Slug)', 'Unique Slug')}</label>
              <input
                type="text"
                required
                value={slug}
                onChange={(e) => setSlug(e.target.value)}
                placeholder="visual_identity"
                className="w-full px-3 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-[#F6E9D8] focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
            <div>
              <label className="block text-[#F6E9D8]/70 mb-1">{t('اسم الأيقونة', 'Icon Name')}</label>
              <input
                type="text"
                value={iconName}
                onChange={(e) => setIconName(e.target.value)}
                placeholder="brush, share, image..."
                className="w-full px-3 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-[#F6E9D8] focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setIsAdding(false)}
              className="px-3 py-1.5 rounded-lg border border-[#D4AF37]/20 text-xs text-[#F6E9D8]/70 hover:bg-[#0B132B]"
            >
              {t('إلغاء', 'Cancel')}
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-1.5 rounded-lg bg-[#D4AF37] text-[#0B132B] text-xs font-bold hover:brightness-110"
            >
              {loading ? t('جار الحفظ...', 'Saving...') : t('حفظ القسم', 'Save Category')}
            </button>
          </div>
        </form>
      )}

      {/* Categories Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {categories.map((c) => (
          <div
            key={c.id}
            className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 hover:border-[#D4AF37]/50 transition-all flex flex-col justify-between"
          >
            <div>
              <div className="flex items-center justify-between mb-3">
                <span className="font-mono text-[10px] px-2 py-0.5 rounded bg-[#0B132B] text-[#D4AF37] border border-[#D4AF37]/20">
                  #{c.slug}
                </span>
                <span
                  className={`flex items-center gap-1 text-[10px] px-2 py-0.5 rounded-full font-medium ${
                    c.is_active
                      ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                      : 'bg-rose-500/15 text-rose-400 border border-rose-500/30'
                  }`}
                >
                  {c.is_active ? t('نشط', 'Active') : t('معطل', 'Inactive')}
                </span>
              </div>
              <h4 className="font-bold text-sm text-[#F6E9D8] mb-1">{c.name_ar}</h4>
              <p className="text-xs text-[#F6E9D8]/60 font-medium">{c.name_en}</p>
            </div>

            <div className="flex items-center justify-between pt-4 mt-4 border-t border-[#D4AF37]/10 text-xs">
              <span className="text-[11px] text-[#F6E9D8]/40">Icon: {c.icon_name}</span>
              {canEdit && (
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => handleToggleActive(c.id, c.is_active)}
                    title={c.is_active ? t('تعطيل القسم', 'Deactivate') : t('تفعيل القسم', 'Activate')}
                    className="p-1.5 rounded-lg bg-[#0B132B] border border-[#D4AF37]/20 text-[#F6E9D8] hover:text-[#D4AF37]"
                  >
                    {c.is_active ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                  </button>
                  <button
                    onClick={() => handleDeleteCategory(c.id)}
                    title={t('حذف القسم', 'Delete Category')}
                    className="p-1.5 rounded-lg bg-[#0B132B] border border-[#7A0E2C]/50 text-rose-400 hover:bg-[#7A0E2C]/30"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}


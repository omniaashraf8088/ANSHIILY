'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { DesignProject } from '@/lib/types';
import { Palette, Eye, Layers, Sparkles, X, Code2, Clock } from 'lucide-react';

interface DesignsModuleProps {
  designs: DesignProject[];
  onRefresh: () => void;
}

export function DesignsModule({ designs, onRefresh }: DesignsModuleProps) {
  const { t } = useAdmin();
  const [selectedDesign, setSelectedDesign] = useState<DesignProject | null>(null);

  return (
    <div className="space-y-6">
      {/* Header bar */}
      <div className="p-4 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 flex items-center justify-between">
        <div>
          <h3 className="font-bold text-sm text-[#F6E9D8] flex items-center gap-2">
            <Palette className="w-4 h-4 text-[#D4AF37]" />
            {t('مشاريع وتصاميم المستخدمين', 'User Projects & AI Layers')}
          </h3>
          <p className="text-xs text-[#F6E9D8]/60 mt-0.5">
            {t(
              'استعراض مستندات التصميم متعددة الطبقات (نصوص، أشكال، صور، خطوط عربية)',
              'Inspect multi-layer design documents generated via ANSHIILY AI Engine & Canvas'
            )}
          </p>
        </div>
        <span className="text-xs font-mono text-[#D4AF37]">
          {t(`إجمالي المشاريع: ${designs.length}`, `Total: ${designs.length}`)}
        </span>
      </div>

      {/* Grid of designs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {designs.length === 0 ? (
          <div className="col-span-full p-12 text-center rounded-2xl bg-[#111C3D]/40 border border-[#D4AF37]/10">
            <Layers className="w-10 h-10 text-[#D4AF37]/40 mx-auto mb-3" />
            <p className="text-xs text-[#F6E9D8]/50">
              {t(
                'لا توجد تصاميم محفوظة حالياً في جدول designs',
                'No designs currently stored in Supabase designs table'
              )}
            </p>
          </div>
        ) : (
          designs.map((d) => (
            <div
              key={d.id}
              className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 hover:border-[#D4AF37]/50 transition-all flex flex-col justify-between"
            >
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-[10px] px-2 py-0.5 rounded bg-[#0B132B] text-[#D4AF37] border border-[#D4AF37]/20 font-mono">
                    {d.aspect_ratio || '1:1'}
                  </span>
                  <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                    {d.status}
                  </span>
                </div>
                <h4 className="font-bold text-sm text-[#F6E9D8] mb-1">{d.title}</h4>
                <div className="p-3 rounded-xl bg-[#0B132B]/60 border border-[#D4AF37]/10 my-2">
                  <p className="text-[10px] text-[#D4AF37]/80 uppercase font-mono mb-0.5">
                    {t('الموجه الأصلي (Prompt):', 'Original Prompt:')}
                  </p>
                  <p className="text-xs text-[#F3E5AB] leading-relaxed line-clamp-3 font-medium">
                    «{d.prompt}»
                  </p>
                </div>
              </div>

              <div className="flex items-center justify-between pt-3 mt-2 border-t border-[#D4AF37]/10 text-xs">
                <span className="text-[10px] text-[#F6E9D8]/40 flex items-center gap-1">
                  <Clock className="w-3 h-3" />
                  {new Date(d.created_at).toLocaleDateString()}
                </span>
                <button
                  onClick={() => setSelectedDesign(d)}
                  className="px-3 py-1 rounded-lg bg-[#0B132B] border border-[#D4AF37]/30 text-[#D4AF37] hover:border-[#D4AF37] font-semibold flex items-center gap-1.5"
                >
                  <Layers className="w-3.5 h-3.5" />
                  <span>{t('فحص الطبقات', 'Inspect Layers')}</span>
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Layer Document Modal */}
      {selectedDesign && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="w-full max-w-2xl bg-[#0B132B] border border-[#D4AF37]/40 rounded-2xl p-6 max-h-[85vh] flex flex-col">
            <div className="flex items-center justify-between pb-3 border-b border-[#D4AF37]/20">
              <div className="flex items-center gap-2">
                <Sparkles className="w-4 h-4 text-[#D4AF37]" />
                <h3 className="font-bold text-sm text-[#F3E5AB]">{selectedDesign.title}</h3>
              </div>
              <button onClick={() => setSelectedDesign(null)} className="text-[#F6E9D8]/50 hover:text-[#F6E9D8]">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="my-4 space-y-3">
              <div className="p-3 rounded-xl bg-[#111C3D] border border-[#D4AF37]/20 text-xs">
                <p className="text-[10px] text-[#D4AF37] font-mono uppercase mb-1">
                  {t('فكرة التصميم والموجه (AI Prompt)', 'Design Concept & Prompt')}
                </p>
                <p className="text-sm text-[#F6E9D8] font-medium">«{selectedDesign.prompt}»</p>
              </div>

              <div className="p-4 rounded-xl bg-[#111C3D] border border-[#D4AF37]/20">
                <h4 className="text-xs font-bold text-[#D4AF37] mb-2 flex items-center gap-2">
                  <Code2 className="w-3.5 h-3.5" />
                  {t('بنية الطبقات المستقلة (Layers Document Schema)', 'Independent Layers Schema')}
                </h4>
                <pre className="overflow-y-auto max-h-64 p-3 rounded-lg bg-[#0B132B] text-[11px] font-mono text-[#F3E5AB] border border-[#D4AF37]/15">
                  {JSON.stringify(
                    selectedDesign.document_data || {
                      pages: [
                        {
                          id: 'page_1',
                          background: { type: 'solid', color: '#0B132B' },
                          elements: [
                            { type: 'text', role: 'title', content: selectedDesign.title },
                            { type: 'shape', role: 'accent_frame', color: '#D4AF37' },
                          ],
                        },
                      ],
                    },
                    null,
                    2
                  )}
                </pre>
              </div>
            </div>

            <div className="flex justify-end">
              <button
                onClick={() => setSelectedDesign(null)}
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


'use client';

import React from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { AIGenerationLog } from '@/lib/types';
import { Cpu, Zap, Activity, CheckCircle2, ShieldCheck, KeyRound, Server } from 'lucide-react';

interface AiAnalyticsModuleProps {
  logs: AIGenerationLog[];
  onRefresh: () => void;
}

export function AiAnalyticsModule({ logs, onRefresh }: AiAnalyticsModuleProps) {
  const { t } = useAdmin();

  const successLogs = logs.filter((l) => l.success);
  const successRate = logs.length > 0 ? Math.round((successLogs.length / logs.length) * 100) : 100;
  const avgLatency =
    logs.length > 0
      ? Math.round(
          logs.reduce((acc, curr) => acc + (curr.execution_time_ms || 1200), 0) / logs.length
        )
      : 1150;

  return (
    <div className="space-y-6">
      {/* AI Engine Security & Server-Side Notice */}
      <div className="p-5 rounded-2xl bg-[#111C3D]/90 border border-[#D4AF37]/30 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl bg-[#0B132B] border border-[#D4AF37]/40 flex items-center justify-center shrink-0">
            <ShieldCheck className="w-5 h-5 text-[#D4AF37]" />
          </div>
          <div>
            <h3 className="font-bold text-sm text-[#F3E5AB] flex items-center gap-2">
              <span>{t('معمارية الذكاء الاصطناعي على الخادم (Server-Side AI Architecture)', 'Server-Side AI Architecture')}</span>
              <span className="px-2 py-0.5 rounded text-[10px] bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                Secure
              </span>
            </h3>
            <p className="text-xs text-[#F6E9D8]/70 mt-1 max-w-2xl leading-relaxed">
              {t(
                'يتم تنفيذ طلبات التوليد وتحليل الأفكار وتوزيع الطبقات عبر Supabase Edge Functions حصرياً. مفاتيح API محمية ومخزنة في أسرار الخادم دون أي تسريب داخل كود تطبيق Flutter.',
                'AI design requests, prompt decomposition, and multi-layer synthesis run via Supabase Edge Functions. AI Provider API keys remain strictly server-side.'
              )}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2 px-3 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/20 text-xs">
          <Server className="w-4 h-4 text-[#D4AF37]" />
          <span className="text-[#F6E9D8]/80 font-mono text-[11px]">Edge: generate-design</span>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-[#F6E9D8]/70 font-medium">
              {t('معدل نجاح التوليد', 'Success Rate')}
            </span>
            <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          </div>
          <span className="text-3xl font-extrabold text-emerald-400 font-mono">
            {successRate}%
          </span>
        </div>

        <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-[#F6E9D8]/70 font-medium">
              {t('متوسط سرعة الاستجابة', 'Average Latency')}
            </span>
            <Zap className="w-4 h-4 text-[#D4AF37]" />
          </div>
          <span className="text-3xl font-extrabold gold-gradient-text font-mono">
            {avgLatency} ms
          </span>
        </div>

        <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-[#F6E9D8]/70 font-medium">
              {t('إجمالي الطلبات المسجلة', 'Total Requests')}
            </span>
            <Activity className="w-4 h-4 text-[#D4AF37]" />
          </div>
          <span className="text-3xl font-extrabold gold-gradient-text font-mono">
            {logs.length}
          </span>
        </div>
      </div>

      {/* Generation Logs Table */}
      <div className="rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 overflow-hidden">
        <div className="p-4 bg-[#0B132B]/80 border-b border-[#D4AF37]/20 flex items-center justify-between">
          <h3 className="font-bold text-xs text-[#F6E9D8] flex items-center gap-2">
            <Cpu className="w-4 h-4 text-[#D4AF37]" />
            {t('سجل نداءات محرك الذكاء الاصطناعي (ai_generation_logs)', 'AI Engine Request Stream')}
          </h3>
          <span className="text-xs font-mono text-[#D4AF37]">{logs.length} entries</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-start text-xs">
            <thead className="bg-[#0B132B]/50 text-[#D4AF37] border-b border-[#D4AF37]/15">
              <tr>
                <th className="p-4 text-start font-semibold">{t('الموجه المدخل (Prompt)', 'Input Prompt')}</th>
                <th className="p-4 text-center font-semibold">{t('القسم', 'Category')}</th>
                <th className="p-4 text-center font-semibold">{t('الزمن', 'Latency')}</th>
                <th className="p-4 text-center font-semibold">{t('الحالة', 'Status')}</th>
                <th className="p-4 text-start font-semibold">{t('التاريخ والوقت', 'Timestamp')}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#D4AF37]/10 text-[#F6E9D8]">
              {logs.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-8 text-center text-[#F6E9D8]/50">
                    {t('لا توجد سجلات بعد في جدول ai_generation_logs', 'No logs recorded in Supabase yet')}
                  </td>
                </tr>
              ) : (
                logs.map((log) => (
                  <tr key={log.id} className="hover:bg-[#16244C]/40 transition-colors">
                    <td className="p-4 font-medium text-[#F3E5AB] max-w-xs truncate">
                      «{log.prompt}»
                    </td>
                    <td className="p-4 text-center font-mono text-[11px] text-[#F6E9D8]/70">
                      {log.category_slug || 'custom'}
                    </td>
                    <td className="p-4 text-center font-mono text-[11px] text-[#D4AF37]">
                      {log.execution_time_ms ? `${log.execution_time_ms}ms` : '1.2s'}
                    </td>
                    <td className="p-4 text-center">
                      <span
                        className={`px-2 py-0.5 rounded text-[10px] font-semibold ${
                          log.success
                            ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                            : 'bg-rose-500/15 text-rose-400 border border-rose-500/30'
                        }`}
                      >
                        {log.success ? 'SUCCESS' : 'FAILED'}
                      </span>
                    </td>
                    <td className="p-4 text-[#F6E9D8]/60 text-[11px]">
                      {new Date(log.created_at).toLocaleString()}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

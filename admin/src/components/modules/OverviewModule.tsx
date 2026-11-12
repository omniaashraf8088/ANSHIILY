'use client';

import React from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { DashboardMetrics, Profile, DesignProject, AIGenerationLog } from '@/lib/types';
import { Users, Crown, Palette, FileBox, Cpu, HardDrive, ArrowUpRight, Activity } from 'lucide-react';

interface OverviewProps {
  metrics: DashboardMetrics;
  recentUsers: Profile[];
  recentDesigns: DesignProject[];
  recentAiLogs: AIGenerationLog[];
  onNavigate: (tab: string) => void;
}

export function OverviewModule({
  metrics,
  recentUsers,
  recentDesigns,
  recentAiLogs,
  onNavigate,
}: OverviewProps) {
  const { t } = useAdmin();

  const statCards = [
    {
      title: t('إجمالي المستخدمين', 'Total Users'),
      value: metrics.totalUsers,
      sub: t(`${metrics.premiumUsers} مستخدم Pro`, `${metrics.premiumUsers} Pro Members`),
      icon: Users,
      color: 'from-[#0B132B] to-[#1C2A54]',
      iconColor: 'text-[#D4AF37]',
      tab: 'users',
    },
    {
      title: t('الاشتراكات النشطة', 'Active Subscriptions'),
      value: metrics.activeSubscriptions,
      sub: t('باقات Pro المميزة', 'Pro Monthly & Yearly'),
      icon: Crown,
      color: 'from-[#7A0E2C]/80 to-[#111C3D]',
      iconColor: 'text-[#F3E5AB]',
      tab: 'subscriptions',
    },
    {
      title: t('التصاميم المنشأة', 'Generated Designs'),
      value: metrics.totalDesigns,
      sub: t('بواسطة محرك AI والـ Canvas', 'Via AI Engine & Canvas'),
      icon: Palette,
      color: 'from-[#0B132B] to-[#16244C]',
      iconColor: 'text-[#D4AF37]',
      tab: 'designs',
    },
    {
      title: t('مكتبة القوالب', 'Template Library'),
      value: metrics.totalTemplates,
      sub: t(`ضمن ${metrics.totalCategories} أقسام رئيسية`, `Across ${metrics.totalCategories} Categories`),
      icon: FileBox,
      color: 'from-[#111C3D] to-[#1C2A54]',
      iconColor: 'text-[#D4AF37]',
      tab: 'templates',
    },
    {
      title: t('عمليات الذكاء الاصطناعي', 'AI Generation Requests'),
      value: metrics.totalAiGenerations,
      sub: t('محرك Edge Function', 'Supabase Edge Runtime'),
      icon: Cpu,
      color: 'from-[#7A0E2C]/50 to-[#0B132B]',
      iconColor: 'text-[#F3E5AB]',
      tab: 'ai_analytics',
    },
    {
      title: t('أحواض التخزين السحابي', 'Storage Buckets'),
      value: metrics.storageBucketsCount,
      sub: t('5 أحواض جاهزة', '5 Buckets Configured'),
      icon: HardDrive,
      color: 'from-[#0B132B] to-[#111C3D]',
      iconColor: 'text-[#D4AF37]',
      tab: 'storage',
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="p-6 rounded-2xl bg-gradient-to-r from-[#111C3D] via-[#16244C] to-[#7A0E2C]/40 border border-[#D4AF37]/30 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1.5">
            <span className="px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-[#D4AF37]/20 text-[#F3E5AB] border border-[#D4AF37]/40 uppercase tracking-wider">
              {t('النظام متصل', 'System Online')}
            </span>
            <span className="text-xs text-[#F6E9D8]/70">Supabase: wwfhoogtnwyavyvuabbw</span>
          </div>
          <h2 className="text-2xl font-bold text-[#F6E9D8]">
            {t('مرحباً بك في لوحة تحكم أنشئلي المركزية', 'Welcome to ANSHIILY Master Admin')}
          </h2>
          <p className="text-sm text-[#F6E9D8]/70 mt-1 max-w-2xl">
            {t(
              'إدارة موحدة للمستخدمين، القوالب، التصاميم الذكية، الاشتراكات ومحركات التوليد عبر السحابة.',
              'Unified management for users, templates, AI design engine, subscriptions and cloud infrastructure.'
            )}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={() => onNavigate('templates')}
            className="px-4 py-2 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#AA8C2C] text-[#0B132B] font-bold text-xs shadow-lg shadow-[#D4AF37]/20 hover:brightness-110 transition-all flex items-center gap-1.5"
          >
            <span>{t('إضافة قالب جديد', 'Add New Template')}</span>
            <ArrowUpRight className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {statCards.map((card, idx) => {
          const Icon = card.icon;
          return (
            <div
              key={idx}
              onClick={() => onNavigate(card.tab)}
              className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 hover:border-[#D4AF37]/50 transition-all duration-300 hover:shadow-xl hover:shadow-[#D4AF37]/5 cursor-pointer group"
            >
              <div className="flex items-center justify-between mb-3">
                <span className="text-xs font-medium text-[#F6E9D8]/70">{card.title}</span>
                <div className="w-9 h-9 rounded-xl bg-[#0B132B] border border-[#D4AF37]/25 flex items-center justify-center group-hover:scale-110 transition-transform">
                  <Icon className={`w-4 h-4 ${card.iconColor}`} />
                </div>
              </div>
              <div className="flex items-baseline justify-between">
                <span className="text-3xl font-extrabold gold-gradient-text font-mono">
                  {card.value}
                </span>
                <span className="text-[11px] text-[#F6E9D8]/50">{card.sub}</span>
              </div>
            </div>
          );
        })}
      </div>

      {/* Recent Activity Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Designs */}
        <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20">
          <div className="flex items-center justify-between mb-4 pb-3 border-b border-[#D4AF37]/15">
            <h3 className="font-bold text-sm text-[#F6E9D8] flex items-center gap-2">
              <Palette className="w-4 h-4 text-[#D4AF37]" />
              {t('أحدث التصاميم المنشأة', 'Latest Generated Designs')}
            </h3>
            <button
              onClick={() => onNavigate('designs')}
              className="text-xs text-[#D4AF37] hover:underline"
            >
              {t('عرض الكل', 'View All')}
            </button>
          </div>
          <div className="space-y-3">
            {recentDesigns.length === 0 ? (
              <p className="text-xs text-[#F6E9D8]/50 text-center py-6">
                {t('لا توجد تصاميم حديثة بعد', 'No recent designs yet')}
              </p>
            ) : (
              recentDesigns.slice(0, 4).map((d) => (
                <div
                  key={d.id}
                  className="p-3 rounded-xl bg-[#0B132B]/60 border border-[#D4AF37]/10 flex items-center justify-between text-xs"
                >
                  <div className="flex-1 min-w-0 me-3">
                    <p className="font-semibold text-[#F6E9D8] truncate">{d.title}</p>
                    <p className="text-[11px] text-[#F6E9D8]/50 truncate">{d.prompt}</p>
                  </div>
                  <span className="px-2 py-0.5 rounded text-[10px] bg-[#D4AF37]/15 text-[#F3E5AB] border border-[#D4AF37]/30 shrink-0">
                    {d.status}
                  </span>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Recent AI Generation Logs */}
        <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20">
          <div className="flex items-center justify-between mb-4 pb-3 border-b border-[#D4AF37]/15">
            <h3 className="font-bold text-sm text-[#F6E9D8] flex items-center gap-2">
              <Activity className="w-4 h-4 text-[#D4AF37]" />
              {t('سجل عمليات الذكاء الاصطناعي', 'AI Generation Activity')}
            </h3>
            <button
              onClick={() => onNavigate('ai_analytics')}
              className="text-xs text-[#D4AF37] hover:underline"
            >
              {t('عرض السجل', 'View Logs')}
            </button>
          </div>
          <div className="space-y-3">
            {recentAiLogs.length === 0 ? (
              <p className="text-xs text-[#F6E9D8]/50 text-center py-6">
                {t('لا توجد عمليات مسجلة حديثاً', 'No recent AI generation logs')}
              </p>
            ) : (
              recentAiLogs.slice(0, 4).map((log) => (
                <div
                  key={log.id}
                  className="p-3 rounded-xl bg-[#0B132B]/60 border border-[#D4AF37]/10 flex items-center justify-between text-xs"
                >
                  <div className="flex-1 min-w-0 me-3">
                    <p className="font-mono text-[#F3E5AB] truncate">{log.prompt}</p>
                    <p className="text-[10px] text-[#F6E9D8]/40">
                      {log.execution_time_ms ? `${log.execution_time_ms}ms` : 'fast'} |{' '}
                      {new Date(log.created_at).toLocaleTimeString()}
                    </p>
                  </div>
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-medium ${
                      log.success
                        ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                        : 'bg-rose-500/15 text-rose-400 border border-rose-500/30'
                    }`}
                  >
                    {log.success ? 'Success' : 'Failed'}
                  </span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}


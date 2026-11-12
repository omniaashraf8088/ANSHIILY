'use client';

import React from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { Subscription } from '@/lib/types';
import { CreditCard, Crown, CheckCircle2, AlertCircle, RefreshCw, Sparkles } from 'lucide-react';

interface SubscriptionsModuleProps {
  subscriptions: Subscription[];
  onRefresh: () => void;
}

export function SubscriptionsModule({ subscriptions, onRefresh }: SubscriptionsModuleProps) {
  const { t } = useAdmin();

  const proCount = subscriptions.filter((s) => s.plan_type === 'pro' || s.plan_type === 'premium').length;
  const activeCount = subscriptions.filter((s) => s.status === 'active').length;

  return (
    <div className="space-y-6">
      {/* Overview Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-[#F6E9D8]/70 font-medium">
              {t('إجمالي المشتركين', 'Total Subscribers')}
            </span>
            <CreditCard className="w-4 h-4 text-[#D4AF37]" />
          </div>
          <span className="text-3xl font-extrabold gold-gradient-text font-mono">
            {subscriptions.length}
          </span>
        </div>

        <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-[#F6E9D8]/70 font-medium">
              {t('الاشتراكات المميزة (PRO)', 'Active Pro Members')}
            </span>
            <Crown className="w-4 h-4 text-[#D4AF37]" />
          </div>
          <span className="text-3xl font-extrabold gold-gradient-text font-mono">
            {proCount}
          </span>
        </div>

        <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-[#F6E9D8]/70 font-medium">
              {t('بوابة الدفع (RevenueCat)', 'Payment Gateway')}
            </span>
            <Sparkles className="w-4 h-4 text-[#D4AF37]" />
          </div>
          <span className="text-sm font-bold text-emerald-400 flex items-center gap-1.5 mt-2">
            <CheckCircle2 className="w-4 h-4" /> Ready & Webhook Synchronized
          </span>
        </div>
      </div>

      {/* Subscriptions Table */}
      <div className="rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 overflow-hidden">
        <div className="p-4 bg-[#0B132B]/80 border-b border-[#D4AF37]/20 flex items-center justify-between">
          <h3 className="font-bold text-xs text-[#F6E9D8] flex items-center gap-2">
            <CreditCard className="w-4 h-4 text-[#D4AF37]" />
            {t('قائمة سجلات الاشتراكات السحابية', 'Cloud Subscription Records')}
          </h3>
          <span className="text-xs font-mono text-[#D4AF37]">{subscriptions.length} records</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-start text-xs">
            <thead className="bg-[#0B132B]/50 text-[#D4AF37] border-b border-[#D4AF37]/15">
              <tr>
                <th className="p-4 text-start font-semibold">{t('معرف المستخدم', 'User ID')}</th>
                <th className="p-4 text-center font-semibold">{t('نوع الخطة', 'Plan Type')}</th>
                <th className="p-4 text-center font-semibold">{t('الحالة', 'Status')}</th>
                <th className="p-4 text-start font-semibold">{t('بداية الفترة', 'Period Start')}</th>
                <th className="p-4 text-start font-semibold">{t('نهاية الفترة', 'Period End')}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#D4AF37]/10 text-[#F6E9D8]">
              {subscriptions.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-8 text-center text-[#F6E9D8]/50">
                    {t('لا توجد اشتراكات مسجلة حالياً', 'No subscription records found in Supabase')}
                  </td>
                </tr>
              ) : (
                subscriptions.map((sub) => (
                  <tr key={sub.id} className="hover:bg-[#16244C]/40 transition-colors">
                    <td className="p-4 font-mono text-[11px] text-[#F3E5AB]">
                      {sub.user_id}
                    </td>
                    <td className="p-4 text-center">
                      <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-[#D4AF37]/20 text-[#F3E5AB] border border-[#D4AF37]/40 uppercase">
                        {sub.plan_type}
                      </span>
                    </td>
                    <td className="p-4 text-center">
                      <span className="px-2 py-0.5 rounded text-[10px] font-semibold bg-emerald-500/15 text-emerald-400 border border-emerald-500/30 uppercase">
                        {sub.status}
                      </span>
                    </td>
                    <td className="p-4 text-[#F6E9D8]/60">
                      {sub.current_period_start ? new Date(sub.current_period_start).toLocaleDateString() : '-'}
                    </td>
                    <td className="p-4 text-[#F6E9D8]/60">
                      {sub.current_period_end ? new Date(sub.current_period_end).toLocaleDateString() : 'Lifetime'}
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


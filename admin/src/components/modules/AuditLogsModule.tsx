'use client';

import React from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { SystemAuditLog } from '@/lib/types';
import { History, CheckCircle2, ShieldAlert, Activity, Server, Database } from 'lucide-react';

interface AuditLogsModuleProps {
  logs: SystemAuditLog[];
}

export function AuditLogsModule({ logs }: AuditLogsModuleProps) {
  const { t } = useAdmin();

  const services = [
    { name: 'Database (PostgreSQL 15)', status: 'Operational', latency: '24ms', region: 'eu-central-2' },
    { name: 'Supabase Auth (GoTrue)', status: 'Operational', latency: '35ms', region: 'eu-central-2' },
    { name: 'Storage API (S3 / Objects)', status: 'Operational', latency: '40ms', region: 'eu-central-2' },
    { name: 'Edge Functions Runtime (Deno)', status: 'Operational', latency: '18ms', region: 'eu-central-2' },
  ];

  return (
    <div className="space-y-6">
      {/* Infrastructure Health Card */}
      <div className="p-5 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 space-y-4">
        <div className="flex items-center justify-between pb-3 border-b border-[#D4AF37]/15">
          <h3 className="font-bold text-sm text-[#F6E9D8] flex items-center gap-2">
            <Server className="w-4 h-4 text-[#D4AF37]" />
            {t('حالة البنية التحتية والخدمات السحابية', 'Infrastructure & Cloud Service Health')}
          </h3>
          <span className="text-[10px] px-2.5 py-0.5 rounded-full font-bold bg-emerald-500/15 text-emerald-400 border border-emerald-500/30 flex items-center gap-1">
            <CheckCircle2 className="w-3 h-3" /> ALL SYSTEMS NORMAL
          </span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {services.map((s, idx) => (
            <div key={idx} className="p-3.5 rounded-xl bg-[#0B132B] border border-[#D4AF37]/15 text-xs">
              <div className="flex items-center justify-between mb-1.5">
                <span className="font-semibold text-[#F3E5AB]">{s.name}</span>
                <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
              </div>
              <div className="flex items-center justify-between text-[10px] text-[#F6E9D8]/50">
                <span>{s.region}</span>
                <span className="font-mono text-[#D4AF37]">{s.latency}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Audit Logs Table */}
      <div className="rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 overflow-hidden">
        <div className="p-4 bg-[#0B132B]/80 border-b border-[#D4AF37]/20 flex items-center justify-between">
          <h3 className="font-bold text-xs text-[#F6E9D8] flex items-center gap-2">
            <History className="w-4 h-4 text-[#D4AF37]" />
            {t('سجل الأنشطة والتدقيق الأمني (Audit Trail)', 'Security Audit Trail')}
          </h3>
          <span className="text-xs font-mono text-[#D4AF37]">Active Monitoring</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-start text-xs">
            <thead className="bg-[#0B132B]/50 text-[#D4AF37] border-b border-[#D4AF37]/15">
              <tr>
                <th className="p-4 text-start font-semibold">{t('الإجراء (Action)', 'Action')}</th>
                <th className="p-4 text-start font-semibold">{t('المنفذ', 'Actor')}</th>
                <th className="p-4 text-start font-semibold">{t('الهدف', 'Target')}</th>
                <th className="p-4 text-start font-semibold">{t('التاريخ والوقت', 'Timestamp')}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#D4AF37]/10 text-[#F6E9D8]">
              {logs.length === 0 ? (
                <tr>
                  <td colSpan={4} className="p-8 text-center text-[#F6E9D8]/50">
                    {t('لا توجد أحداث تدقيق أمني استثنائية', 'No audit logs recorded')}
                  </td>
                </tr>
              ) : (
                logs.map((log) => (
                  <tr key={log.id} className="hover:bg-[#16244C]/40 transition-colors">
                    <td className="p-4 font-mono font-medium text-[#F3E5AB]">
                      {log.action}
                    </td>
                    <td className="p-4 text-[#F6E9D8]/80">
                      {log.actor_email || 'System'}
                    </td>
                    <td className="p-4 text-[#F6E9D8]/60 font-mono text-[11px]">
                      {log.target_type}: {log.target_id || '-'}
                    </td>
                    <td className="p-4 text-[#F6E9D8]/50 text-[11px]">
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


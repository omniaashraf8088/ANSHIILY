'use client';

import React from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { Shield, ShieldAlert, Check, X, Users, Lock } from 'lucide-react';
import { AdminRole } from '@/lib/types';

export function AdminTeamModule() {
  const { t, currentRole } = useAdmin();

  const roleDefinitions: {
    role: AdminRole;
    nameAr: string;
    nameEn: string;
    color: string;
    descAr: string;
    descEn: string;
    permissions: string[];
  }[] = [
    {
      role: 'SUPER_ADMIN',
      nameAr: 'المشرف العام (Super Admin)',
      nameEn: 'Super Administrator',
      color: 'border-[#D4AF37] bg-[#D4AF37]/15 text-[#F3E5AB]',
      descAr: 'تحكم مطلق في النظام، إدارة الصلاحيات، الحذف النهائي، والاتصال بالسحابة',
      descEn: 'Full system control, permissions, permanent deletions, and billing configuration',
      permissions: ['Manage Admins', 'Delete Records', 'Edit Schemas', 'View Revenue', 'Adjust Credits', 'Manage Templates'],
    },
    {
      role: 'ADMIN',
      nameAr: 'مدير النظام (Admin)',
      nameEn: 'Administrator',
      color: 'border-sky-500/50 bg-sky-500/15 text-sky-300',
      descAr: 'إدارة المستخدمين، متابعة التخزين، نشر القوالب، واعتماد الاشتراكات',
      descEn: 'User moderation, storage management, template approvals, and support oversight',
      permissions: ['Manage Users', 'Adjust Credits', 'Manage Templates', 'Inspect Storage', 'Audit Logs'],
    },
    {
      role: 'CONTENT_MANAGER',
      nameAr: 'مدير المحتوى (Content Manager)',
      nameEn: 'Content Manager',
      color: 'border-emerald-500/50 bg-emerald-500/15 text-emerald-300',
      descAr: 'إضافة وتعديل التصنيفات والقوالب وبناء مكتبة التصاميم الجاهزة',
      descEn: 'Create & edit categories, build template library, inspect canvas layers',
      permissions: ['Manage Categories', 'Create Templates', 'Edit Template JSON', 'View Designs'],
    },
    {
      role: 'SUPPORT',
      nameAr: 'الدعم الفني (Support Agent)',
      nameEn: 'Customer Support',
      color: 'border-amber-500/50 bg-amber-500/15 text-amber-300',
      descAr: 'البحث عن حسابات المستخدمين، حل المشاكل التقنية، ومنح رصيد تعويضي',
      descEn: 'Search user profiles, diagnose design errors, grant promotional credits',
      permissions: ['View Users', 'Grant Credits', 'View Generation Logs', 'Check Export Jobs'],
    },
    {
      role: 'ANALYST',
      nameAr: 'محلل البيانات (Data Analyst)',
      nameEn: 'Business Analyst',
      color: 'border-purple-500/50 bg-purple-500/15 text-purple-300',
      descAr: 'قراءة تقارير الذكاء الاصطناعي، معدلات التحويل، ونمو الاشتراكات بدون تعديل',
      descEn: 'Read-only access to metrics, generation logs, and subscription analytics',
      permissions: ['View KPIs', 'Analyze AI Prompts', 'Subscription Reports', 'Export CSV Data'],
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="p-4 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 flex items-center justify-between">
        <div>
          <h3 className="font-bold text-sm text-[#F6E9D8] flex items-center gap-2">
            <Shield className="w-4 h-4 text-[#D4AF37]" />
            {t('مصفوفة الصلاحيات وفريق الإدارة', 'Role-Based Access Control (RBAC)')}
          </h3>
          <p className="text-xs text-[#F6E9D8]/60 mt-0.5">
            {t(
              'مستويات الحماية والوصول لـ 5 أدوار مختلفة مع تشفير الاتصال',
              'Enterprise 5-tier access control matrix protecting sensitive Supabase operations'
            )}
          </p>
        </div>
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-xs">
          <span className="text-[#F6E9D8]/70">{t('دورك الحالي:', 'Your Role:')}</span>
          <span className="font-bold text-[#D4AF37]">{currentRole}</span>
        </div>
      </div>

      {/* Role Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {roleDefinitions.map((rd) => {
          const isCurrent = currentRole === rd.role;
          return (
            <div
              key={rd.role}
              className={`p-5 rounded-2xl bg-[#111C3D]/80 border transition-all flex flex-col justify-between ${
                isCurrent ? 'border-[#D4AF37] shadow-lg shadow-[#D4AF37]/10' : 'border-[#D4AF37]/20'
              }`}
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <span className={`text-[10px] px-2.5 py-0.5 rounded-full font-bold border ${rd.color}`}>
                    {rd.role}
                  </span>
                  {isCurrent && (
                    <span className="text-[10px] font-bold text-[#D4AF37] flex items-center gap-1">
                      <Check className="w-3 h-3" /> ACTIVE
                    </span>
                  )}
                </div>
                <h4 className="font-bold text-sm text-[#F6E9D8] mb-1">
                  {t(rd.nameAr, rd.nameEn)}
                </h4>
                <p className="text-xs text-[#F6E9D8]/60 leading-relaxed mb-4">
                  {t(rd.descAr, rd.descEn)}
                </p>
              </div>

              <div className="pt-3 border-t border-[#D4AF37]/10">
                <p className="text-[10px] uppercase font-mono text-[#D4AF37] mb-2">
                  {t('الصلاحيات الممنوحة:', 'Granted Permissions:')}
                </p>
                <div className="flex flex-wrap gap-1.5">
                  {rd.permissions.map((p, idx) => (
                    <span
                      key={idx}
                      className="text-[10px] px-2 py-0.5 rounded bg-[#0B132B] text-[#F6E9D8]/80 border border-[#D4AF37]/15"
                    >
                      {p}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

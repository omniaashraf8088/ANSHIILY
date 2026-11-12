'use client';

import React from 'react';
import { useRouter } from 'next/navigation';
import { useAdmin } from '@/lib/context/AdminContext';
import { AdminRole } from '@/lib/types';
import { createClient } from '@/lib/supabase/client';
import { Globe, Shield, RefreshCw, LogOut, Info } from 'lucide-react';

interface HeaderProps {
  onRefresh?: () => void;
  isRefreshing?: boolean;
}

export function Header({ onRefresh, isRefreshing }: HeaderProps) {
  const router = useRouter();
  const supabase = createClient();
  const { lang, setLang, t, currentRole, setCurrentRole, currentUser } = useAdmin();

  const roles: { id: AdminRole; label: string }[] = [
    { id: 'SUPER_ADMIN', label: 'Super Admin (المشرف العام)' },
    { id: 'ADMIN', label: 'Admin (مدير النظام)' },
    { id: 'CONTENT_MANAGER', label: 'Content Manager (مدير المحتوى)' },
    { id: 'SUPPORT', label: 'Support (الدعم الفني)' },
    { id: 'ANALYST', label: 'Analyst (محلل البيانات)' },
  ];

  const handleSignOut = async () => {
    try {
      await supabase.auth.signOut();
    } catch (_) {}
    router.push('/login');
  };

  return (
    <header className="h-16 bg-[#0B132B]/95 backdrop-blur border-b border-[#D4AF37]/20 px-6 flex items-center justify-between sticky top-0 z-40">
      {/* Brand & Slogan */}
      <div className="flex items-center gap-3">
        <span className="text-xs uppercase tracking-widest text-[#D4AF37]/80 font-mono hidden md:inline">
          {t('من فكرة إلى تصميم', 'From Idea to Design')}
        </span>
      </div>

      {/* Controls & Actions */}
      <div className="flex items-center gap-3">
        {/* Refresh button */}
        {onRefresh && (
          <button
            onClick={onRefresh}
            disabled={isRefreshing}
            title={t('تحديث البيانات', 'Refresh Data')}
            className="p-2 rounded-lg bg-[#111C3D] border border-[#D4AF37]/20 text-[#F6E9D8] hover:text-[#D4AF37] hover:border-[#D4AF37]/50 transition-all"
          >
            <RefreshCw className={`w-4 h-4 ${isRefreshing ? 'animate-spin text-[#D4AF37]' : ''}`} />
          </button>
        )}

        {/* UI Role Simulator Indicator */}
        <div className="flex items-center gap-2 bg-[#111C3D] px-3 py-1.5 rounded-lg border border-[#D4AF37]/30 text-xs">
          <div className="flex items-center gap-1 text-[10px] text-[#D4AF37] font-semibold">
            <Shield className="w-3.5 h-3.5" />
            <span className="hidden xl:inline">{t('محاكاة العرض:', 'UI Simulator:')}</span>
          </div>
          <select
            value={currentRole}
            onChange={(e) => setCurrentRole(e.target.value as AdminRole)}
            className="bg-transparent text-[#F6E9D8] focus:outline-none cursor-pointer text-xs font-medium"
            title={t(
              'تغيير الدور لتجربة الصلاحيات البصرية في لوحة التحكم (لا يمنح صلاحيات خادم)',
              'Switch role to preview UI visibility. Does not bypass server RLS.'
            )}
          >
            {roles.map((r) => (
              <option key={r.id} value={r.id} className="bg-[#0B132B] text-[#F6E9D8]">
                {r.label}
              </option>
            ))}
          </select>
        </div>

        {/* Language Switcher */}
        <button
          onClick={() => setLang(lang === 'ar' ? 'en' : 'ar')}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#111C3D] border border-[#D4AF37]/20 text-xs font-medium text-[#F6E9D8] hover:border-[#D4AF37]/50 transition-all"
        >
          <Globe className="w-3.5 h-3.5 text-[#D4AF37]" />
          <span>{lang === 'ar' ? 'English' : 'العربية'}</span>
        </button>

        {/* Sign Out Button */}
        <button
          onClick={handleSignOut}
          title={t('تسجيل الخروج', 'Sign Out')}
          className="p-2 rounded-lg bg-[#111C3D] border border-rose-500/30 text-rose-300 hover:bg-rose-500/20 transition-all flex items-center gap-1"
        >
          <LogOut className="w-4 h-4" />
        </button>
      </div>
    </header>
  );
}

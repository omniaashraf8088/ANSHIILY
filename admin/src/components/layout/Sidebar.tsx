'use client';

import React from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import {
  LayoutDashboard,
  Users,
  FolderTree,
  FileBox,
  Palette,
  CreditCard,
  Cpu,
  HardDrive,
  ShieldAlert,
  History,
  Sparkles,
} from 'lucide-react';

interface SidebarProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export function Sidebar({ activeTab, setActiveTab }: SidebarProps) {
  const { t, currentRole } = useAdmin();

  const navItems = [
    {
      id: 'overview',
      nameAr: 'نظرة عامة',
      nameEn: 'Dashboard Overview',
      icon: LayoutDashboard,
      roles: ['SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER', 'SUPPORT', 'ANALYST'],
    },
    {
      id: 'users',
      nameAr: 'إدارة المستخدمين',
      nameEn: 'Users Management',
      icon: Users,
      roles: ['SUPER_ADMIN', 'ADMIN', 'SUPPORT'],
    },
    {
      id: 'categories',
      nameAr: 'أقسام التصاميم',
      nameEn: 'Design Categories',
      icon: FolderTree,
      roles: ['SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER'],
    },
    {
      id: 'templates',
      nameAr: 'مكتبة القوالب',
      nameEn: 'Template Library',
      icon: FileBox,
      roles: ['SUPER_ADMIN', 'ADMIN', 'CONTENT_MANAGER'],
    },
    {
      id: 'designs',
      nameAr: 'مشاريع المستخدمين',
      nameEn: 'User Projects & Layers',
      icon: Palette,
      roles: ['SUPER_ADMIN', 'ADMIN', 'SUPPORT', 'ANALYST'],
    },
    {
      id: 'subscriptions',
      nameAr: 'الاشتراكات والفوترة',
      nameEn: 'Subscriptions & Revenue',
      icon: CreditCard,
      roles: ['SUPER_ADMIN', 'ADMIN', 'ANALYST'],
    },
    {
      id: 'ai_analytics',
      nameAr: 'محرك الذكاء الاصطناعي',
      nameEn: 'AI Design Analytics',
      icon: Cpu,
      roles: ['SUPER_ADMIN', 'ADMIN', 'ANALYST'],
    },
    {
      id: 'storage',
      nameAr: 'الملفات والتخزين',
      nameEn: 'Storage & Assets',
      icon: HardDrive,
      roles: ['SUPER_ADMIN', 'ADMIN'],
    },
    {
      id: 'admin_team',
      nameAr: 'صلاحيات الإدارة',
      nameEn: 'Admin Roles & Access',
      icon: ShieldAlert,
      roles: ['SUPER_ADMIN'],
    },
    {
      id: 'audit_logs',
      nameAr: 'سجل تدقيق النظام',
      nameEn: 'Audit & System Health',
      icon: History,
      roles: ['SUPER_ADMIN', 'ADMIN'],
    },
  ];

  return (
    <aside className="w-64 bg-[#0B132B] border-r border-[#D4AF37]/20 flex flex-col h-screen sticky top-0 select-none">
      {/* Brand Header */}
      <div className="p-6 border-b border-[#D4AF37]/15 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#D4AF37] to-[#7A0E2C] flex items-center justify-center shadow-lg shadow-[#D4AF37]/20">
            <Sparkles className="w-5 h-5 text-[#0B132B]" />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-wider gold-gradient-text">
              ANSHIILY
            </h1>
            <p className="text-xs text-[#D4AF37]/70 font-medium">أنشئلي | لوحة الإدارة</p>
          </div>
        </div>
      </div>

      {/* Nav Menu */}
      <nav className="flex-1 overflow-y-auto p-4 space-y-1.5">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          const isAllowed = item.roles.includes(currentRole);

          if (!isAllowed) return null;

          return (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={`w-full flex items-center gap-3.5 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200 ${
                isActive
                  ? 'bg-gradient-to-r from-[#D4AF37]/20 to-[#7A0E2C]/20 text-[#F3E5AB] border border-[#D4AF37]/40 shadow-md shadow-[#D4AF37]/5'
                  : 'text-[#F6E9D8]/70 hover:text-[#F3E5AB] hover:bg-[#16244C]/60'
              }`}
            >
              <Icon
                className={`w-4 h-4 transition-colors ${
                  isActive ? 'text-[#D4AF37]' : 'text-[#F6E9D8]/50'
                }`}
              />
              <span className="flex-1 text-start">
                {t(item.nameAr, item.nameEn)}
              </span>
            </button>
          );
        })}
      </nav>

      {/* Environment & Backend Indicator */}
      <div className="p-4 m-3 rounded-xl bg-[#111C3D] border border-[#D4AF37]/20">
        <div className="flex items-center justify-between text-xs mb-1">
          <span className="text-[#D4AF37] font-semibold">Supabase Cloud</span>
          <span className="flex h-2 w-2 relative">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
          </span>
        </div>
        <p className="text-[11px] text-[#F6E9D8]/60 font-mono truncate">wwfhoogtnwyavyvuabbw</p>
      </div>
    </aside>
  );
}


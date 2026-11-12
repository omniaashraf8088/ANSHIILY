'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { AdminRole, AdminUser } from '@/lib/types';

interface AdminContextType {
  lang: 'ar' | 'en';
  setLang: (lang: 'ar' | 'en') => void;
  dir: 'rtl' | 'ltr';
  t: (arText: string, enText: string) => string;
  currentRole: AdminRole;
  setCurrentRole: (role: AdminRole) => void;
  currentUser: AdminUser;
  hasPermission: (requiredRole: AdminRole[]) => boolean;
}

const defaultAdminUser: AdminUser = {
  id: 'admin-super-001',
  email: 'admin@anshiily.com',
  role: 'SUPER_ADMIN',
  created_at: new Date().toISOString(),
};

const roleHierarchy: Record<AdminRole, number> = {
  SUPER_ADMIN: 5,
  ADMIN: 4,
  CONTENT_MANAGER: 3,
  SUPPORT: 2,
  ANALYST: 1,
};

const AdminContext = createContext<AdminContextType | undefined>(undefined);

export function AdminProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLangState] = useState<'ar' | 'en'>('ar');
  const [currentRole, setCurrentRole] = useState<AdminRole>('SUPER_ADMIN');

  useEffect(() => {
    const saved = localStorage.getItem('anshiily_admin_lang');
    if (saved === 'ar' || saved === 'en') {
      setLangState(saved);
    }
  }, []);

  const setLang = (newLang: 'ar' | 'en') => {
    setLangState(newLang);
    localStorage.setItem('anshiily_admin_lang', newLang);
  };

  const dir = lang === 'ar' ? 'rtl' : 'ltr';

  const t = (arText: string, enText: string) => (lang === 'ar' ? arText : enText);

  const hasPermission = (allowedRoles: AdminRole[]) => {
    return allowedRoles.includes(currentRole);
  };

  const currentUser: AdminUser = {
    ...defaultAdminUser,
    role: currentRole,
  };

  return (
    <AdminContext.Provider
      value={{
        lang,
        setLang,
        dir,
        t,
        currentRole,
        setCurrentRole,
        currentUser,
        hasPermission,
      }}
    >
      <div dir={dir} className={lang === 'ar' ? 'font-arabic' : 'font-sans'}>
        {children}
      </div>
    </AdminContext.Provider>
  );
}

export function useAdmin() {
  const context = useContext(AdminContext);
  if (!context) {
    throw new Error('useAdmin must be used within an AdminProvider');
  }
  return context;
}


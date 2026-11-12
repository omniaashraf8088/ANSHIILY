import type { Metadata } from 'next';
import './globals.css';
import { AdminProvider } from '@/lib/context/AdminContext';

export const metadata: Metadata = {
  title: 'ANSHIILY | أنشئلي - لوحة الإدارة المركزية',
  description: 'Master Admin Dashboard for ANSHIILY AI Graphic Design Platform - Supabase, Cloud Storage & Multi-tenant Management',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl" className="h-full">
      <body className="min-h-full bg-[#0B132B] text-[#F6E9D8]">
        <AdminProvider>{children}</AdminProvider>
      </body>
    </html>
  );
}

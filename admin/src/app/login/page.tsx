'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Sparkles, Shield, Lock, Mail, ArrowRight, ArrowLeft } from 'lucide-react';

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;
    setLoading(true);
    setErrorMsg(null);

    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email: email.trim(),
        password,
      });

      if (error) {
        setErrorMsg(error.message);
      } else if (data.session) {
        router.push('/');
      }
    } catch (err: any) {
      setErrorMsg(err.message || 'فشل تسجيل الدخول');
    } finally {
      setLoading(false);
    }
  };

  const handleDemoAccess = () => {
    router.push('/?demo=true');
  };

  return (
    <div className="min-h-screen bg-[#0B132B] flex flex-col justify-center items-center p-6 relative overflow-hidden select-none">
      {/* Background Glows */}
      <div className="absolute top-1/4 start-1/4 w-96 h-96 bg-[#D4AF37]/5 rounded-full blur-3xl pointer-events-none"></div>
      <div className="absolute bottom-1/4 end-1/4 w-96 h-96 bg-[#7A0E2C]/10 rounded-full blur-3xl pointer-events-none"></div>

      {/* Main Login Card */}
      <div className="w-full max-w-md bg-[#111C3D]/90 border border-[#D4AF37]/30 rounded-3xl p-8 shadow-2xl backdrop-blur relative z-10">
        {/* Brand Header */}
        <div className="flex flex-col items-center text-center mb-8">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-[#D4AF37] to-[#7A0E2C] flex items-center justify-center shadow-xl shadow-[#D4AF37]/20 mb-3">
            <Sparkles className="w-7 h-7 text-[#0B132B]" />
          </div>
          <h1 className="text-2xl font-extrabold gold-gradient-text tracking-wider">
            ANSHIILY | أنشئلي
          </h1>
          <p className="text-xs text-[#D4AF37]/80 mt-1 font-medium">
            لوحة الإدارة والتحكم السحابية المركزية
          </p>
        </div>

        {/* Error Alert */}
        {errorMsg && (
          <div className="mb-4 p-3 rounded-xl bg-rose-500/15 border border-rose-500/30 text-rose-300 text-xs text-center font-medium">
            {errorMsg}
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-[#F6E9D8]/80 mb-1.5 text-start">
              البريد الإلكتروني للإدارة (Admin Email)
            </label>
            <div className="relative">
              <Mail className="w-4 h-4 text-[#D4AF37]/60 absolute start-3 top-1/2 -translate-y-1/2" />
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@anshiily.com"
                className="w-full ps-10 pe-4 py-2.5 rounded-xl bg-[#0B132B] border border-[#D4AF37]/25 text-xs text-[#F6E9D8] placeholder-[#F6E9D8]/30 focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#F6E9D8]/80 mb-1.5 text-start">
              كلمة المرور (Password)
            </label>
            <div className="relative">
              <Lock className="w-4 h-4 text-[#D4AF37]/60 absolute start-3 top-1/2 -translate-y-1/2" />
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full ps-10 pe-4 py-2.5 rounded-xl bg-[#0B132B] border border-[#D4AF37]/25 text-xs text-[#F6E9D8] placeholder-[#F6E9D8]/30 focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#AA8C2C] text-[#0B132B] font-bold text-xs shadow-lg shadow-[#D4AF37]/20 hover:brightness-110 transition-all flex items-center justify-center gap-2 mt-2"
          >
            <span>{loading ? 'جار التحقق من الصلاحيات...' : 'تسجيل الدخول إلى لوحة التحكم'}</span>
            <ArrowLeft className="w-4 h-4" />
          </button>
        </form>

        {/* Demo / Sandbox Access Button */}
        <div className="pt-6 mt-6 border-t border-[#D4AF37]/15 text-center">
          <p className="text-[11px] text-[#F6E9D8]/50 mb-3">
            للمعاينة واختبار الواجهات والتصاميم في بيئة العرض:
          </p>
          <button
            onClick={handleDemoAccess}
            className="w-full py-2.5 rounded-xl bg-[#0B132B] border border-[#D4AF37]/30 text-[#F3E5AB] text-xs font-semibold hover:border-[#D4AF37] transition-all flex items-center justify-center gap-1.5"
          >
            <Shield className="w-3.5 h-3.5 text-[#D4AF37]" />
            <span>الدخول بوضع المحاكاة الاستعراضي (Demo Mode)</span>
          </button>
        </div>
      </div>
    </div>
  );
}

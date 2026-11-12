'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { Profile } from '@/lib/types';
import { createClient } from '@/lib/supabase/client';
import { Search, Crown, Plus, Minus, UserCheck, Shield, Sparkles } from 'lucide-react';

interface UsersModuleProps {
  users: Profile[];
  onRefresh: () => void;
}

export function UsersModule({ users, onRefresh }: UsersModuleProps) {
  const { t, hasPermission, currentUser } = useAdmin();
  const [searchTerm, setSearchTerm] = useState('');
  const [isUpdating, setIsUpdating] = useState<string | null>(null);

  const canEdit = hasPermission(['SUPER_ADMIN', 'ADMIN']);
  const supabase = createClient();

  const filteredUsers = users.filter((u) => {
    const term = searchTerm.toLowerCase();
    return (
      u.full_name?.toLowerCase().includes(term) ||
      u.username?.toLowerCase().includes(term) ||
      u.id.toLowerCase().includes(term)
    );
  });

  const handleAdjustCredits = async (userId: string, currentCredits: number, delta: number) => {
    if (!canEdit) return;
    setIsUpdating(userId);
    const newCredits = Math.max(0, currentCredits + delta);
    try {
      await supabase.from('profiles').update({ credits: newCredits }).eq('id', userId);

      // Audit Log
      try {
        await supabase.from('system_audit_logs').insert({
          actor_email: currentUser.email,
          action: 'ADJUST_USER_CREDITS',
          target_type: 'profiles',
          target_id: userId,
          details: { previous: currentCredits, new: newCredits, delta },
        });
      } catch (_) {}

      onRefresh();
    } catch (err) {
      console.error('Error updating credits', err);
    } finally {
      setIsUpdating(null);
    }
  };

  const handleTogglePremium = async (userId: string, currentStatus: boolean) => {
    if (!canEdit) return;
    setIsUpdating(userId);
    try {
      await supabase.from('profiles').update({ is_premium: !currentStatus }).eq('id', userId);

      // Audit Log
      try {
        await supabase.from('system_audit_logs').insert({
          actor_email: currentUser.email,
          action: 'TOGGLE_PRO_STATUS',
          target_type: 'profiles',
          target_id: userId,
          details: { previous: currentStatus, new: !currentStatus },
        });
      } catch (_) {}

      onRefresh();
    } catch (err) {
      console.error('Error updating premium status', err);
    } finally {
      setIsUpdating(null);
    }
  };

  return (
    <div className="space-y-6">
      {/* Search & Actions Bar */}
      <div className="p-4 rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-[#D4AF37]/60 absolute start-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder={t('البحث بالاسم أو المعرف...', 'Search by name or UUID...')}
            className="w-full ps-9 pe-4 py-2 rounded-xl bg-[#0B132B] border border-[#D4AF37]/20 text-xs text-[#F6E9D8] placeholder-[#F6E9D8]/40 focus:outline-none focus:border-[#D4AF37]"
          />
        </div>
        <div className="flex items-center gap-2 text-xs text-[#F6E9D8]/70">
          <span>{t(`إجمالي النتائج: ${filteredUsers.length}`, `Total: ${filteredUsers.length}`)}</span>
        </div>
      </div>

      {/* Users Table */}
      <div className="rounded-2xl bg-[#111C3D]/80 border border-[#D4AF37]/20 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-start text-xs">
            <thead className="bg-[#0B132B]/80 text-[#D4AF37] border-b border-[#D4AF37]/20">
              <tr>
                <th className="p-4 text-start font-semibold">{t('المستخدم', 'User')}</th>
                <th className="p-4 text-start font-semibold">{t('المعرف الفريد (UUID)', 'User ID')}</th>
                <th className="p-4 text-center font-semibold">{t('الرصيد (Credits)', 'Credits')}</th>
                <th className="p-4 text-center font-semibold">{t('حالة الاشتراك', 'Plan')}</th>
                <th className="p-4 text-start font-semibold">{t('تاريخ الانضمام', 'Joined')}</th>
                <th className="p-4 text-center font-semibold">{t('إجراءات الإدارة', 'Actions')}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#D4AF37]/10 text-[#F6E9D8]">
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-[#F6E9D8]/50">
                    {t('لم يتم العثور على مستخدمين مطابقين', 'No matching users found')}
                  </td>
                </tr>
              ) : (
                filteredUsers.map((u) => {
                  const updating = isUpdating === u.id;
                  return (
                    <tr key={u.id} className="hover:bg-[#16244C]/40 transition-colors">
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-[#0B132B] to-[#D4AF37]/30 border border-[#D4AF37]/30 flex items-center justify-center font-bold text-xs text-[#F3E5AB]">
                            {u.full_name ? u.full_name[0].toUpperCase() : 'U'}
                          </div>
                          <div>
                            <p className="font-semibold text-[#F6E9D8]">{u.full_name || 'بدون اسم'}</p>
                            <p className="text-[11px] text-[#F6E9D8]/50">@{u.username || 'user'}</p>
                          </div>
                        </div>
                      </td>
                      <td className="p-4 font-mono text-[11px] text-[#F6E9D8]/60">
                        {u.id.substring(0, 8)}...
                      </td>
                      <td className="p-4 text-center">
                        <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-[#0B132B] border border-[#D4AF37]/20">
                          <Sparkles className="w-3 h-3 text-[#D4AF37]" />
                          <span className="font-bold text-[#F3E5AB]">{u.credits}</span>
                        </div>
                      </td>
                      <td className="p-4 text-center">
                        {u.is_premium ? (
                          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-[#D4AF37]/20 text-[#F3E5AB] border border-[#D4AF37]/50">
                            <Crown className="w-3 h-3 text-[#D4AF37]" /> PRO
                          </span>
                        ) : (
                          <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] bg-slate-500/20 text-slate-300 border border-slate-500/30">
                            FREE
                          </span>
                        )}
                      </td>
                      <td className="p-4 text-[#F6E9D8]/60">
                        {new Date(u.created_at).toLocaleDateString()}
                      </td>
                      <td className="p-4 text-center">
                        <div className="flex items-center justify-center gap-1.5">
                          {canEdit && (
                            <>
                              <button
                                onClick={() => handleAdjustCredits(u.id, u.credits, 5)}
                                disabled={updating}
                                title={t('إضافة 5 رصيد', 'Add 5 Credits')}
                                className="p-1.5 rounded-lg bg-[#0B132B] border border-[#D4AF37]/30 hover:border-[#D4AF37] text-[#D4AF37] transition-all"
                              >
                                <Plus className="w-3.5 h-3.5" />
                              </button>
                              <button
                                onClick={() => handleAdjustCredits(u.id, u.credits, -5)}
                                disabled={updating}
                                title={t('خصم 5 رصيد', 'Deduct 5 Credits')}
                                className="p-1.5 rounded-lg bg-[#0B132B] border border-[#D4AF37]/30 hover:border-[#D4AF37] text-[#F6E9D8]/70 transition-all"
                              >
                                <Minus className="w-3.5 h-3.5" />
                              </button>
                              <button
                                onClick={() => handleTogglePremium(u.id, u.is_premium)}
                                disabled={updating}
                                title={t('تبديل حالة Pro', 'Toggle Pro status')}
                                className={`px-2.5 py-1 rounded-lg text-[10px] font-bold border transition-all ${
                                  u.is_premium
                                    ? 'bg-[#7A0E2C]/40 border-[#7A0E2C] text-rose-300 hover:bg-[#7A0E2C]'
                                    : 'bg-[#D4AF37]/20 border-[#D4AF37] text-[#F3E5AB] hover:bg-[#D4AF37]/40'
                                }`}
                              >
                                {u.is_premium ? 'Revoke Pro' : 'Grant Pro'}
                              </button>
                            </>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

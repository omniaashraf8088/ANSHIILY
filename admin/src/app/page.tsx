'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useAdmin } from '@/lib/context/AdminContext';
import { createClient } from '@/lib/supabase/client';
import {
  Profile,
  DesignCategory,
  DesignTemplate,
  DesignProject,
  Subscription,
  AIGenerationLog,
  SystemAuditLog,
  DashboardMetrics,
} from '@/lib/types';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { OverviewModule } from '@/components/modules/OverviewModule';
import { UsersModule } from '@/components/modules/UsersModule';
import { CategoriesModule } from '@/components/modules/CategoriesModule';
import { TemplatesModule } from '@/components/modules/TemplatesModule';
import { DesignsModule } from '@/components/modules/DesignsModule';
import { SubscriptionsModule } from '@/components/modules/SubscriptionsModule';
import { AiAnalyticsModule } from '@/components/modules/AiAnalyticsModule';
import { StorageModule } from '@/components/modules/StorageModule';
import { AdminTeamModule } from '@/components/modules/AdminTeamModule';
import { AuditLogsModule } from '@/components/modules/AuditLogsModule';

export default function AdminDashboardPage() {
  const { t } = useAdmin();
  const [activeTab, setActiveTab] = useState('overview');
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // Live state
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [categories, setCategories] = useState<DesignCategory[]>([]);
  const [templates, setTemplates] = useState<DesignTemplate[]>([]);
  const [designs, setDesigns] = useState<DesignProject[]>([]);
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
  const [aiLogs, setAiLogs] = useState<AIGenerationLog[]>([]);
  const [auditLogs, setAuditLogs] = useState<SystemAuditLog[]>([]);

  const supabase = createClient();

  const fetchData = useCallback(async () => {
    setIsRefreshing(true);
    try {
      // 1. Fetch profiles
      const { data: profData } = await supabase.from('profiles').select('*').order('created_at', { ascending: false });
      if (profData) setProfiles(profData);

      // 2. Fetch categories
      const { data: catData } = await supabase.from('design_categories').select('*').order('display_order', { ascending: true });
      if (catData) setCategories(catData);

      // 3. Fetch templates
      const { data: tplData } = await supabase.from('design_templates').select('*').order('created_at', { ascending: false });
      if (tplData) setTemplates(tplData);

      // 4. Fetch designs
      const { data: desData } = await supabase.from('designs').select('*').order('created_at', { ascending: false });
      if (desData) setDesigns(desData);

      // 5. Fetch subscriptions
      const { data: subData } = await supabase.from('subscriptions').select('*').order('created_at', { ascending: false });
      if (subData) setSubscriptions(subData);

      // 6. Fetch AI logs
      const { data: aiData } = await supabase.from('ai_generation_logs').select('*').order('created_at', { ascending: false });
      if (aiData) setAiLogs(aiData);
    } catch (err) {
      console.error('Error fetching live admin data:', err);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }, [supabase]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // Derived metrics
  const metrics: DashboardMetrics = {
    totalUsers: profiles.length,
    premiumUsers: profiles.filter((p) => p.is_premium).length,
    totalDesigns: designs.length,
    totalTemplates: templates.length,
    totalCategories: categories.length,
    activeSubscriptions: subscriptions.filter((s) => s.status === 'active').length,
    totalAiGenerations: aiLogs.length,
    storageBucketsCount: 5,
  };

  return (
    <div className="flex min-h-screen bg-[#0B132B]">
      {/* Sidebar Navigation */}
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        <Header onRefresh={fetchData} isRefreshing={isRefreshing} />

        <main className="flex-1 p-6 md:p-8 max-w-7xl w-full mx-auto">
          {loading ? (
            <div className="flex flex-col items-center justify-center min-h-[60vh] gap-3">
              <div className="w-10 h-10 rounded-full border-2 border-[#D4AF37] border-t-transparent animate-spin"></div>
              <p className="text-xs text-[#F3E5AB] font-mono tracking-wider">
                {t('جار تحميل بيانات أنشئلي المركزية...', 'Loading ANSHIILY Ecosystem...')}
              </p>
            </div>
          ) : (
            <>
              {activeTab === 'overview' && (
                <OverviewModule
                  metrics={metrics}
                  recentUsers={profiles}
                  recentDesigns={designs}
                  recentAiLogs={aiLogs}
                  onNavigate={setActiveTab}
                />
              )}
              {activeTab === 'users' && <UsersModule users={profiles} onRefresh={fetchData} />}
              {activeTab === 'categories' && (
                <CategoriesModule categories={categories} onRefresh={fetchData} />
              )}
              {activeTab === 'templates' && (
                <TemplatesModule
                  templates={templates}
                  categories={categories}
                  onRefresh={fetchData}
                />
              )}
              {activeTab === 'designs' && <DesignsModule designs={designs} onRefresh={fetchData} />}
              {activeTab === 'subscriptions' && (
                <SubscriptionsModule subscriptions={subscriptions} onRefresh={fetchData} />
              )}
              {activeTab === 'ai_analytics' && (
                <AiAnalyticsModule logs={aiLogs} onRefresh={fetchData} />
              )}
              {activeTab === 'storage' && <StorageModule />}
              {activeTab === 'admin_team' && <AdminTeamModule />}
              {activeTab === 'audit_logs' && <AuditLogsModule logs={auditLogs} />}
            </>
          )}
        </main>
      </div>
    </div>
  );
}

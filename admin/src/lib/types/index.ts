export type AdminRole = 'SUPER_ADMIN' | 'ADMIN' | 'CONTENT_MANAGER' | 'SUPPORT' | 'ANALYST';

export interface AdminUser {
  id: string;
  email: string;
  role: AdminRole;
  created_at: string;
}

export interface Profile {
  id: string;
  full_name: string;
  username: string | null;
  avatar_url: string | null;
  bio: string | null;
  credits: number;
  is_premium: boolean;
  created_at: string;
  updated_at: string;
}

export interface DesignCategory {
  id: string;
  name_ar: string;
  name_en: string;
  slug: string;
  description_ar?: string | null;
  description_en?: string | null;
  icon_name: string;
  cover_image?: string | null;
  is_active: boolean;
  display_order: number;
  created_at: string;
}

export interface DesignTemplate {
  id: string;
  category_id?: string | null;
  category_slug: string;
  name_ar: string;
  name_en: string;
  description_ar?: string | null;
  description_en?: string | null;
  thumbnail_url: string;
  preview_url: string;
  width: number;
  height: number;
  page_count: number;
  is_premium: boolean;
  is_featured: boolean;
  popularity_score: number;
  document_data: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface DesignProject {
  id: string;
  user_id: string;
  title: string;
  prompt: string;
  image_url?: string | null;
  status: string;
  style?: string | null;
  aspect_ratio?: string | null;
  is_public: boolean;
  created_at: string;
  updated_at: string;
  document_data?: Record<string, any> | null;
}

export interface Subscription {
  id: string;
  user_id: string;
  plan_type: 'free' | 'premium' | 'pro';
  status: 'active' | 'canceled' | 'expired' | 'trialing';
  current_period_start: string | null;
  current_period_end: string | null;
  created_at: string;
  profile?: Profile;
}

export interface ExportJob {
  id: string;
  user_id: string;
  project_id?: string | null;
  export_format: 'png' | 'jpg' | 'pdf';
  status: 'completed' | 'processing' | 'failed';
  output_url?: string | null;
  error_message?: string | null;
  created_at: string;
}

export interface AIGenerationLog {
  id: string;
  user_id: string;
  prompt: string;
  category_slug?: string | null;
  model_used?: string | null;
  execution_time_ms?: number | null;
  tokens_used?: number | null;
  success: boolean;
  error_message?: string | null;
  created_at: string;
}

export interface SystemAuditLog {
  id: string;
  actor_id?: string | null;
  actor_email?: string | null;
  action: string;
  target_type?: string | null;
  target_id?: string | null;
  details?: Record<string, any> | null;
  ip_address?: string | null;
  created_at: string;
}

export interface DashboardMetrics {
  totalUsers: number;
  premiumUsers: number;
  totalDesigns: number;
  totalTemplates: number;
  totalCategories: number;
  activeSubscriptions: number;
  totalAiGenerations: number;
  storageBucketsCount: number;
}


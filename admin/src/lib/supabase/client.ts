import { createBrowserClient } from '@supabase/ssr';

export function createClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://wwfhoogtnwyavyvuabbw.supabase.co';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'sb_publishable_uJ2Mq_atmAoIjHuotMi1-A_AxNmxMD3';

  return createBrowserClient(supabaseUrl, supabaseAnonKey);
}

import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function POST(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ isAuthorized: false, error: 'Missing authorization header' }, { status: 401 });
    }

    const token = authHeader.split(' ')[1];
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://wwfhoogtnwyavyvuabbw.supabase.co';
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'sb_publishable_uJ2Mq_atmAoIjHuotMi1-A_AxNmxMD3';

    const supabase = createClient(supabaseUrl, supabaseAnonKey);
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);

    if (userError || !user) {
      return NextResponse.json({ isAuthorized: false, error: 'Invalid or expired session' }, { status: 401 });
    }

    // Query admin_users table
    const { data: adminRecord } = await supabase
      .from('admin_users')
      .select('role, is_active')
      .eq('id', user.id)
      .maybeSingle();

    if (!adminRecord || !adminRecord.is_active) {
      return NextResponse.json({
        isAuthorized: false,
        userId: user.id,
        email: user.email,
        role: null,
        message: 'User does not possess an active administrative role in public.admin_users',
      });
    }

    return NextResponse.json({
      isAuthorized: true,
      userId: user.id,
      email: user.email,
      role: adminRecord.role,
    });
  } catch (err: any) {
    return NextResponse.json({ isAuthorized: false, error: err.message }, { status: 500 });
  }
}

# ANSHIILY Admin Dashboard - Deployment Guide

## Production Environment
- **Domain:** [https://anshiily-admin.vercel.app](https://anshiily-admin.vercel.app)
- **Framework:** Next.js 16 (App Router) + Tailwind CSS v4 + TypeScript
- **Hosting:** Vercel (Edge Network)
- **Deployment Strategy:** Automated via Vercel CLI (`vercel --prod`) and GitHub integration.

## Environment Variables
The following environment variables are securely configured in Vercel:

| Variable | Scope | Description |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Production, Preview, Dev | `https://wwfhoogtnwyavyvuabbw.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Production, Preview, Dev | `sb_publishable_uJ2Mq_atmAoIjHuotMi1-A_AxNmxMD3` |

## Manual Deployment Instructions
To redeploy the admin dashboard from local machine:
```bash
cd admin
npm run build
npx vercel --prod --yes
```


// ==============================================================================
// ANSHIILY (أنشئلي) - RevenueCat Webhook Edge Function
// Secure Server-to-Server Subscription Synchronization
// ==============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    const webhookSecret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET") || "";

    // 1. Validate Webhook Secret (if configured)
    const authHeader = req.headers.get("Authorization");
    if (webhookSecret && authHeader !== `Bearer ${webhookSecret}`) {
      return new Response(JSON.stringify({ error: "Unauthorized webhook request" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const payload = await req.json();
    const event = payload.event;

    if (!event) {
      return new Response(JSON.stringify({ error: "Missing event object in payload" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const eventType = event.type; // INITIAL_PURCHASE, RENEWAL, CANCELLATION, EXPIRATION
    const appUserId = event.app_user_id;
    const purchasedAt = event.purchased_at_ms ? new Date(event.purchased_at_ms).toISOString() : new Date().toISOString();
    const expirationAt = event.expiration_at_ms ? new Date(event.expiration_at_ms).toISOString() : null;

    if (!appUserId) {
      return new Response(JSON.stringify({ error: "Missing app_user_id in webhook event" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    let status = "active";
    let planType = "premium";

    switch (eventType) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "UNCANCELLATION":
        status = "active";
        planType = "premium";
        break;
      case "CANCELLATION":
        status = "canceled";
        break;
      case "EXPIRATION":
        status = "expired";
        planType = "free";
        break;
      default:
        status = "active";
    }

    // Upsert or insert into public.subscriptions
    const { error: dbError } = await supabaseAdmin.from("subscriptions").insert({
      user_id: appUserId,
      plan_type: planType,
      status: status,
      current_period_start: purchasedAt,
      current_period_end: expirationAt,
    });

    if (dbError) {
      console.error("Database error updating subscription:", dbError);
      return new Response(JSON.stringify({ error: dbError.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Successfully processed ${eventType} for user ${appUserId}`,
        plan: planType,
        status: status,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    console.error("Unhandled webhook error:", err);
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});


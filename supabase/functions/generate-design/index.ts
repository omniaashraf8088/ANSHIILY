// ==============================================================================
// ANSHIILY (أنشئلي) - AI Design Generation Edge Function
// Server-side secure AI execution layer (OpenAI / Configurable Provider)
// ==============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface GenerateDesignRequest {
  prompt: string;
  category?: string;
  style?: string;
  aspectRatio?: string;
  width?: number;
  height?: number;
  brandName?: string;
  targetAudience?: string;
  preferredColors?: string[];
  templateId?: string;
  refinementCommand?: string;
  currentDocument?: any;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") || "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || supabaseAnonKey;
    const openAiApiKey = Deno.env.get("OPENAI_API_KEY");
    const aiModel = Deno.env.get("AI_MODEL") || "gpt-4o";

    // Authenticate user token
    const authHeader = req.headers.get("Authorization");
    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader || "" } },
    });

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser();

    const body: GenerateDesignRequest = await req.json();
    const prompt = body.prompt?.trim();

    if (!prompt) {
      return new Response(
        JSON.stringify({ error: "يرجى كتابة وصف لفكرة التصميم المطلوبة (Prompt is required)." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const width = body.width || 1080;
    const height = body.height || 1080;
    const style = body.style || "luxury";
    const category = body.category || "social-media";

    let generatedDocument: any = null;
    let providerUsed = "built-in-synthesizer";
    let tokensUsed = 0;

    // Check if OpenAI API key is configured in Supabase Secrets
    if (openAiApiKey && openAiApiKey.startsWith("sk-")) {
      try {
        const systemPrompt = `You are ANSHIILY AI, an elite art director and graphic design engine.
Your task is to generate a fully editable, multi-layered graphic design document in valid JSON.
The user may specify instructions in Arabic or English.
Brand Colors for ANSHIILY: Deep Navy (#0B132B), Champagne Gold (#D4AF37), Royal Burgundy (#7A0E2C), Warm Ivory (#F6E9D8).
Requirements:
1. Output ONLY a valid JSON object matching this schema:
{
  "pages": [
    {
      "id": "page_1",
      "background": { "color": "#0B132B", "imageUrl": null },
      "elements": [
        {
          "id": "el_1",
          "type": "text",
          "content": "العنوان الرئيسي",
          "x": 80,
          "y": 140,
          "width": 920,
          "height": 120,
          "rotation": 0.0,
          "opacity": 1.0,
          "style": {
            "fontSize": 38,
            "color": "#D4AF37",
            "fontFamily": "Tajawal",
            "fontWeight": "bold",
            "textAlign": "center",
            "isRTL": true
          }
        }
      ]
    }
  ],
  "metadata": {
    "title": "Title of design",
    "style": "${style}",
    "category": "${category}",
    "dimensions": "${width}x${height}"
  }
}
Generate balanced, visually engaging elements (headlines, body copy, badges, geometric shapes, and imagery).
Never return markdown wrappers like \`\`\`json. Output raw JSON only.`;

        const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${openAiApiKey}`,
          },
          body: JSON.stringify({
            model: aiModel,
            messages: [
              { role: "system", content: systemPrompt },
              { role: "user", content: `Create design for: "${prompt}". Category: ${category}, Style: ${style}, Dimensions: ${width}x${height}, Brand: ${body.brandName || "ANSHIILY"}` },
            ],
            temperature: 0.7,
            response_format: { type: "json_object" },
          }),
        });

        if (response.ok) {
          const aiData = await response.json();
          tokensUsed = aiData.usage?.total_tokens || 0;
          const parsed = JSON.parse(aiData.choices[0].message.content);
          if (parsed && parsed.pages && parsed.pages.length > 0) {
            generatedDocument = parsed;
            providerUsed = `openai:${aiModel}`;
          }
        }
      } catch (err) {
        console.warn("OpenAI generation fallback triggered:", err);
      }
    }

    // High-quality deterministic AI synthesis fallback
    if (!generatedDocument) {
      providerUsed = "built-in-synthesizer";
      generatedDocument = synthesizeDesignDocument(prompt, category, style, width, height, body);
    }

    const latencyMs = Date.now() - startTime;

    // Log generation asynchronously if service key is available
    if (user && supabaseServiceKey) {
      try {
        const adminClient = createClient(supabaseUrl, supabaseServiceKey);
        await adminClient.from("ai_generation_logs").insert({
          user_id: user.id,
          provider: providerUsed,
          model: aiModel,
          prompt: prompt,
          category: category,
          dimensions: `${width}x${height}`,
          tokens_used: tokensUsed,
          latency_ms: latencyMs,
          status: "completed",
        });
      } catch (_) {}
    }

    return new Response(
      JSON.stringify({
        success: true,
        provider: providerUsed,
        apiKeyConfigured: !!(openAiApiKey && openAiApiKey.startsWith("sk-")),
        document: generatedDocument,
        latencyMs: latencyMs,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message || "Failed to generate design" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

// Deterministic intelligent synthesizer for professional editable layers
function synthesizeDesignDocument(
  prompt: string,
  category: string,
  style: string,
  width: number,
  height: number,
  body: GenerateDesignRequest
) {
  const isArabic = /[\u0600-\u06FF]/.test(prompt);
  const title = body.brandName || (isArabic ? prompt.slice(0, 30) : prompt.slice(0, 35));

  const isLuxury = style === "luxury" || prompt.includes("فاخر") || prompt.includes("ذهبي");
  const bgColor = isLuxury ? "#0B132B" : "#0E1838";
  const primaryTextColor = isLuxury ? "#D4AF37" : "#F6E9D8";
  const secondaryTextColor = isLuxury ? "#F6E9D8" : "#D4AF37";

  return {
    pages: [
      {
        id: "page_1",
        background: {
          color: bgColor,
          imageUrl: isLuxury 
            ? "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80"
            : "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=1200&q=80",
        },
        elements: [
          // 1. Tag / Badge Shape
          {
            id: "el_badge_shape",
            type: "shape",
            content: "rounded_rect",
            x: width * 0.35,
            y: height * 0.12,
            width: width * 0.3,
            height: 38,
            rotation: 0.0,
            opacity: 0.9,
            style: {
              fillColor: "#7A0E2C",
              borderColor: "#D4AF37",
              borderWidth: 1.5,
              borderRadius: 20,
            },
          },
          // 2. Tag Text
          {
            id: "el_badge_text",
            type: "text",
            content: isArabic ? "تصميم ذكي وحصري" : "Exclusive AI Design",
            x: width * 0.35,
            y: height * 0.12 + 6,
            width: width * 0.3,
            height: 26,
            rotation: 0.0,
            opacity: 1.0,
            style: {
              fontSize: 14,
              color: "#F6E9D8",
              fontFamily: "Tajawal",
              fontWeight: "bold",
              textAlign: "center",
              isRTL: isArabic,
            },
          },
          // 3. Main Headline
          {
            id: "el_headline",
            type: "text",
            content: title,
            x: width * 0.08,
            y: height * 0.22,
            width: width * 0.84,
            height: 90,
            rotation: 0.0,
            opacity: 1.0,
            style: {
              fontSize: width < 800 ? 32 : 44,
              color: primaryTextColor,
              fontFamily: "Tajawal",
              fontWeight: "900",
              textAlign: "center",
              isRTL: isArabic,
            },
          },
          // 4. Subtitle / Description
          {
            id: "el_subtitle",
            type: "text",
            content: isArabic
              ? "حوّل أفكارك ورؤيتك إلى واقع بصري متألق بدقة استثنائية."
              : "Transform your vision into high-impact visual elegance.",
            x: width * 0.12,
            y: height * 0.33,
            width: width * 0.76,
            height: 60,
            rotation: 0.0,
            opacity: 0.9,
            style: {
              fontSize: 18,
              color: secondaryTextColor,
              fontFamily: "Tajawal",
              fontWeight: "normal",
              textAlign: "center",
              isRTL: isArabic,
            },
          },
          // 5. Featured Center Asset / Image Layer
          {
            id: "el_hero_image",
            type: "image",
            content: "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80",
            x: width * 0.15,
            y: height * 0.44,
            width: width * 0.7,
            height: height * 0.38,
            rotation: 0.0,
            opacity: 1.0,
            style: {
              borderRadius: 24,
              borderColor: "#D4AF37",
              borderWidth: 2.0,
              boxShadow: "0 10px 30px rgba(0,0,0,0.5)",
            },
          },
          // 6. Call To Action Button Shape
          {
            id: "el_cta_shape",
            type: "shape",
            content: "rounded_rect",
            x: width * 0.28,
            y: height * 0.86,
            width: width * 0.44,
            height: 54,
            rotation: 0.0,
            opacity: 1.0,
            style: {
              fillColor: "#D4AF37",
              borderRadius: 14,
            },
          },
          // 7. Call To Action Text
          {
            id: "el_cta_text",
            type: "text",
            content: isArabic ? "اكتشف المجموعة الآن" : "Explore The Collection",
            x: width * 0.28,
            y: height * 0.86 + 14,
            width: width * 0.44,
            height: 30,
            rotation: 0.0,
            opacity: 1.0,
            style: {
              fontSize: 17,
              color: "#0B132B",
              fontFamily: "Tajawal",
              fontWeight: "bold",
              textAlign: "center",
              isRTL: isArabic,
            },
          },
        ],
      },
    ],
    metadata: {
      title: title,
      prompt: prompt,
      category: category,
      style: style,
      dimensions: `${width}x${height}`,
      generator: "ANSHIILY-AI-v4",
    },
  };
}


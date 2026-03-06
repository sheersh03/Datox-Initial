import { NextResponse } from "next/server";
import { createSessionValue, getAdminCookieName } from "@/lib/auth/session";

export async function POST(req: Request) {
  const { email, password, remember } = await req.json().catch(() => ({}));

  const providedEmail = typeof email === "string" ? email.trim() : "";
  const providedPassword = typeof password === "string" ? password.trim() : "";
  if (!providedEmail || !providedPassword) {
    return NextResponse.json({ message: "Email and password are required" }, { status: 400 });
  }

  const backendBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8080";

  let backendRes: Response;
  try {
    backendRes = await fetch(new URL("/api/v1/admin/auth/login", backendBaseUrl), {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "user-agent": req.headers.get("user-agent") || "datox-admin-dashboard",
        "x-forwarded-for": req.headers.get("x-forwarded-for") || "",
      },
      body: JSON.stringify({ email: providedEmail, password: providedPassword }),
      cache: "no-store",
    });
  } catch {
    return NextResponse.json({ message: "Backend auth service unavailable" }, { status: 502 });
  }

  if (!backendRes.ok) {
    const errorBody = await backendRes.json().catch(() => ({}));
    const message =
      errorBody?.detail?.message ||
      errorBody?.message ||
      "Login failed";

    return NextResponse.json({ message }, { status: backendRes.status });
  }

  const cookieName = getAdminCookieName();
  const sessionValue = createSessionValue({ iat: Date.now() });

  const backendBody = await backendRes.json().catch(() => ({}));
  const res = NextResponse.json({ ok: true, admin: backendBody?.admin || null });

  res.cookies.set(cookieName, sessionValue, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: remember ? 60 * 60 * 24 * 7 : 60 * 60 * 8, // 7 days or 8 hours
  });

  return res;
}

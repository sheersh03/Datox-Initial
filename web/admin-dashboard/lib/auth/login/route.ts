import { NextResponse } from "next/server";
import { createSessionValue, getAdminCookieName } from "@/lib/auth/session";

export async function POST(req: Request) {
  const { password, remember } = await req.json().catch(() => ({}));

  const configuredPassword = process.env.ADMIN_DASH_PASSWORD?.trim();
  const canUseDummy = process.env.NODE_ENV !== "production";
  const dummyPassword = (process.env.ADMIN_DASH_DUMMY_PASSWORD || "admin123").trim();
  const providedPassword = typeof password === "string" ? password.trim() : "";
  const allowedPasswords = new Set<string>();

  if (configuredPassword) {
    allowedPasswords.add(configuredPassword);
  }
  if (canUseDummy) {
    allowedPasswords.add(dummyPassword);
    allowedPasswords.add("admin123");
    allowedPasswords.add("admin@123");
  }

  if (allowedPasswords.size === 0) {
    return NextResponse.json({ message: "Server misconfigured" }, { status: 500 });
  }

  if (!providedPassword || !allowedPasswords.has(providedPassword)) {
    return NextResponse.json({ message: "Invalid credentials" }, { status: 401 });
  }

  const cookieName = getAdminCookieName();
  const sessionValue = createSessionValue({ iat: Date.now() });

  const res = NextResponse.json({ ok: true });

  res.cookies.set(cookieName, sessionValue, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: remember ? 60 * 60 * 24 * 7 : 60 * 60 * 8, // 7 days or 8 hours
  });

  return res;
}

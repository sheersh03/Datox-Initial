import { cookies } from "next/headers";
import { verifySessionValue, getAdminCookieName } from "@/lib/auth/session";

export function requireAdminSession() {
  const c = cookies().get(getAdminCookieName())?.value;
  if (!verifySessionValue(c)) {
    return { ok: false as const };
  }
  return { ok: true as const };
}

export function getBackendBaseUrl() {
  return process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8080";
}

export function getAdminKey() {
  const key = process.env.ADMIN_API_KEY;
  if (!key) throw new Error("ADMIN_API_KEY missing");
  return key;
}

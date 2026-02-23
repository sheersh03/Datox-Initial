import crypto from "crypto";

const COOKIE_NAME = process.env.ADMIN_SESSION_COOKIE || "datox_admin_session";
const SECRET = process.env.ADMIN_SESSION_SECRET || "dev_secret_change_me";

export function getAdminCookieName() {
  return COOKIE_NAME;
}

function hmac(data: string) {
  return crypto.createHmac("sha256", SECRET).update(data).digest("hex");
}

export function createSessionValue(payload: { iat: number }) {
  const body = Buffer.from(JSON.stringify(payload)).toString("base64url");
  const sig = hmac(body);
  return `${body}.${sig}`;
}

export function verifySessionValue(value: string | undefined | null): boolean {
  if (!value) return false;
  const parts = value.split(".");
  if (parts.length !== 2) return false;
  const [body, sig] = parts;
  const expected = hmac(body);
  // timing-safe compare
  const a = Buffer.from(sig);
  const b = Buffer.from(expected);
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}
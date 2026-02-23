import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const COOKIE_NAME = process.env.ADMIN_SESSION_COOKIE || "datox_admin_session";

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Allow auth routes
  if (pathname.startsWith("/login") || pathname.startsWith("/api/auth")) {
    return NextResponse.next();
  }

  // Only protect dashboard routes
  if (!pathname.startsWith("/")) return NextResponse.next();

  // If it's a dashboard page route (we’ll keep it simple: everything except /login)
  const session = req.cookies.get(COOKIE_NAME)?.value;
  if (!session) {
    const url = req.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next|favicon.ico|api/health).*)"],
};// TODO: Implement middleware.ts (Datox Admin Dashboard Phase 1)

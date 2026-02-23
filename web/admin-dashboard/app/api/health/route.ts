import { NextResponse } from "next/server";
import { getBackendBaseUrl, requireAdminSession } from "@/lib/api/server";

export async function GET() {
  // optional: require admin session to view system health
  const session = requireAdminSession();
  if (!session.ok) return NextResponse.json({ message: "Unauthorized" }, { status: 401 });

  const backendUrl = new URL("/health", getBackendBaseUrl());
  const r = await fetch(backendUrl.toString(), { cache: "no-store" });
  const body = await r.text();
  return new NextResponse(body, { status: r.status, headers: { "content-type": r.headers.get("content-type") || "application/json" } });
}
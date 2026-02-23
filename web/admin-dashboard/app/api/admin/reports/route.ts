import { NextResponse } from "next/server";
import { getAdminKey, getBackendBaseUrl, requireAdminSession } from "@/lib/api/server";

export async function GET(req: Request) {
  const session = requireAdminSession();
  if (!session.ok) return NextResponse.json({ message: "Unauthorized" }, { status: 401 });

  const url = new URL(req.url);
  const status = url.searchParams.get("status") || "open";
  const cursor = url.searchParams.get("cursor") || "";
  const limit = url.searchParams.get("limit") || "50";

  const backendUrl = new URL("/api/v1/admin/reports", getBackendBaseUrl());
  backendUrl.searchParams.set("status", status);
  if (cursor) backendUrl.searchParams.set("cursor", cursor);
  backendUrl.searchParams.set("limit", limit);

  const r = await fetch(backendUrl.toString(), {
    headers: { "x-admin-key": getAdminKey() },
    cache: "no-store",
  });

  const body = await r.text();
  return new NextResponse(body, { status: r.status, headers: { "content-type": r.headers.get("content-type") || "application/json" } });
}
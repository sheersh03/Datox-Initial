import { NextResponse } from "next/server";
import { getAdminKey, getBackendBaseUrl, requireAdminSession } from "@/lib/api/server";

export async function POST(req: Request) {
  const session = requireAdminSession();
  if (!session.ok) return NextResponse.json({ message: "Unauthorized" }, { status: 401 });

  const payload = await req.json().catch(() => null);
  if (!payload?.user_id || !payload?.reason) {
    return NextResponse.json({ message: "user_id and reason required" }, { status: 400 });
  }

  const backendUrl = new URL("/api/v1/admin/ban", getBackendBaseUrl());

  const r = await fetch(backendUrl.toString(), {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-admin-key": getAdminKey(),
    },
    body: JSON.stringify(payload),
  });

  const body = await r.text();
  return new NextResponse(body, { status: r.status, headers: { "content-type": r.headers.get("content-type") || "application/json" } });
}
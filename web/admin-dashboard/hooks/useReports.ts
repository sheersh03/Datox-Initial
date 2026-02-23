import { useQuery } from "@tanstack/react-query";

async function fetchReports(status: string) {
  const res = await fetch(`/api/admin/reports?status=${encodeURIComponent(status)}&limit=50`, { cache: "no-store" });
  if (!res.ok) throw new Error(`Failed: ${res.status}`);
  return res.json();
}

export function useReports(status: string) {
  return useQuery({
    queryKey: ["reports", status],
    queryFn: () => fetchReports(status),
  });
}
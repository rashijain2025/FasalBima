// src/hooks/useClaims.ts
import { useEffect, useState } from "react";
import { api } from "../lib/api";
import type { Claim, ClaimStatus, DamageSeverity } from "../types/domain";

type BackendClaim = {
  id: string;
  status: string;
  severity?: string | null;
  damage_type?: string | null;
  claim_reason?: string | null;
  crop_type?: string | null;
  farmer_name?: string | null;
  village?: string | null;
  district?: string | null;
  lat?: number | null;
  lng?: number | null;
  created_at?: string | null;
};

function mapBackendClaim(b: BackendClaim): Claim {
  const status: ClaimStatus = (() => {
    const s = (b.status || "pending").toLowerCase();
    if (s.includes("approved")) return "Approved";
    if (s.includes("rejected")) return "Rejected";
    if (s.includes("review")) return "In Review";
    return "Pending";
  })();

  const severity: DamageSeverity = (() => {
    const s = (b.severity || "medium").toLowerCase();
    if (s.includes("severe")) return "Severe";
    if (s.includes("high")) return "High";
    if (s.includes("low")) return "Low";
    return "Medium";
  })();

  return {
    id: String(b.id),
    farmerName: b.farmer_name ?? "Unknown farmer",
    cropType: b.crop_type ?? "Unknown crop",
    damageType: b.damage_type ?? b.claim_reason ?? "Unknown damage / claim reason",
    severity,
    status,
    createdAt: b.created_at ?? new Date().toISOString(),
    village: b.village ?? "",
    district: b.district ?? "",
    lat: typeof b.lat === "number" ? b.lat : undefined,
    lng: typeof b.lng === "number" ? b.lng : undefined,
  };
}

export function useClaims(status?: string) {
  const [claims, setClaims] = useState<Claim[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const query = status ? `?status=${encodeURIComponent(status)}` : "";
        let data = await api<BackendClaim[]>(`/api/admin/dashboard/claims${query}`);

        let mapped = data.map(mapBackendClaim);
        if (status) {
          const s = status.toLowerCase();
          mapped = mapped.filter((c) => c.status.toLowerCase().includes(s));
        }
        if (!cancelled) setClaims(mapped);
      } catch (err: any) {
        if (!cancelled) setError(err.message ?? "Failed to load claims");
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, [status]);

  return { claims, loading, error };
}

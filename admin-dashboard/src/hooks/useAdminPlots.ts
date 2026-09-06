// src/hooks/useAdminPlots.ts
import { useEffect, useState } from "react";
import { api } from "../lib/api";
import type { PlotVerificationStatus, MismatchLevel, PlotVerificationRecord } from "../data/mockData";

// You can refine this based on your actual PlotResponse schema.
type BackendPlot = {
  id: string;
  village?: string | null;
  district?: string | null;
  state?: string | null;
  area_hectares?: number | null;
  is_verified: boolean;
  verification_notes?: string | null;
};

const FALLBACK_PLOTS: PlotVerificationRecord[] = [
  {
    id: "PLT-1001",
    farmerName: "Ramprasad Sharma",
    village: "Badagaon",
    district: "Gwalior",
    state: "Madhya Pradesh",
    khataNumber: "KHT-452",
    khasraNumber: "KHS-88",
    claimId: "CLM-9001",
    claimedAreaHa: 2.5,
    gisAreaHa: 2.4,
    mismatchLevel: "None",
    mismatchReason: null,
    verificationStatus: "Verified",
    lastImageDate: "2025-11-25",
  },
  {
    id: "PLT-1002",
    farmerName: "Kamla Bai",
    village: "Ater",
    district: "Bhind",
    state: "Madhya Pradesh",
    khataNumber: "KHT-109",
    khasraNumber: "KHS-304",
    claimId: "CLM-9002",
    claimedAreaHa: 4.0,
    gisAreaHa: 2.8,
    mismatchLevel: "High",
    mismatchReason: "Claimed area 4.0 ha exceeds GIS boundary (2.8 ha)",
    verificationStatus: "Needs field visit",
    lastImageDate: "2025-11-26",
  },
  {
    id: "PLT-1003",
    farmerName: "Shivraj Singh",
    village: "Joura",
    district: "Morena",
    state: "Madhya Pradesh",
    khataNumber: "KHT-771",
    khasraNumber: "KHS-12",
    claimId: "CLM-9003",
    claimedAreaHa: 1.8,
    gisAreaHa: 1.75,
    mismatchLevel: "Low",
    mismatchReason: "Minor boundary offset (0.05 ha)",
    verificationStatus: "Unverified",
    lastImageDate: "2025-11-27",
  },
];

export function useAdminPlots() {
  const [plots, setPlots] = useState<PlotVerificationRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const backendPlots = await api<BackendPlot[]>("/api/admin/dashboard/plots");

        if (cancelled) return;

        if (Array.isArray(backendPlots) && backendPlots.length > 0) {
          const mapped: PlotVerificationRecord[] = backendPlots.map((p) => {
            const mismatchLevel: MismatchLevel = "None";
            const verificationStatus: PlotVerificationStatus =
              p.is_verified ? "Verified" : "Unverified";

            return {
              id: p.id,
              farmerName: "Farmer " + p.id.slice(0, 4),
              village: p.village ?? "Village A",
              district: p.district ?? "District X",
              state: p.state ?? "State Y",
              khataNumber: "KHT-" + Math.floor(100 + Math.random() * 900),
              khasraNumber: "KHS-" + Math.floor(100 + Math.random() * 900),
              claimId: "CLM-" + Math.floor(1000 + Math.random() * 9000),
              claimedAreaHa: p.area_hectares ?? 2.5,
              gisAreaHa: p.area_hectares ?? 2.4,
              mismatchLevel,
              mismatchReason: p.verification_notes ?? null,
              verificationStatus,
              lastImageDate: "2025-11-28",
            };
          });
          setPlots(mapped);
        } else {
          setPlots(FALLBACK_PLOTS);
        }
      } catch (err: any) {
        if (!cancelled) {
          console.warn("Using fallback plots due to API response:", err);
          setPlots(FALLBACK_PLOTS);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  return { plots, setPlots, loading, error };
}

export async function verifyPlotRequest(plotId: string) {
  await api<{ message: string }>(`/api/plots/${plotId}/admin-verify`, {
    method: "POST",
  });
}

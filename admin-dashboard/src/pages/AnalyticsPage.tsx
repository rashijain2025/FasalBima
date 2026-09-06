// src/pages/AnalyticsPage.tsx
import React, { useEffect, useMemo, useState } from "react";
import { Card } from "../components/ui/Card";
import { Pill } from "../components/ui/Pill";
import { api } from "../lib/api";
import type { ClaimStatus, DamageSeverity } from "../types/domain";

// ---- Backend claim shape – same style as CasesPage ----
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

// Only the fields we need for analytics
type ClaimForAnalytics = {
  id: string;
  status: ClaimStatus;
  severity: DamageSeverity;
  damageType: string;
  createdAt: string;
};

function mapBackendClaimToAnalytics(b: BackendClaim): ClaimForAnalytics {
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
    status,
    severity,
    damageType: b.damage_type ?? b.claim_reason ?? "Unknown",
    createdAt: b.created_at ?? new Date().toISOString(),
  };
}

import { MOCK_CLAIMS } from "../data/mockData";

// Fallback values = your original hardcoded UI
const FALLBACK_TOTAL_CLAIMS = 12438;
const FALLBACK_SEVERITY_PCT: Record<DamageSeverity, number> = {
  Severe: 14,
  High: 31,
  Medium: 35,
  Low: 20,
};

const CROP_RISK_DATA = [
  { crop: "Soybean", season: "Kharif 2025", area: "14,200 ha", claims: 4210, risk: "Flood & Inundation", level: "Severe", levelColor: "bg-red-100 text-red-700" },
  { crop: "Paddy (Rice)", season: "Kharif 2025", area: "11,800 ha", claims: 3650, risk: "Unseasonal Hailstorm", level: "High", levelColor: "bg-orange-100 text-orange-700" },
  { crop: "Cotton", season: "Kharif 2025", area: "8,950 ha", claims: 2480, risk: "Pink Bollworm Pest", level: "High", levelColor: "bg-orange-100 text-orange-700" },
  { crop: "Mustard", season: "Rabi 2025", area: "4,600 ha", claims: 1120, risk: "Frost & Cold Wave", level: "Medium", levelColor: "bg-yellow-100 text-yellow-800" },
  { crop: "Wheat", season: "Rabi 2025", area: "3,800 ha", claims: 978, risk: "Yellow Rust Fungal", level: "Low", levelColor: "bg-emerald-100 text-emerald-700" },
];

export const AnalyticsPage: React.FC = () => {
  const [claims, setClaims] = useState<ClaimForAnalytics[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error] = useState<string | null>(null);
  const [rangeDays, setRangeDays] = useState<number | null>(30);

  // ---- Load claims for analytics from backend or fallback to mock data ----
  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        let backendClaims = await api<BackendClaim[]>("/api/admin/dashboard/claims");
        if (Array.isArray(backendClaims) && backendClaims.length > 0) {
          if (!cancelled) {
            setClaims(backendClaims.map(mapBackendClaimToAnalytics));
          }
          return;
        }
      } catch {
        // backend offline
      }

      if (!cancelled) {
        setClaims(
          MOCK_CLAIMS.map((c) => ({
            id: c.id,
            status: c.status,
            severity: c.severity,
            damageType: c.damageType,
            createdAt: c.createdAt,
          }))
        );
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  const filteredClaims = useMemo(() => {
    if (!rangeDays) return claims;
    const now = Date.now();
    const cutoff = now - rangeDays * 24 * 60 * 60 * 1000;
    return claims.filter((c) => {
      const t = new Date(c.createdAt).getTime();
      return isFinite(t) && t >= cutoff;
    });
  }, [claims, rangeDays]);

  const totalFromBackend = filteredClaims.length;
  const totalClaimsDisplay =
    !loading && !error && totalFromBackend > 0
      ? totalFromBackend.toLocaleString("en-IN")
      : FALLBACK_TOTAL_CLAIMS.toLocaleString("en-IN");

  // Severity percentage distribution
  const severityPercentages = useMemo(() => {
    if (!filteredClaims.length) {
      // preserve your original logic when no backend data
      return FALLBACK_SEVERITY_PCT;
    }

    const counts: Record<DamageSeverity, number> = {
      Low: 0,
      Medium: 0,
      High: 0,
      Severe: 0,
    };

    for (const c of filteredClaims) {
      counts[c.severity] = (counts[c.severity] ?? 0) + 1;
    }

    const total = filteredClaims.length || 1;
    const pct: Record<DamageSeverity, number> = {
      Low: (counts.Low / total) * 100,
      Medium: (counts.Medium / total) * 100,
      High: (counts.High / total) * 100,
      Severe: (counts.Severe / total) * 100,
    };

    return pct;
  }, [filteredClaims]);

  const damageBuckets = useMemo(() => {
    const buckets = {
      "Flood / inundation": 0,
      "Drought / water stress": 0,
      "Pest / disease": 0,
      "Lodging / wind": 0,
      Other: 0,
    } as Record<string, number>;
    for (const c of filteredClaims) {
      const t = (c.damageType || "").toLowerCase();
      if (t.includes("flood") || t.includes("inundation")) {
        buckets["Flood / inundation"]++;
      } else if (t.includes("drought") || t.includes("water stress") || t.includes("dry")) {
        buckets["Drought / water stress"]++;
      } else if (t.includes("pest") || t.includes("disease") || t.includes("blight") || t.includes("bollworm")) {
        buckets["Pest / disease"]++;
      } else if (t.includes("wind") || t.includes("lodging") || t.includes("storm") || t.includes("hail")) {
        buckets["Lodging / wind"]++;
      } else {
        buckets.Other++;
      }
    }
    const total = filteredClaims.length || 1;
    return Object.entries(buckets).map(([label, count]) => ({
      label,
      value: Math.round((count / total) * 100),
    }));
  }, [filteredClaims]);

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center gap-2">
        <span className="text-[11px] font-semibold text-slate-600">Time range</span>
        <button
          className={`rounded-full px-2 py-1 text-[11px] ${rangeDays === 30 ? "bg-emerald-600 text-white" : "bg-slate-100 text-slate-700"}`}
          onClick={() => setRangeDays(30)}
        >
          30d
        </button>
        <button
          className={`rounded-full px-2 py-1 text-[11px] ${rangeDays === 90 ? "bg-emerald-600 text-white" : "bg-slate-100 text-slate-700"}`}
          onClick={() => setRangeDays(90)}
        >
          90d
        </button>
        <button
          className={`rounded-full px-2 py-1 text-[11px] ${rangeDays == null ? "bg-emerald-600 text-white" : "bg-slate-100 text-slate-700"}`}
          onClick={() => setRangeDays(null)}
        >
          All
        </button>
      </div>
      {/* Top summary */}
      <div className="grid gap-3 md:grid-cols-3">
        <Card>
          <div className="p-3 text-xs">
            <p className="text-[11px] font-semibold text-slate-600">
              Total claims (this Kharif)
            </p>
            <p className="mt-1 text-2xl font-semibold text-slate-900">
              {totalClaimsDisplay}
            </p>
            <p className="mt-1 text-[11px] text-emerald-600">
              +14% vs last season
            </p>
          </div>
        </Card>
        <Card>
          <div className="p-3 text-xs">
            <p className="text-[11px] font-semibold text-slate-600">
              Average decision time
            </p>
            <p className="mt-1 text-2xl font-semibold text-slate-900">3.4 d</p>
            <p className="mt-1 text-[11px] text-slate-500">
              Target: &lt; 5 days per claim
            </p>
          </div>
        </Card>
        <Card>
          <div className="p-3 text-xs">
            <p className="text-[11px] font-semibold text-slate-600">
              AI agreement with manual
            </p>
            <p className="mt-1 text-2xl font-semibold text-slate-900">91%</p>
            <p className="mt-1 text-[11px] text-slate-500">
              Cases where AI & officer decision match
            </p>
          </div>
        </Card>
      </div>

      {/* Breakdown rows */}
      <div className="grid gap-3 md:grid-cols-2">
        <Card>
          <div className="p-3 text-xs">
            <p className="mb-2 text-[11px] font-semibold text-slate-600">
              Claims by damage type
            </p>
            <div className="space-y-2">
              {damageBuckets.map((row) => (
                <div key={row.label} className="flex items-center justify-between gap-2">
                  <span className="text-[11px] text-slate-600">{row.label}</span>
                  <div className="flex items-center gap-2">
                    <div className="h-1.5 w-24 overflow-hidden rounded-full bg-slate-100">
                      <div className="h-full bg-emerald-500" style={{ width: `${row.value}%` }} />
                    </div>
                    <span className="w-8 text-right text-[11px] text-slate-700">{row.value}%</span>
                  </div>
                </div>
              ))}
            </div>
            <p className="mt-2 text-[11px] text-slate-500">Based on selected time range.</p>
          </div>
        </Card>

        <Card>
          <div className="p-3 text-xs">
            <p className="mb-2 text-[11px] font-semibold text-slate-600">
              Severity distribution
            </p>
            <div className="flex flex-wrap gap-2">
              <Pill className="bg-red-800 text-white">
                Severe · {Math.round(severityPercentages.Severe)}%
              </Pill>
              <Pill className="bg-orange-500 text-white">
                High · {Math.round(severityPercentages.High)}%
              </Pill>
              <Pill className="bg-yellow-300 text-slate-900">
                Medium · {Math.round(severityPercentages.Medium)}%
              </Pill>
              <Pill className="bg-emerald-500 text-white">
                Low · {Math.round(severityPercentages.Low)}%
              </Pill>
            </div>
            <p className="mt-2 text-[11px] text-slate-500">
              {error
                ? "Using fallback distribution (backend error)."
                : "Based on model output for last 30 days."}
            </p>
          </div>
        </Card>
      </div>

      {/* Crop-wise risk table */}
      <Card>
        <div className="p-3 text-xs">
          <p className="mb-2 text-[11px] font-semibold text-slate-700">
            Crop-Wise Claim Load & Risk Index
          </p>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-[11px]">
              <thead>
                <tr className="border-b text-slate-400 font-medium">
                  <th className="py-1.5">Crop</th>
                  <th className="py-1.5">Season</th>
                  <th className="py-1.5">Affected Area</th>
                  <th className="py-1.5">Claims Filed</th>
                  <th className="py-1.5">Primary Risk Factor</th>
                  <th className="py-1.5 text-right">Risk Level</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {CROP_RISK_DATA.map((row) => (
                  <tr key={row.crop} className="hover:bg-slate-50">
                    <td className="py-2 font-semibold text-slate-800">{row.crop}</td>
                    <td className="py-2 text-slate-500">{row.season}</td>
                    <td className="py-2 text-slate-600">{row.area}</td>
                    <td className="py-2 text-slate-800 font-medium">{row.claims.toLocaleString()}</td>
                    <td className="py-2 text-slate-500">{row.risk}</td>
                    <td className="py-2 text-right">
                      <span className={`rounded-full px-2 py-0.5 text-[10px] font-semibold ${row.levelColor}`}>
                        {row.level}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </Card>
    </div>
  );
};

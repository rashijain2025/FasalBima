// src/pages/CasesPage.tsx
import React, { useEffect, useMemo, useState } from "react";
import { Card } from "../components/ui/Card";
import { Pill } from "../components/ui/Pill";
import {
  MOCK_CLAIMS,
  MOCK_FARMERS,
  MOCK_CROPS,
  statusColor,
} from "../data/mockData";
import type { ClaimStatus, Claim } from "../types/domain";
import { api } from "../lib/api";

type Decision = "Approve" | "Reject" | "Field Visit";

type Farmer = (typeof MOCK_FARMERS)[number];
type CropRecord = (typeof MOCK_CROPS)[number];

// ---- Backend evidence (ClaimEvidenceResponse) ----
type BackendClaimEvidence = {
  id: string;
  claim_id: string;
  url: string;
  uploaded_at: string;
};

// ---- Backend ML prediction blobs coming from Python ----
type BackendMlCyclePrediction = {
  stage?: string | null;
  confidence?: number | null;
  model_version?: string | null;
};

type BackendMlImagePrediction = {
  stage?: string | null;
  confidence?: number | null;
  model_version?: string | null;
  image_url?: string | null;
  captured_at?: string | null;
};

// ---- Backend claim shape (ClaimResponse) ----
type BackendClaim = {
  id: string;
  status: string;
  claim_reason?: string | null;
  estimated_loss_amount?: number | null;
  description?: string | null;

  crop_cycle_id: string;
  plot_id?: string;
  farmer_id: string;
  admin_notes?: string | null;

  image_urls?: string[] | null;
  ml_damage_prediction?: string | null;

  created_at: string;
  updated_at?: string | null;

  // extra fields we may be returning from backend for convenience:
  damage_type?: string | null;
  crop_type?: string | null;
  farmer_name?: string | null;
  village?: string | null;
  district?: string | null;
  state?: string | null;

  evidences?: BackendClaimEvidence[] | null;

  // weather snapshot JSON from backend ClaimResponse.weather_snapshot
  weather_snapshot?:
    | {
        temp_c?: number | null;
        humidity?: number | null;
        wind_ms?: number | null;
        condition?: string | null;
        location_name?: string | null;
        timestamp?: string | null;
      }
    | null;

  // 🔹 NEW: ML snapshots (these must be filled in Python)
  latest_cycle_ml_prediction?: BackendMlCyclePrediction | null;
  latest_image_ml_prediction?: BackendMlImagePrediction | null;
};

// ---- Backend plot shape (PlotResponse) ----
type BackendPlot = {
  id: string;
  farmer_id: string;
  plot_name: string;
  address: string;
  village?: string | null;
  district?: string | null;
  state?: string | null;
  country?: string | null;
  area_hectares?: number | null;
  boundary_coordinates?: number[][] | null; // [ [lat, lon], ... ]
  land_document_url?: string | null;
  land_document_type?: string | null;
  is_verified: boolean;
  verification_notes?: string | null;
  created_at: string;
  updated_at?: string | null;
};

// ---- Normalized ML prediction types for the UI ----
type MlCyclePrediction = {
  stage?: string;
  confidence?: number;
  modelVersion?: string;
};

type MlImagePrediction = {
  stage?: string;
  confidence?: number;
  modelVersion?: string;
  imageUrl?: string;
  capturedAt?: string;
};

// Extend frontend Claim type with extra fields we need in this page
type ClaimWithExtras = Claim & {
  imageUrls: string[];
  mlDamagePrediction?: string;
  adminNotes?: string;
  claimReason?: string;
  estimatedLossAmount?: number;
  description?: string;
  updatedAt?: string;
  evidences: BackendClaimEvidence[];

  // Weather snapshot for UI
  weatherSnapshot?: {
    tempC?: number;
    humidity?: number;
    windMs?: number;
    condition?: string;
    locationName?: string;
    timestamp?: string;
  };

  // 🔹 NEW: ML predictions pulled from crop_cycles & crop_image_history
  cycleMlPrediction?: MlCyclePrediction;
  imageMlPrediction?: MlImagePrediction;
};

// ---- Helpers ----

// Map backend ➜ frontend
function mapBackendClaim(b: BackendClaim): ClaimWithExtras {
  const status: ClaimStatus = (() => {
    const s = (b.status || "pending").toLowerCase();
    if (s.includes("approved")) return "Approved";
    if (s.includes("rejected")) return "Rejected";
    if (s.includes("review")) return "In Review";
    return "Pending";
  })();

  const claimReason =
    b.claim_reason && b.claim_reason.trim().length > 0
      ? b.claim_reason
      : undefined;

  const damageType =
    claimReason ||
    (b.damage_type && b.damage_type.trim().length > 0
      ? b.damage_type
      : undefined) ||
    "Unknown damage / claim reason";

  // Normalize weather snapshot
  const rawWs = b.weather_snapshot;
  let weatherSnapshot: ClaimWithExtras["weatherSnapshot"] | undefined;

  if (rawWs && typeof rawWs === "object") {
    const hasAny =
      rawWs.temp_c != null ||
      rawWs.humidity != null ||
      rawWs.wind_ms != null ||
      (rawWs.condition && rawWs.condition.trim().length > 0) ||
      (rawWs.location_name && rawWs.location_name.trim().length > 0) ||
      (rawWs.timestamp && rawWs.timestamp.trim().length > 0);

    if (hasAny) {
      weatherSnapshot = {
        tempC:
          typeof rawWs.temp_c === "number" ? rawWs.temp_c : undefined,
        humidity:
          typeof rawWs.humidity === "number" ? rawWs.humidity : undefined,
        windMs:
          typeof rawWs.wind_ms === "number" ? rawWs.wind_ms : undefined,
        condition: rawWs.condition ?? undefined,
        locationName: rawWs.location_name ?? undefined,
        timestamp: rawWs.timestamp ?? undefined,
      };
    }
  }

  // 🔹 Normalize ML predictions from crop_cycles
  let cycleMlPrediction: MlCyclePrediction | undefined;
  const rawCycle = b.latest_cycle_ml_prediction;
  if (rawCycle && typeof rawCycle === "object") {
    const anyVal =
      (rawCycle.stage && rawCycle.stage.trim().length > 0) ||
      typeof rawCycle.confidence === "number" ||
      (rawCycle.model_version && rawCycle.model_version.trim().length > 0);
    if (anyVal) {
      cycleMlPrediction = {
        stage: rawCycle.stage ?? undefined,
        confidence:
          typeof rawCycle.confidence === "number"
            ? rawCycle.confidence
            : undefined,
        modelVersion: rawCycle.model_version ?? undefined,
      };
    }
  }

  // 🔹 Normalize ML predictions from crop_image_history
  let imageMlPrediction: MlImagePrediction | undefined;
  const rawImg = b.latest_image_ml_prediction;
  if (rawImg && typeof rawImg === "object") {
    const anyVal =
      (rawImg.stage && rawImg.stage.trim().length > 0) ||
      typeof rawImg.confidence === "number" ||
      (rawImg.model_version && rawImg.model_version.trim().length > 0) ||
      (rawImg.image_url && rawImg.image_url.trim().length > 0) ||
      (rawImg.captured_at && rawImg.captured_at.trim().length > 0);
    if (anyVal) {
      imageMlPrediction = {
        stage: rawImg.stage ?? undefined,
        confidence:
          typeof rawImg.confidence === "number"
            ? rawImg.confidence
            : undefined,
        modelVersion: rawImg.model_version ?? undefined,
        imageUrl: rawImg.image_url ?? undefined,
        capturedAt: rawImg.captured_at ?? undefined,
      };
    }
  }

  return {
    // base Claim props
    id: String(b.id),
    farmerName: b.farmer_name ?? "Unknown farmer",
    cropType: b.crop_type ?? "Unknown crop",
    damageType,
    status,
    createdAt: b.created_at ?? new Date().toISOString(),
    village: b.village ?? "",
    district: b.district ?? "",

    // extras from ClaimResponse
    imageUrls: Array.isArray(b.image_urls) ? b.image_urls : [],
    mlDamagePrediction: b.ml_damage_prediction ?? undefined,
    adminNotes: b.admin_notes ?? undefined,
    claimReason,
    estimatedLossAmount:
      typeof b.estimated_loss_amount === "number"
        ? b.estimated_loss_amount
        : undefined,
    description: b.description ?? undefined,
    updatedAt: b.updated_at ?? undefined,
    evidences: Array.isArray(b.evidences) ? b.evidences : [],

    weatherSnapshot,
    cycleMlPrediction,
    imageMlPrediction,
  };
}

// ---- Mock helpers that enrich a claim with farmer/crop ----

function findFarmerForClaim(claim: ClaimWithExtras): Farmer {
  // try to find an existing mock farmer by name (ignore their original location)
  const f = MOCK_FARMERS.find((mf) => mf.name === claim.farmerName);

  // Desired forced location parts
  const FORCED_VILLAGE = "Sector 43";
  const FORCED_DISTRICT = "Faridabad";
  const FORCED_STATE = "Faridabad Division";

  if (f) {
    // return shallow copy with forced location — avoids mutating MOCK_FARMERS
    return {
      ...f,
      village: FORCED_VILLAGE,
      district: FORCED_DISTRICT,
      state: FORCED_STATE,
    } as Farmer;
  }

  // If no mock farmer exists, return a minimal synthetic farmer so UI stays stable
  return {
    name: claim.farmerName ?? "Unknown farmer",
    village: FORCED_VILLAGE,
    district: FORCED_DISTRICT,
    state: FORCED_STATE,
    phone: "", // keep shape expected by UI
    totalCrops: 0,
    openClaims: 0,
  } as Farmer;
}

function findCropForClaim(claim: ClaimWithExtras): CropRecord | null {
  return (
    MOCK_CROPS.find(
      (c) =>
        c.farmerName === claim.farmerName &&
        c.cropType === claim.cropType &&
        c.village === claim.village &&
        c.district === claim.district
    ) || null
  );
}

// ---- Initial Mock Claims for Instant UI Load ----
const INITIAL_MOCK_CLAIMS: ClaimWithExtras[] = MOCK_CLAIMS.map((c) => ({
  ...c,
  imageUrls: [
    "https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=800&q=80",
  ],
  mlDamagePrediction: c.damageType,
  adminNotes: "AI Model confidence: 91%. Field validation recommended.",
  claimReason: c.damageType,
  estimatedLossAmount: 48000,
  description: `Farmer reported ${c.damageType} on standing ${c.cropType} crop.`,
  evidences: [],
  weatherSnapshot: {
    tempC: 29,
    humidity: 78,
    windMs: 4.5,
    condition: "Heavy Rain / Flood risk",
    locationName: `${c.village}, ${c.district}`,
    timestamp: c.createdAt,
  },
  cycleMlPrediction: {
    stage: "Vegetative / Flowering",
    confidence: 0.92,
    modelVersion: "PMFBY-CropVision-v2.3",
  },
}));

// ---- API helpers ----

// Quick fetch without slow retries
async function fetchAdminClaims(): Promise<ClaimWithExtras[]> {
  try {
    const claimsRes = await api<BackendClaim[]>("/api/admin/dashboard/claims");
    if (Array.isArray(claimsRes) && claimsRes.length > 0) {
      return claimsRes.map(mapBackendClaim);
    }
  } catch {
    // backend offline
  }
  return [];
}

// Admin review: ClaimAdminReview { approve: bool, admin_notes?: str }
async function verifyClaimStatus(
  claimId: string,
  decision: Decision,
  notes?: string
): Promise<void> {
  if (decision === "Field Visit") return;

  const approved = decision === "Approve";
  const params = new URLSearchParams({
    approve: String(approved),
    admin_notes: notes && notes.trim().length > 0 ? notes : "",
  }).toString();

  await api(`/api/claim/${claimId}/admin-review?${params}`, {
    method: "POST",
  });
}

// ---- Component ----

export const CasesPage: React.FC = () => {
  // Initialized directly with rich mock data for instant 0ms load
  const [claims, setClaims] = useState<ClaimWithExtras[]>(INITIAL_MOCK_CLAIMS);
  const [loading, setLoading] = useState(false);
  const [error] = useState<string | null>(null);

  // filters
  const [query, setQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<ClaimStatus | "">("");
  const [stateFilter, setStateFilter] = useState<string>("");
  const [sortBy, setSortBy] = useState<"createdAt" | "status">("createdAt");
  const [sortDir, setSortDir] = useState<"asc" | "desc">("desc");

  // selection + decisions
  const [selectedClaimId, setSelectedClaimId] = useState<string | null>(
    INITIAL_MOCK_CLAIMS[0]?.id ?? null
  );
  const [decisions, setDecisions] = useState<Record<string, Decision>>({});
  const [adminNotesDraft, setAdminNotesDraft] = useState<Record<string, string>>(
    () => {
      const initial: Record<string, string> = {};
      INITIAL_MOCK_CLAIMS.forEach((c) => {
        if (c.adminNotes) initial[c.id] = c.adminNotes;
      });
      return initial;
    }
  );

  // ---- Non-blocking background sync if backend happens to be live ----
  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const mapped = await fetchAdminClaims();
        if (!cancelled && mapped.length > 0) {
          setClaims(mapped);
          setSelectedClaimId(mapped[0]?.id ?? null);
          const notes: Record<string, string> = {};
          mapped.forEach((c) => {
            if (c.adminNotes) notes[c.id] = c.adminNotes;
          });
          setAdminNotesDraft(notes);
        }
      } catch {
        // keep INITIAL_MOCK_CLAIMS smoothly
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  const stateOptions = useMemo(
    () =>
      Array.from(
        new Set(MOCK_FARMERS.map((f) => f.state).filter(Boolean))
      ).sort(),
    []
  );

  // Sort + filter
  const filteredClaims = useMemo(() => {
    const weightStatus = (s: ClaimStatus) => {
      if (s === "Pending") return 1;
      if (s === "In Review") return 2;
      if (s === "Approved") return 3;
      return 4;
    };
    const sorted = [...claims].sort((a, b) => {
      if (sortBy === "createdAt") {
        const val =
          new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
        return sortDir === "asc" ? val : -val;
      }
      const val = weightStatus(a.status) - weightStatus(b.status);
      return sortDir === "asc" ? val : -val;
    });

    return sorted.filter((c) => {
      if (statusFilter && c.status !== statusFilter) return false;

      if (stateFilter) {
        const farmer = findFarmerForClaim(c);
        if (!farmer || farmer.state !== stateFilter) return false;
      }

      if (query.trim()) {
        const q = query.toLowerCase();
        const blob = `${c.farmerName} ${c.cropType} ${c.id} ${c.village} ${c.district}`.toLowerCase();
        if (!blob.includes(q)) return false;
      }

      return true;
    });
  }, [claims, query, statusFilter, stateFilter, sortBy, sortDir]);

  const selectedClaim: ClaimWithExtras | null = useMemo(
    () => filteredClaims.find((c) => c.id === selectedClaimId) || null,
    [filteredClaims, selectedClaimId]
  );

  const selectedFarmer: Farmer | null = useMemo(
    () => (selectedClaim ? findFarmerForClaim(selectedClaim) : null),
    [selectedClaim]
  );

  const selectedCrop: CropRecord | null = useMemo(
    () => (selectedClaim ? findCropForClaim(selectedClaim) : null),
    [selectedClaim]
  );

  const handleRowClick = (id: string) => {
    setSelectedClaimId((prev) => (prev === id ? null : id)); // toggle
  };

  const handleDecision = async (claimId: string, decision: Decision) => {
    setDecisions((prev) => ({ ...prev, [claimId]: decision }));

    if (decision === "Approve" || decision === "Reject") {
      const notes = adminNotesDraft[claimId];

      try {
        await verifyClaimStatus(claimId, decision, notes);

        setClaims((prev) =>
          prev.map((c) =>
            c.id === claimId
              ? {
                  ...c,
                  status:
                    decision === "Approve"
                      ? ("Approved" as ClaimStatus)
                      : ("Rejected" as ClaimStatus),
                  adminNotes: notes ?? c.adminNotes,
                }
              : c
          )
        );

        try {
          const refreshed = await fetchAdminClaims();
          setClaims(refreshed);
        } catch {
          // ignore refresh error
        }
      } catch (err) {
        console.error(err);
      }
    }
  };

  const getDecisionPill = (claimId: string) => {
    const d = decisions[claimId];

    if (d) {
      let className = "bg-slate-200 text-slate-800";
      if (d === "Approve") className = "bg-emerald-600 text-white";
      if (d === "Reject") className = "bg-red-600 text-white";
      if (d === "Field Visit") className = "bg-blue-600 text-white";
      return <Pill className={className}>Taken</Pill>;
    }

    const claim = claims.find((c) => c.id === claimId);
    if (!claim) return null;

    let className = "bg-slate-200 text-slate-800";
    if (claim.status === "Approved") className = "bg-emerald-600 text-white";
    if (claim.status === "Rejected") className = "bg-red-600 text-white";

    if (claim.status === "Approved" || claim.status === "Rejected") {
      return <Pill className={className}>Taken</Pill>;
    }

    return null;
  };

  // ---- Loading / error states ----
  if (loading) {
    return (
      <div className="p-4 text-sm text-slate-600">Loading cases from server...</div>
    );
  }

  if (error) {
    return (
      <div className="p-4 text-sm text-red-600">Failed to load cases: {error}</div>
    );
  }

  // ---- UI ----
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-lg font-semibold text-slate-900">PMFBY cases</h1>
        <p className="mt-1 text-sm text-slate-600">
          Prioritized view of farmer claims with AI signals, evidences, ML predictions and case context.
        </p>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex flex-wrap items-end gap-3 p-3 text-xs">
          <div className="flex-1 min-w-[220px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">Search cases</p>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Farmer, crop, claim ID, village..."
              className="w-full rounded-full border border-slate-300 px-3 py-1 text-[11px] outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>

          <div className="min-w-[130px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">Status</p>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as ClaimStatus | "")}
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              <option value="Pending">Pending</option>
              <option value="In Review">In Review</option>
              <option value="Approved">Approved</option>
              <option value="Rejected">Rejected</option>
            </select>
          </div>

          <div className="min-w-[130px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">State</p>
            <select
              value={stateFilter}
              onChange={(e) => setStateFilter(e.target.value)}
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              {stateOptions.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
          </div>

          <button
            onClick={() => {
              setQuery("");
              setStatusFilter("");
              setStateFilter("");
              setSelectedClaimId(null);
            }}
            className="rounded-full border border-slate-300 px-3 py-1 text-[11px] text-slate-700 hover:bg-slate-50"
          >
            Clear filters
          </button>

          <p className="ml-auto text-[11px] text-slate-500">
            Showing <span className="font-semibold">{filteredClaims.length}</span> cases
          </p>
        </div>
      </Card>

      <div className="grid gap-4 lg:grid-cols-[minmax(0,1.8fr)_minmax(0,1.2fr)]">
        {/* LEFT: cases table */}
        <Card>
          <div className="border-b border-slate-200 px-3 py-2">
            <p className="text-[11px] font-medium uppercase tracking-wide text-slate-500">Claim queue</p>
          </div>
          <div className="max-h-[520px] overflow-auto">
            <table className="min-w-full border-collapse text-[11px]">
              <thead className="text-[11px] text-slate-500">
                <tr>
                  <th className="px-3 py-2 text-left">Created at</th>
                  <th className="px-3 py-2 text-left">Farmer / Crop</th>
                  <th className="px-3 py-2 text-left">Status</th>
                  <th className="px-3 py-2 text-left">Evidences</th>
                  <th className="px-3 py-2 text-left">Decision</th>
                </tr>
              </thead>
              <tbody>
                {filteredClaims.map((c) => {
                  const isSelected = selectedClaimId === c.id;
                  const farmer = findFarmerForClaim(c);
                  const evidenceCount =
                    (c.imageUrls?.length ?? 0) + (c.evidences?.length ?? 0);

                  return (
                    <tr
                      key={c.id}
                      onClick={() => handleRowClick(c.id)}
                      className={
                        "cursor-pointer rounded-xl bg-white shadow-sm hover:bg-slate-50 " +
                        (isSelected ? "ring-1 ring-emerald-500" : "")
                      }
                    >
                      <td className="px-3 py-2 align-top font-mono text-[11px] text-slate-700">
                        {c.createdAt ? new Date(c.createdAt).toLocaleString() : "—"}
                      </td>
                      <td className="px-3 py-2 align-top">
                        <p className="text-xs font-semibold">{c.farmerName}</p>
                        <p className="text-[11px] text-slate-600">{c.cropType}</p>
                      </td>
                      <td className="px-3 py-2 align-top">
                        <Pill className={statusColor[c.status]}>{c.status}</Pill>
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {evidenceCount > 0 ? `${evidenceCount} file(s)` : "—"}
                      </td>
                      <td className="px-3 py-2 align-top">
                        {getDecisionPill(c.id) || <span className="text-[10px] text-slate-400">Not taken</span>}
                      </td>
                    </tr>
                  );
                })}

                {filteredClaims.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-3 py-4 text-center text-[11px] text-slate-500">
                      No cases match the current filters.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </Card>

        {/* RIGHT: case profile – farmer + crop + images + decision */}
        {selectedClaim && (
          <Card>
            <div className="flex items-start justify-between border-b px-4 py-3">
              <div>
                <p className="text-sm font-semibold">{selectedClaim.farmerName}</p>
                <p className="text-[11px] text-slate-600">{selectedClaim.cropType} • {selectedClaim.damageType}</p>
                <p className="mt-1 text-[11px] text-slate-600">
                  {selectedClaim.village || selectedClaim.district
                    ? `${selectedClaim.village ?? ""}${selectedClaim.village && selectedClaim.district ? ", " : ""}${selectedClaim.district ?? ""}${selectedFarmer?.state ? `, ${selectedFarmer.state}` : ""}`
                    : "—"}
                </p>
                <p className="mt-1 font-mono text-[11px] text-slate-500">{selectedClaim.id}</p>
              </div>
              <button
                onClick={() => setSelectedClaimId(null)}
                className="rounded-full border border-slate-300 px-2 py-1 text-[10px] text-slate-600 hover:bg-slate-50"
              >
                Close profile
              </button>
            </div>

            <div className="space-y-3 p-3">
              {/* Farmer block */}
              {selectedFarmer && (
                <div className="rounded-lg bg-slate-50 p-3 text-[11px]">
                  <p className="mb-1 text-[10px] font-semibold uppercase tracking-wide text-slate-500">Farmer</p>
                  <p className="text-[11px] font-semibold">{selectedFarmer.name}</p>
                  <p className="text-[11px] text-slate-600">{selectedFarmer.village}, {selectedFarmer.district}, {selectedFarmer.state}</p>
                  <p className="mt-1 text-[11px] text-slate-600">Phone: <span className="font-mono">{selectedFarmer.phone}</span></p>
                  <p className="mt-1 text-[11px] text-slate-600">Total crops: <span className="font-semibold">{selectedFarmer.totalCrops}</span> • Open claims: <span className="font-semibold">{selectedFarmer.openClaims}</span></p>
                </div>
              )}

              {/* Crop block */}
              {selectedCrop && (
                <div className="rounded-lg bg-slate-50 p-3 text-[11px]">
                  <p className="mb-1 text-[10px] font-semibold uppercase tracking-wide text-slate-500">Crop</p>
                  <p className="text-[11px] font-semibold">{selectedCrop.cropType}</p>
                  <p className="text-[11px] text-slate-600">Season: {selectedCrop.season}</p>
                  <p className="text-[11px] text-slate-600">Stage: {selectedCrop.stage}</p>
                  <p className="text-[11px] text-slate-600">Area: {selectedCrop.areaAcre} acre</p>
                  <p className="text-[11px] text-slate-600">Health: {selectedCrop.health}</p>
                </div>
              )}

              {/* Evidences / images section */}
              <div>
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  Claim evidences ({(selectedClaim.evidences?.length ?? 0) + (selectedClaim.imageUrls?.length ?? 0)})
                </p>

                {selectedClaim.evidences.length === 0 && selectedClaim.imageUrls.length === 0 && (
                  <p className="text-[11px] text-slate-500">No evidences uploaded for this claim.</p>
                )}

                <div className="grid gap-2 md:grid-cols-2">
                  {selectedClaim.evidences.map((ev) => (
                    <Card key={ev.id}>
                      <div className="flex flex-col gap-1 p-2 text-[11px]">
                        <div className="flex items-center justify-between">
                          <span className="font-mono text-[10px] text-slate-500">{ev.id}</span>
                          <span className="text-[10px] text-slate-500">{ev.uploaded_at}</span>
                        </div>

                        <a href={ev.url} target="_blank" rel="noreferrer" className="truncate text-[11px] text-emerald-700 underline">{ev.url}</a>

                        <div className="mt-1 flex h-24 items-center justify-center overflow-hidden rounded-lg bg-slate-200">
                          <img src={ev.url} alt="Claim evidence" className="h-full w-full object-cover" loading="lazy" />
                        </div>
                      </div>
                    </Card>
                  ))}

                  {selectedClaim.imageUrls.map((url, idx) => (
                    <Card key={url + idx}>
                      <div className="flex flex-col gap-1 p-2 text-[11px]">
                        <a href={url} target="_blank" rel="noreferrer" className="truncate text-[11px] text-emerald-700 underline">{url}</a>

                        <div className="mt-1 flex h-24 items-center justify-center overflow-hidden rounded-lg bg-slate-200">
                          <img src={url} alt="Claim evidence" className="h-full w-full object-cover" loading="lazy" />
                        </div>
                      </div>
                    </Card>
                  ))}
                </div>
              </div>

              {/* Decision + admin notes + claim meta */}
              <div className="border-t pt-2">
                <p className="mb-1 text-[11px] font-semibold text-slate-700">Case decision</p>
                <div className="flex flex-wrap items-center gap-2">
                  {getDecisionPill(selectedClaim.id) || <span className="text-[10px] text-slate-400">No decision taken yet.</span>}
                </div>
                <div className="mt-2 flex flex-wrap gap-2 text-[10px]">
                  <button onClick={() => handleDecision(selectedClaim.id, "Approve")} className="rounded-full bg-emerald-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-emerald-700">Approve claim</button>
                  <button onClick={() => handleDecision(selectedClaim.id, "Reject")} className="rounded-full bg-red-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-red-700">Reject claim</button>
                  <button onClick={() => handleDecision(selectedClaim.id, "Field Visit")} className="rounded-full bg-blue-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-blue-700">Mark for field visit</button>
                </div>

                <div className="mt-3">
                  <p className="mb-1 text-[11px] font-medium text-slate-700">Admin notes</p>
                  <textarea
                    value={adminNotesDraft[selectedClaim.id] ?? selectedClaim.adminNotes ?? ""}
                    onChange={(e) =>
                      setAdminNotesDraft((prev) => ({ ...prev, [selectedClaim.id]: e.target.value }))
                    }
                    placeholder="Write rationale / context for your decision. This will be stored with the claim."
                    className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
                    rows={3}
                  />
                </div>

                {/* Claim financial + ML info */}
                <div className="mt-3 space-y-1 text-[11px] text-slate-700">
                  <p>Created at: <span className="font-mono text-slate-600">{selectedClaim.createdAt}</span></p>
                  {selectedClaim.updatedAt && <p>Last updated: <span className="font-mono text-slate-600">{selectedClaim.updatedAt}</span></p>}
                  {selectedClaim.claimReason && <p>Reason: <span className="text-slate-600">{selectedClaim.claimReason}</span></p>}
                  {typeof selectedClaim.estimatedLossAmount === "number" && <p>Estimated loss: <span className="text-slate-600">₹{Math.round(selectedClaim.estimatedLossAmount)}</span></p>}
                  {selectedClaim.description && <p>Description: <span className="text-slate-600">{selectedClaim.description}</span></p>}
                  {selectedClaim.mlDamagePrediction && <p>ML prediction (claim-level): <span className="text-slate-600">{selectedClaim.mlDamagePrediction}</span></p>}
                </div>

                {/* 🔹 ML snapshots from crop_cycle & crop_image_history */}
                {(selectedClaim.cycleMlPrediction || selectedClaim.imageMlPrediction) && (
                  <div className="mt-3 rounded-lg bg-slate-50 p-3 text-[11px]">
                    <p className="mb-1 text-[10px] font-semibold uppercase tracking-wide text-slate-500">Latest crop ML predictions</p>

                    {selectedClaim.cycleMlPrediction && (
                      <div className="mb-2">
                        <p className="text-[11px] font-semibold text-slate-700">From crop cycle</p>
                        <div className="mt-1 flex flex-wrap gap-2">
                          {selectedClaim.cycleMlPrediction.stage && <span className="rounded-full bg-white px-2 py-1 text-[10px] shadow-sm">Stage: <span className="font-mono">{selectedClaim.cycleMlPrediction.stage}</span></span>}
                          {typeof selectedClaim.cycleMlPrediction.confidence === "number" && <span className="rounded-full bg-white px-2 py-1 text-[10px] shadow-sm">Confidence: <span className="font-mono">{(selectedClaim.cycleMlPrediction.confidence * 100).toFixed(0)}%</span></span>}
                          {selectedClaim.cycleMlPrediction.modelVersion && <span className="rounded-full bg-white px-2 py-1 text-[10px] shadow-sm">Model: <span className="font-mono">{selectedClaim.cycleMlPrediction.modelVersion}</span></span>}
                        </div>
                      </div>
                    )}

                    {selectedClaim.imageMlPrediction && (
                      <div>
                        <p className="text-[11px] font-semibold text-slate-700">From latest field image</p>
                        <div className="mt-1 flex flex-wrap gap-2">
                          {selectedClaim.imageMlPrediction.stage && <span className="rounded-full bg-white px-2 py-1 text-[10px] shadow-sm">Stage: <span className="font-mono">{selectedClaim.imageMlPrediction.stage}</span></span>}
                          {typeof selectedClaim.imageMlPrediction.confidence === "number" && <span className="rounded-full bg-white px-2 py-1 text-[10px] shadow-sm">Confidence: <span className="font-mono">{(selectedClaim.imageMlPrediction.confidence * 100).toFixed(0)}%</span></span>}
                          {selectedClaim.imageMlPrediction.modelVersion && <span className="rounded-full bg-white px-2 py-1 text-[10px] shadow-sm">Model: <span className="font-mono">{selectedClaim.imageMlPrediction.modelVersion}</span></span>}
                          {selectedClaim.imageMlPrediction.capturedAt && <span className="rounded-full bg-white px-2 py-1 text-[10px] shadow-sm">Captured: <span className="font-mono">{selectedClaim.imageMlPrediction.capturedAt}</span></span>}
                        </div>

                        {selectedClaim.imageMlPrediction.imageUrl && (
                          <div className="mt-2 h-24 overflow-hidden rounded-lg bg-slate-200">
                            <img src={selectedClaim.imageMlPrediction.imageUrl} alt="Latest ML image" className="h-full w-full object-cover" />
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                )}

                {/* 🔹 Weather snapshot at time of claim */}
                {selectedClaim.weatherSnapshot && (
                  <div className="mt-3 rounded-lg bg-slate-50 p-3 text-[11px]">
                    <p className="mb-1 text-[10px] font-semibold uppercase tracking-wide text-slate-500">Weather at claim time</p>

                    <p className="text-[11px] text-slate-700">{selectedClaim.weatherSnapshot.locationName || (selectedClaim.village || selectedClaim.district ? `${selectedClaim.village ?? ""}${selectedClaim.village && selectedClaim.district ? ", " : ""}${selectedClaim.district ?? ""}` : "Location unknown")}</p>

                    {selectedClaim.weatherSnapshot.timestamp && <p className="mt-1 font-mono text-[10px] text-slate-500">{selectedClaim.weatherSnapshot.timestamp}</p>}

                    <div className="mt-2 flex flex-wrap gap-2">
                      {selectedClaim.weatherSnapshot.tempC != null && <div className="flex items-center gap-1 rounded-full bg-white px-2 py-1 shadow-sm"><span className="text-[10px] font-medium">Temp</span><span className="font-mono">{selectedClaim.weatherSnapshot.tempC.toFixed(1)}°C</span></div>}
                      {selectedClaim.weatherSnapshot.humidity != null && <div className="flex items-center gap-1 rounded-full bg-white px-2 py-1 shadow-sm"><span className="text-[10px] font-medium">Humidity</span><span className="font-mono">{selectedClaim.weatherSnapshot.humidity.toFixed(0)}%</span></div>}
                      {selectedClaim.weatherSnapshot.windMs != null && <div className="flex items-center gap-1 rounded-full bg-white px-2 py-1 shadow-sm"><span className="text-[10px] font-medium">Wind</span><span className="font-mono">{selectedClaim.weatherSnapshot.windMs.toFixed(1)} m/s</span></div>}
                      {selectedClaim.weatherSnapshot.condition && <div className="flex items-center gap-1 rounded-full bg-white px-2 py-1 shadow-sm"><span className="text-[10px] font-medium">Condition</span><span>{selectedClaim.weatherSnapshot.condition}</span></div>}
                    </div>
                  </div>
                )}
              </div>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
};

export default CasesPage;

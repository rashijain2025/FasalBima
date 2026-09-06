// src/pages/ClaimsPage.tsx
import React, { useMemo, useState } from "react";
import { Card } from "../components/ui/Card";
import { Pill } from "../components/ui/Pill";
import { severityColor, statusColor } from "../data/mockData";
import { useClaims } from "../hooks/useClaims";
import type { DamageSeverity, ClaimStatus } from "../types/domain";

type Decision = "Approve" | "Reject" | "Field Visit";

export const ClaimsPage: React.FC = () => {
    const { claims: MOCK_CLAIMS, loading, error } = useClaims();
    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error}</div>;
  
  const [query, setQuery] = useState("");
  const [severityFilter, setSeverityFilter] = useState<DamageSeverity | "">("");
  const [statusFilter, setStatusFilter] = useState<ClaimStatus | "">("");
  const [cropFilter, setCropFilter] = useState<string>("");
  const [districtFilter, setDistrictFilter] = useState<string>("");
  const [selectedClaimId, setSelectedClaimId] = useState<string | null>(null);

  const [decisions, setDecisions] = useState<Record<string, Decision>>({});

  const cropOptions = useMemo(
    () => Array.from(new Set(MOCK_CLAIMS.map((c) => c.cropType))).sort(),
    []
  );

  const districtOptions = useMemo(
    () => Array.from(new Set(MOCK_CLAIMS.map((c) => c.district))).sort(),
    []
  );

  const filteredClaims = useMemo(() => {
    return MOCK_CLAIMS.filter((c) => {
      if (severityFilter && c.severity !== severityFilter) return false;
      if (statusFilter && c.status !== statusFilter) return false;
      if (cropFilter && c.cropType !== cropFilter) return false;
      if (districtFilter && c.district !== districtFilter) return false;

      if (query.trim()) {
        const q = query.toLowerCase();
        const blob = `${c.farmerName} ${c.id} ${c.cropType} ${c.village} ${c.district}`.toLowerCase();
        if (!blob.includes(q)) return false;
      }
      return true;
    });
  }, [query, severityFilter, statusFilter, cropFilter, districtFilter]);

  const selectedClaim = useMemo(
    () => filteredClaims.find((c) => c.id === selectedClaimId) || null,
    [filteredClaims, selectedClaimId]
  );

  const handleRowClick = (id: string) => {
    setSelectedClaimId((prev) => (prev === id ? null : id)); // toggle
  };

  const handleDecision = (claimId: string, decision: Decision) => {
    setDecisions((prev) => ({ ...prev, [claimId]: decision }));
  };

  const getDecisionPill = (claimId: string) => {
    const d = decisions[claimId];
    if (!d) return null;

    let className = "bg-slate-200 text-slate-800";
    if (d === "Approve") className = "bg-emerald-600 text-white";
    if (d === "Reject") className = "bg-red-600 text-white";
    if (d === "Field Visit") className = "bg-blue-600 text-white";

    return <Pill className={className}>{d}</Pill>;
  };

  return (
    <div className="space-y-4">
      {/* Filters */}
      <Card>
        <div className="flex flex-wrap items-end gap-3 p-3 text-xs">
          <div className="flex-1 min-w-[200px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">Search</p>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Farmer, claim ID, village..."
              className="w-full rounded-full border border-slate-300 px-3 py-1 text-[11px] outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>

          <div className="min-w-[130px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              Severity
            </p>
            <select
              value={severityFilter}
              onChange={(e) =>
                setSeverityFilter(
                  e.target.value as DamageSeverity | ""
                )
              }
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              <option value="Low">Low</option>
              <option value="Medium">Medium</option>
              <option value="High">High</option>
              <option value="Severe">Severe</option>
            </select>
          </div>

          <div className="min-w-[130px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">Status</p>
            <select
              value={statusFilter}
              onChange={(e) =>
                setStatusFilter(e.target.value as ClaimStatus | "")
              }
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              <option value="Pending">Pending</option>
              <option value="In Review">In Review</option>
              <option value="Approved">Approved</option>
              <option value="Rejected">Rejected</option>
            </select>
          </div>

          <div className="min-w-[140px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">Crop</p>
            <select
              value={cropFilter}
              onChange={(e) => setCropFilter(e.target.value)}
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              {cropOptions.map((crop) => (
                <option key={crop} value={crop}>
                  {crop}
                </option>
              ))}
            </select>
          </div>

          <div className="min-w-[140px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              District
            </p>
            <select
              value={districtFilter}
              onChange={(e) => setDistrictFilter(e.target.value)}
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              {districtOptions.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
          </div>

          <button
            onClick={() => {
              setQuery("");
              setSeverityFilter("");
              setStatusFilter("");
              setCropFilter("");
              setDistrictFilter("");
              setSelectedClaimId(null);
            }}
            className="rounded-full border border-slate-300 px-3 py-1 text-[11px] text-slate-700 hover:bg-slate-50"
          >
            Clear filters
          </button>

          <p className="ml-auto text-[11px] text-slate-500">
            Showing <span className="font-semibold">{filteredClaims.length}</span>{" "}
            claims
          </p>
        </div>
      </Card>

      {/* List + profile layout */}
      <div className="grid gap-4 lg:grid-cols-[minmax(0,1.6fr)_minmax(0,1.2fr)]">
        {/* Claims table */}
        <Card>
          <div className="border-b px-4 py-2 text-[11px] font-semibold text-slate-600">
            Claims
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full border-separate border-spacing-y-1 text-xs">
              <thead className="text-[11px] text-slate-500">
                <tr>
                  <th className="px-3 py-2 text-left">Claim ID</th>
                  <th className="px-3 py-2 text-left">Farmer / Crop</th>
                  <th className="px-3 py-2 text-left">Location</th>
                  <th className="px-3 py-2 text-left">Damage</th>
                  <th className="px-3 py-2 text-left">Severity</th>
                  <th className="px-3 py-2 text-left">Status</th>
                  <th className="px-3 py-2 text-left">Decision</th>
                </tr>
              </thead>
              <tbody>
                {filteredClaims.map((c) => {
                  const isSelected = selectedClaimId === c.id;
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
                        {c.id}
                      </td>
                      <td className="px-3 py-2 align-top">
                        <p className="text-xs font-semibold">{c.farmerName}</p>
                        <p className="text-[11px] text-slate-600">{c.cropType}</p>
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {c.village}, {c.district}
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {c.damageType}
                      </td>
                      <td className="px-3 py-2 align-top">
                        <Pill className={severityColor[c.severity]}>
                          {c.severity}
                        </Pill>
                      </td>
                      <td className="px-3 py-2 align-top">
                        <Pill className={statusColor[c.status]}>{c.status}</Pill>
                      </td>
                      <td className="px-3 py-2 align-top">
                        {getDecisionPill(c.id) || (
                          <span className="text-[10px] text-slate-400">
                            Not taken
                          </span>
                        )}
                      </td>
                    </tr>
                  );
                })}
                {filteredClaims.length === 0 && (
                  <tr>
                    <td
                      colSpan={7}
                      className="px-3 py-4 text-center text-[11px] text-slate-500"
                    >
                      No claims match the current filters.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </Card>

        {/* Claim profile / decisions */}
        {selectedClaim && (
          <Card>
            <div className="flex items-start justify-between border-b px-4 py-3">
              <div>
                <p className="text-sm font-semibold">{selectedClaim.farmerName}</p>
                <p className="text-[11px] text-slate-600">
                  {selectedClaim.cropType} &bull; {selectedClaim.damageType}
                </p>
                <p className="mt-1 text-[11px] text-slate-600">
                  {selectedClaim.village}, {selectedClaim.district}
                </p>
                <p className="mt-1 font-mono text-[11px] text-slate-500">
                  {selectedClaim.id}
                </p>
              </div>
              <button
                onClick={() => setSelectedClaimId(null)}
                className="rounded-full border border-slate-300 px-2 py-1 text-[10px] text-slate-600 hover:bg-slate-50"
              >
                Close profile
              </button>
            </div>

            <div className="space-y-3 px-4 py-3 text-xs">
              <div className="flex gap-4 text-[11px] text-slate-600">
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Severity
                  </p>
                  <Pill className={severityColor[selectedClaim.severity]}>
                    {selectedClaim.severity}
                  </Pill>
                </div>
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Status
                  </p>
                  <Pill className={statusColor[selectedClaim.status]}>
                    {selectedClaim.status}
                  </Pill>
                </div>
              </div>

              <div>
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  Decision on this claim
                </p>
                <div className="flex flex-wrap items-center gap-2">
                  {getDecisionPill(selectedClaim.id) || (
                    <span className="text-[10px] text-slate-400">
                      No decision taken yet.
                    </span>
                  )}
                </div>
                <div className="mt-2 flex flex-wrap gap-2 text-[10px]">
                  <button
                    onClick={() => handleDecision(selectedClaim.id, "Approve")}
                    className="rounded-full bg-emerald-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-emerald-700"
                  >
                    Approve claim
                  </button>
                  <button
                    onClick={() => handleDecision(selectedClaim.id, "Reject")}
                    className="rounded-full bg-red-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-red-700"
                  >
                    Reject claim
                  </button>
                  <button
                    onClick={() =>
                      handleDecision(selectedClaim.id, "Field Visit")
                    }
                    className="rounded-full bg-blue-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-blue-700"
                  >
                    Mark for field visit
                  </button>
                </div>
              </div>

              <div>
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  Timeline
                </p>
                <p className="text-[11px] text-slate-600">
                  Created at:{" "}
                  <span className="font-mono">{selectedClaim.createdAt}</span>
                </p>
                {/* later: add AI model timestamps, inspection dates, etc. */}
              </div>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
};

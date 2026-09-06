// src/pages/FarmersPage.tsx
import React, { useMemo, useState } from "react";
import { Card } from "../components/ui/Card";
import { Pill } from "../components/ui/Pill";
// import { MOCK_FARMERS, MOCK_CLAIMS, severityColor, statusColor } from "../data/mockData";
import { useFarmers } from "../hooks/useFarmers";
import type { DamageSeverity, ClaimStatus } from "../types/domain";

type Decision = "Approve" | "Reject" | "Field Visit";

export const FarmersPage: React.FC = () => {
    const { farmers, loading, error } = useFarmers();
  const [query, setQuery] = useState("");
  const [stateFilter, setStateFilter] = useState<string>("");
  const [districtFilter, setDistrictFilter] = useState<string>("");
  const [selectedFarmerId, setSelectedFarmerId] = useState<string | null>(null);

  // decisions are per-claim, keyed by claim id
  const [decisions, setDecisions] = useState<Record<string, Decision>>({});

  const uniqueStates = useMemo(
    () => Array.from(new Set(farmers.map((f) => f.state))).sort(),
    []
  );

  const uniqueDistricts = useMemo(
    () =>
      Array.from(
        new Set(
          farmers
            .filter((f) => (stateFilter ? f.state === stateFilter : true))
            .map((f) => f.district)
        )
      ).sort(),
    [stateFilter]
  );

  const filteredFarmers = useMemo(() => {
    return farmers.filter((f) => {
      if (stateFilter && f.state !== stateFilter) return false;
      if (districtFilter && f.district !== districtFilter) return false;
      if (query.trim()) {
        const q = query.toLowerCase();
        const blob =
          `${f.name} ${f.village} ${f.district} ${f.state} ${f.phone}`.toLowerCase();
        if (!blob.includes(q)) return false;
      }
      return true;
    });
  }, [query, stateFilter, districtFilter]);

  const selectedFarmer = useMemo(
    () => farmers.find((f) => f.id === selectedFarmerId) || null,
    [selectedFarmerId]
  );

  const selectedFarmerClaims = useMemo(
    () =>
      selectedFarmer
        ? MOCK_CLAIMS.filter((c) => c.farmerName === selectedFarmer.name)
        : [],
    [selectedFarmer]
  );

  const handleRowClick = (id: string) => {
    setSelectedFarmerId((prev) => (prev === id ? null : id)); // toggle
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
      {/* Filters row */}
      <Card>
        <div className="flex flex-wrap items-end gap-3 p-3 text-xs">
          <div className="flex-1 min-w-[180px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              Search farmers
            </p>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Name, village, phone..."
              className="w-full rounded-full border border-slate-300 px-3 py-1 text-[11px] outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>

          <div className="min-w-[140px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">State</p>
            <select
              value={stateFilter}
              onChange={(e) => {
                setStateFilter(e.target.value);
                setDistrictFilter("");
              }}
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              {uniqueStates.map((s) => (
                <option key={s} value={s}>
                  {s}
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
              {uniqueDistricts.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
          </div>

          <button
            onClick={() => {
              setQuery("");
              setStateFilter("");
              setDistrictFilter("");
              setSelectedFarmerId(null);
            }}
            className="rounded-full border border-slate-300 px-3 py-1 text-[11px] text-slate-700 hover:bg-slate-50"
          >
            Clear filters
          </button>

          <p className="ml-auto text-[11px] text-slate-500">
            Showing <span className="font-semibold">{filteredFarmers.length}</span>{" "}
            farmers
          </p>
        </div>
      </Card>

      {/* List + profile layout */}
      <div className="grid gap-4 lg:grid-cols-[minmax(0,1.5fr)_minmax(0,1.2fr)]">
        {/* Farmers list */}
        <Card>
          <div className="border-b px-4 py-2 text-[11px] font-semibold text-slate-600">
            Farmer registry
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full border-separate border-spacing-y-1 text-xs">
              <thead className="text-[11px] text-slate-500">
                <tr>
                  <th className="px-3 py-2 text-left">Farmer</th>
                  <th className="px-3 py-2 text-left">Village / District</th>
                  <th className="px-3 py-2 text-left">State</th>
                  <th className="px-3 py-2 text-right">Open claims</th>
                </tr>
              </thead>
              <tbody>
                {filteredFarmers.map((f) => {
                  const isSelected = selectedFarmerId === f.id;
                  return (
                    <tr
                      key={f.id}
                      onClick={() => handleRowClick(f.id)}
                      className={
                        "cursor-pointer rounded-xl bg-white shadow-sm hover:bg-slate-50 " +
                        (isSelected ? "ring-1 ring-emerald-500" : "")
                      }
                    >
                      <td className="px-3 py-2 align-top">
                        <p className="text-xs font-semibold">{f.name}</p>
                        <p className="mt-0.5 text-[11px] text-slate-600">
                          {f.phone}
                        </p>
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {f.village}, {f.district}
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {f.state}
                      </td>
                      <td className="px-3 py-2 align-top text-right text-[11px] text-slate-700">
                        {f.openClaims}
                      </td>
                    </tr>
                  );
                })}
                {filteredFarmers.length === 0 && (
                  <tr>
                    <td
                      colSpan={4}
                      className="px-3 py-4 text-center text-[11px] text-slate-500"
                    >
                      No farmers match the current filters.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </Card>

        {/* Profile / decision panel */}
        {selectedFarmer && (
          <Card>
            <div className="flex items-start justify-between border-b px-4 py-3">
              <div>
                <p className="text-sm font-semibold">{selectedFarmer.name}</p>
                <p className="text-[11px] text-slate-600">
                  {selectedFarmer.village}, {selectedFarmer.district},{" "}
                  {selectedFarmer.state}
                </p>
                <p className="mt-1 text-[11px] text-slate-600">
                  Phone: <span className="font-mono">{selectedFarmer.phone}</span>
                </p>
              </div>
              <button
                onClick={() => setSelectedFarmerId(null)}
                className="rounded-full border border-slate-300 px-2 py-1 text-[10px] text-slate-600 hover:bg-slate-50"
              >
                Close profile
              </button>
            </div>

            <div className="space-y-3 px-4 py-3 text-xs">
              <div className="flex gap-4 text-[11px] text-slate-600">
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Total crops
                  </p>
                  <p className="text-sm font-semibold">{selectedFarmer.totalCrops}</p>
                </div>
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Open claims
                  </p>
                  <p className="text-sm font-semibold">
                    {selectedFarmer.openClaims}
                  </p>
                </div>
              </div>

              <div>
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  Claims for this farmer
                </p>
                {selectedFarmerClaims.length === 0 && (
                  <p className="text-[11px] text-slate-500">
                    No claims linked to this farmer in the current dataset.
                  </p>
                )}

                <div className="space-y-2">
                  {selectedFarmerClaims.map((c) => (
                    <div
                      key={c.id}
                      className="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2"
                    >
                      <div className="flex items-center justify-between">
                        <p className="font-mono text-[11px] text-slate-700">
                          {c.id}
                        </p>
                        <Pill className={severityColor[c.severity]}>
                          {c.severity}
                        </Pill>
                      </div>
                      <p className="mt-1 text-[11px] text-slate-700">
                        {c.cropType}
                      </p>
                      <p className="text-[11px] text-slate-600">
                        {c.damageType}
                      </p>
                      <div className="mt-1 flex items-center justify-between">
                        <Pill className={statusColor[c.status]}>{c.status}</Pill>
                        <span className="text-[10px] text-slate-500">
                          {c.createdAt}
                        </span>
                      </div>

                      {/* Decision section */}
                      <div className="mt-2 flex flex-wrap items-center gap-2">
                        <span className="text-[10px] text-slate-500">
                          Decision:
                        </span>
                        {getDecisionPill(c.id) || (
                          <span className="text-[10px] text-slate-400">
                            Not taken
                          </span>
                        )}
                      </div>
                      <div className="mt-1 flex flex-wrap gap-2 text-[10px]">
                        <button
                          onClick={() => handleDecision(c.id, "Approve")}
                          className="rounded-full bg-emerald-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-emerald-700"
                        >
                          Approve
                        </button>
                        <button
                          onClick={() => handleDecision(c.id, "Reject")}
                          className="rounded-full bg-red-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-red-700"
                        >
                          Reject
                        </button>
                        <button
                          onClick={() => handleDecision(c.id, "Field Visit")}
                          className="rounded-full bg-blue-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-blue-700"
                        >
                          Mark for field visit
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
};

// src/pages/CropsPage.tsx
import React, { useMemo, useState } from "react";
import { Card } from "../components/ui/Card";
import { Pill } from "../components/ui/Pill";
import { MOCK_CROPS, MOCK_CLAIMS, severityColor, statusColor } from "../data/mockData";

type Decision = "Approve" | "Reject" | "Field Visit";

// infer crop type from mock data
type CropRecord = (typeof MOCK_CROPS)[number];

export const CropsPage: React.FC = () => {
  const [query, setQuery] = useState("");
  const [cropFilter, setCropFilter] = useState<string>("");
  const [healthFilter, setHealthFilter] = useState<string>("");
  const [stateFilter, setStateFilter] = useState<string>("");
  const [selectedCropId, setSelectedCropId] = useState<string | null>(null);

  // decisions keyed by claim id (for claims linked to this crop)
  const [decisions, setDecisions] = useState<Record<string, Decision>>({});

  const cropOptions = useMemo(
    () => Array.from(new Set(MOCK_CROPS.map((c) => c.cropType))).sort(),
    []
  );

  const healthOptions = useMemo(
    () => Array.from(new Set(MOCK_CROPS.map((c) => c.health))).sort(),
    []
  );

  const stateOptions = useMemo(
    () => Array.from(new Set(MOCK_CROPS.map((c) => c.state))).sort(),
    []
  );

  const filteredCrops = useMemo(() => {
    return MOCK_CROPS.filter((c) => {
      if (cropFilter && c.cropType !== cropFilter) return false;
      if (healthFilter && c.health !== healthFilter) return false;
      if (stateFilter && c.state !== stateFilter) return false;

      if (query.trim()) {
        const q = query.toLowerCase();
        const blob = `${c.farmerName} ${c.cropType} ${c.village} ${c.district} ${c.state}`.toLowerCase();
        if (!blob.includes(q)) return false;
      }

      return true;
    });
  }, [query, cropFilter, healthFilter, stateFilter]);

  const selectedCrop: CropRecord | null = useMemo(
    () => filteredCrops.find((c) => c.id === selectedCropId) || null,
    [filteredCrops, selectedCropId]
  );

  // link claims to this crop (by farmer + crop + location)
  const linkedClaims = useMemo(
    () =>
      selectedCrop
        ? MOCK_CLAIMS.filter((cl) => {
            return (
              cl.farmerName === selectedCrop.farmerName &&
              cl.cropType === selectedCrop.cropType &&
              cl.village === selectedCrop.village &&
              cl.district === selectedCrop.district
            );
          })
        : [],
    [selectedCrop]
  );

  const handleRowClick = (id: string) => {
    setSelectedCropId((prev) => (prev === id ? null : id)); // toggle open/close
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
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              Search
            </p>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Farmer, crop, village..."
              className="w-full rounded-full border border-slate-300 px-3 py-1 text-[11px] outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>

          <div className="min-w-[130px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              Crop
            </p>
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

          <div className="min-w-[130px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              Health
            </p>
            <select
              value={healthFilter}
              onChange={(e) => setHealthFilter(e.target.value)}
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              {healthOptions.map((h) => (
                <option key={h} value={h}>
                  {h}
                </option>
              ))}
            </select>
          </div>

          <div className="min-w-[130px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              State
            </p>
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
              setCropFilter("");
              setHealthFilter("");
              setStateFilter("");
              setSelectedCropId(null);
            }}
            className="rounded-full border border-slate-300 px-3 py-1 text-[11px] text-slate-700 hover:bg-slate-50"
          >
            Clear filters
          </button>

          <p className="ml-auto text-[11px] text-slate-500">
            Showing <span className="font-semibold">{filteredCrops.length}</span>{" "}
            crop records
          </p>
        </div>
      </Card>

      {/* List + profile layout */}
      <div className="grid gap-4 lg:grid-cols-[minmax(0,1.6fr)_minmax(0,1.2fr)]">
        {/* Crops table */}
        <Card>
          <div className="border-b px-4 py-2 text-[11px] font-semibold text-slate-600">
            Crop health overview
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full border-separate border-spacing-y-1 text-xs">
              <thead className="text-[11px] text-slate-500">
                <tr>
                  <th className="px-3 py-2 text-left">Farmer</th>
                  <th className="px-3 py-2 text-left">Crop</th>
                  <th className="px-3 py-2 text-left">Health</th>
                  <th className="px-3 py-2 text-left">Location</th>
                </tr>
              </thead>
              <tbody>
                {filteredCrops.map((c) => {
                  const isSelected = selectedCropId === c.id;
                  return (
                    <tr
                      key={c.id}
                      onClick={() => handleRowClick(c.id)}
                      className={
                        "cursor-pointer rounded-xl bg-white shadow-sm hover:bg-slate-50 " +
                        (isSelected ? "ring-1 ring-emerald-500" : "")
                      }
                    >
                      <td className="px-3 py-2 align-top">
                        <p className="text-xs font-semibold">{c.farmerName}</p>
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {c.cropType}
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {c.health}
                      </td>
                      {/* ✅ Location clearly shown */}
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {c.village}, {c.district}, {c.state}
                      </td>
                    </tr>
                  );
                })}
                {filteredCrops.length === 0 && (
                  <tr>
                    <td
                      colSpan={4}
                      className="px-3 py-4 text-center text-[11px] text-slate-500"
                    >
                      No crops match the current filters.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </Card>

        {/* Right-side crop profile / decisions */}
        {selectedCrop && (
          <Card>
            <div className="flex items-start justify-between border-b px-4 py-3">
              <div>
                <p className="text-sm font-semibold">
                  {selectedCrop.cropType}
                </p>
                <p className="text-[11px] text-slate-600">
                  {selectedCrop.farmerName}
                </p>
                <p className="mt-1 text-[11px] text-slate-600">
                  {selectedCrop.village}, {selectedCrop.district},{" "}
                  {selectedCrop.state}
                </p>
              </div>
              <button
                onClick={() => setSelectedCropId(null)}
                className="rounded-full border border-slate-300 px-2 py-1 text-[10px] text-slate-600 hover:bg-slate-50"
              >
                Close profile
              </button>
            </div>

            <div className="space-y-3 px-4 py-3 text-xs">
              {/* Crop health summary */}
              <div className="flex gap-4 text-[11px] text-slate-600">
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Health
                  </p>
                  <p className="text-sm font-semibold">{selectedCrop.health}</p>
                </div>
                {selectedCrop.ndviScore != null && (
                  <div>
                    <p className="text-[10px] uppercase tracking-wide text-slate-500">
                      NDVI score
                    </p>
                    <p className="text-sm font-semibold">
                      {selectedCrop.ndviScore}
                    </p>
                  </div>
                )}
              </div>

              {/* Linked claims and decisions */}
              <div>
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  Linked insurance claims
                </p>
                {linkedClaims.length === 0 && (
                  <p className="text-[11px] text-slate-500">
                    No claims found for this crop in the current dataset.
                  </p>
                )}

                <div className="space-y-2">
                  {linkedClaims.map((c) => (
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

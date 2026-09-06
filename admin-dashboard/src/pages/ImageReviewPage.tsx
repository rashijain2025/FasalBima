// src/pages/ImageReviewPage.tsx
import React, { useMemo, useState } from "react";
import { Card } from "../components/ui/Card";
import { Pill } from "../components/ui/Pill";
import { MOCK_IMAGES, severityColor, statusColor } from "../data/mockData";

type Decision = "Approve" | "Reject" | "Field Visit";

// infer type from mock data
type ReviewImage = (typeof MOCK_IMAGES)[number];

export const ImageReviewPage: React.FC = () => {
  const [query, setQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [cropFilter, setCropFilter] = useState<string>("");
  const [damageFilter, setDamageFilter] = useState<string>("");
  const [selectedImageId, setSelectedImageId] = useState<string | null>(null);

  const [decisions, setDecisions] = useState<Record<string, Decision>>({});

  const statusOptions = useMemo(
    () => Array.from(new Set(MOCK_IMAGES.map((i) => i.reviewStatus))).sort(),
    []
  );

  const cropOptions = useMemo(
    () => Array.from(new Set(MOCK_IMAGES.map((i) => i.cropType))).sort(),
    []
  );

  const damageOptions = useMemo(
    () =>
      Array.from(new Set(MOCK_IMAGES.map((i) => i.damageType || "Unknown"))).sort(),
    []
  );

  const filteredImages = useMemo(() => {
    return MOCK_IMAGES.filter((img) => {
      if (statusFilter && img.reviewStatus !== statusFilter) return false;
      if (cropFilter && img.cropType !== cropFilter) return false;
      if (damageFilter && (img.damageType || "Unknown") !== damageFilter)
        return false;

      if (query.trim()) {
        const q = query.toLowerCase();
        const blob = `${img.farmerName} ${img.cropType} ${img.village} ${img.district} ${img.state}`.toLowerCase();
        if (!blob.includes(q)) return false;
      }

      return true;
    });
  }, [query, statusFilter, cropFilter, damageFilter]);

  const selectedImage: ReviewImage | null = useMemo(
    () => filteredImages.find((i) => i.id === selectedImageId) || null,
    [filteredImages, selectedImageId]
  );

  const handleCardClick = (id: string) => {
    setSelectedImageId((prev) => (prev === id ? null : id)); // toggle
  };

  const handleDecision = (imageId: string, decision: Decision) => {
    setDecisions((prev) => ({ ...prev, [imageId]: decision }));
  };

  const getDecisionPill = (imageId: string) => {
    const d = decisions[imageId];
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
              Review status
            </p>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              {statusOptions.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
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

          <div className="min-w-[150px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              Damage type
            </p>
            <select
              value={damageFilter}
              onChange={(e) => setDamageFilter(e.target.value)}
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              {damageOptions.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
          </div>

          <button
            onClick={() => {
              setQuery("");
              setStatusFilter("");
              setCropFilter("");
              setDamageFilter("");
              setSelectedImageId(null);
            }}
            className="rounded-full border border-slate-300 px-3 py-1 text-[11px] text-slate-700 hover:bg-slate-50"
          >
            Clear filters
          </button>

          <p className="ml-auto text-[11px] text-slate-500">
            Showing <span className="font-semibold">{filteredImages.length}</span>{" "}
            images
          </p>
        </div>
      </Card>

      {/* Grid + profile layout */}
      <div className="grid gap-4 lg:grid-cols-[minmax(0,1.7fr)_minmax(0,1.1fr)]">
        {/* Image cards grid */}
        <div className="grid gap-3 md:grid-cols-2">
          {filteredImages.map((img) => {
            const isSelected = selectedImageId === img.id;
            return (
              <Card
                key={img.id}
                onClick={() => handleCardClick(img.id)}
                className={
                  "cursor-pointer " +
                  (isSelected ? "ring-2 ring-emerald-500" : "")
                }
              >
                <div className="flex flex-col gap-2 p-3 text-xs">
                  <div className="flex items-center justify-between">
                    <p className="text-xs font-semibold">{img.farmerName}</p>
                    <span className="text-[10px] text-slate-500">
                      {img.timestamp}
                    </span>
                  </div>
                  <p className="text-[11px] text-slate-600">
                    {img.cropType} • {img.stage}
                  </p>
                  <p className="text-[11px] text-slate-600">
                    {img.village}, {img.district}, {img.state}
                  </p>
                  <div className="flex flex-wrap gap-1">
                    {img.severity && (
                      <Pill className={severityColor[img.severity]}>
                        {img.severity}
                      </Pill>
                    )}
                    <Pill className={statusColor[img.status]}>
                      {img.status}
                    </Pill>
                    <Pill className="bg-slate-100 text-[10px] text-slate-700">
                      {img.reviewStatus}
                    </Pill>
                    {getDecisionPill(img.id)}
                  </div>
                  {/* Replace with real <img> later */}
                  <div className="mt-1 flex h-32 items-center justify-center rounded-xl bg-slate-200 text-[10px] text-slate-500">
                    Image placeholder
                  </div>
                </div>
              </Card>
            );
          })}
          {filteredImages.length === 0 && (
            <p className="col-span-full text-center text-[11px] text-slate-500">
              No images match the current filters.
            </p>
          )}
        </div>

        {/* Right-side image profile / decisions */}
        {selectedImage && (
          <Card>
            <div className="flex items-start justify-between border-b px-4 py-3">
              <div>
                <p className="text-sm font-semibold">{selectedImage.farmerName}</p>
                <p className="text-[11px] text-slate-600">
                  {selectedImage.cropType} • {selectedImage.stage}
                </p>
                <p className="mt-1 text-[11px] text-slate-600">
                  {selectedImage.village}, {selectedImage.district},{" "}
                  {selectedImage.state}
                </p>
                <p className="mt-1 font-mono text-[11px] text-slate-500">
                  {selectedImage.id}
                </p>
              </div>
              <button
                onClick={() => setSelectedImageId(null)}
                className="rounded-full border border-slate-300 px-2 py-1 text-[10px] text-slate-600 hover:bg-slate-50"
              >
                Close profile
              </button>
            </div>

            <div className="space-y-3 px-4 py-3 text-xs">
              {/* Big image */}
              <div className="h-40 rounded-xl bg-slate-200 text-[10px] text-slate-500 flex items-center justify-center">
                Full-size image placeholder
              </div>

              <div className="flex flex-wrap gap-3 text-[11px] text-slate-600">
                {selectedImage.severity && (
                  <div>
                    <p className="text-[10px] uppercase tracking-wide text-slate-500">
                      Severity
                    </p>
                    <Pill className={severityColor[selectedImage.severity]}>
                      {selectedImage.severity}
                    </Pill>
                  </div>
                )}
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Claim status
                  </p>
                  <Pill className={statusColor[selectedImage.status]}>
                    {selectedImage.status}
                  </Pill>
                </div>
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Review status
                  </p>
                  <Pill className="bg-slate-100 text-[10px] text-slate-700">
                    {selectedImage.reviewStatus}
                  </Pill>
                </div>
                {selectedImage.damageType && (
                  <div>
                    <p className="text-[10px] uppercase tracking-wide text-slate-500">
                      Damage type
                    </p>
                    <p className="text-[11px] text-slate-700">
                      {selectedImage.damageType}
                    </p>
                  </div>
                )}
              </div>

              {/* Decision controls */}
              <div>
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  Decision on this complaint
                </p>
                <div className="flex flex-wrap items-center gap-2">
                  {getDecisionPill(selectedImage.id) || (
                    <span className="text-[10px] text-slate-400">
                      No decision taken yet.
                    </span>
                  )}
                </div>
                <div className="mt-2 flex flex-wrap gap-2 text-[10px]">
                  <button
                    onClick={() => handleDecision(selectedImage.id, "Approve")}
                    className="rounded-full bg-emerald-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-emerald-700"
                  >
                    Approve claim
                  </button>
                  <button
                    onClick={() => handleDecision(selectedImage.id, "Reject")}
                    className="rounded-full bg-red-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-red-700"
                  >
                    Reject claim
                  </button>
                  <button
                    onClick={() =>
                      handleDecision(selectedImage.id, "Field Visit")
                    }
                    className="rounded-full bg-blue-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-blue-700"
                  >
                    Mark for field visit
                  </button>
                </div>
              </div>

              {/* Basic AI info placeholder */}
              <div>
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  AI assessment
                </p>
                <p className="text-[11px] text-slate-600">
                  Model confidence:&nbsp;
                  <span className="font-mono">
                    {selectedImage.aiConfidence ?? "0.93"}
                  </span>
                </p>
                <p className="text-[11px] text-slate-600">
                  Last scored at:&nbsp;
                  <span className="font-mono">{selectedImage.timestamp}</span>
                </p>
              </div>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
};

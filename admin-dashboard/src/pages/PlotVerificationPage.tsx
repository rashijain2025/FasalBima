// // src/pages/PlotVerificationPage.tsx
// import React, { useMemo, useState } from "react";
// import { Card } from "../components/ui/Card";
// import { Pill } from "../components/ui/Pill";
// import {
//   MOCK_PLOTS,
//   type PlotVerificationRecord,
//   type PlotVerificationStatus,
//   type MismatchLevel,
// } from "../data/mockData";
// import { useAdminPlots, verifyPlotRequest } from "../hooks/useAdminPlots";

// type Decision = PlotVerificationStatus; // "Verified" | "Rejected" | "Needs field visit" | "Unverified"

// const mismatchColor: Record<MismatchLevel, string> = {
//   None: "bg-emerald-500 text-white",
//   Low: "bg-yellow-300 text-slate-900",
//   High: "bg-red-700 text-white",
// };

// const statusLabelColor: Record<PlotVerificationStatus, string> = {
//   Unverified: "bg-slate-200 text-slate-800",
//   Verified: "bg-emerald-600 text-white",
//   Rejected: "bg-red-600 text-white",
//   "Needs field visit": "bg-blue-600 text-white",
// };

// // TODO: Populate with actual state options
// const stateOptions = ["State A", "State B", "State C"];

// export const PlotVerificationPage: React.FC = () => {
//     const { plots, setPlots, loading, error } = useAdminPlots();
//     if (loading) {
//   return <div className="p-4 text-sm text-slate-600">Loading plots...</div>;
// }

// if (error) {
//   return (
//     <div className="p-4 text-sm text-red-600">
//       Failed to load plots: {error}
//     </div>
//   );
// }

//   const [query, setQuery] = useState("");
//   const [stateFilter, setStateFilter] = useState<string>("");
//   const [mismatchFilter, setMismatchFilter] =
//     useState<"All" | "OnlyMismatch" | "OnlyClean">("All");
//   const [statusFilter, setStatusFilter] = useState<PlotVerificationStatus | "">(
//     ""
//   );

//   const [selectedPlotId, setSelectedPlotId] = useState<string | null>(null);
//   const [decisions, setDecisions] = useState<Record<string, Decision>>({});

//   const filteredPlots = useMemo(() => {
//   return plots.filter((p) => {
//     if (stateFilter && p.state !== stateFilter) return false;

//     if (statusFilter && p.verificationStatus !== statusFilter) return false;

//     if (mismatchFilter === "OnlyMismatch" && p.mismatchLevel === "None")
//       return false;
//     if (mismatchFilter === "OnlyClean" && p.mismatchLevel !== "None")
//       return false;

//     if (query.trim()) {
//       const q = query.toLowerCase();
//       const blob = `${p.farmerName} ${p.village} ${p.district} ${p.khataNumber} ${p.khasraNumber} ${p.claimId}`.toLowerCase();
//       if (!blob.includes(q)) return false;
//     }

//     return true;
//   });
// }, [plots, query, stateFilter, mismatchFilter, statusFilter]);


//   const selectedPlot: PlotVerificationRecord | null = useMemo(
//     () => filteredPlots.find((p) => p.id === selectedPlotId) || null,
//     [filteredPlots, selectedPlotId]
//   );

//   const handleRowClick = (id: string) => {
//     setSelectedPlotId((prev) => (prev === id ? null : id)); // toggle open/close
//   };

//   const handleDecision = async (plotId: string, decision: Decision) => {
//     setDecisions((prev) => ({ ...prev, [plotId]: decision }));
//     // If you only send "Verified" to backend for now:
//     if (decision === "Verified") {
//       try {
//         await verifyPlotRequest(plotId);

//         // Optimistically update plots array
//         setPlots((prev) =>
//           prev.map((p) =>
//             p.id === plotId
//               ? { ...p, verificationStatus: "Verified" as PlotVerificationStatus }
//               : p
//           )
//         );
//       } catch (err) {
//         console.error(err);
//         // TODO: show toast or error, and maybe revert decision state
//       }
//     }
//   };

//   const getDecisionPill = (plotId: string) => {
//     const d = decisions[plotId];
//     if (!d) return null;
//     return (
//       <Pill className={statusLabelColor[d]}>
//         {d}
//       </Pill>
//     );
//   };

//   return (
//     <div className="space-y-4">
//       {/* Filters */}
//       <Card>
//         <div className="flex flex-wrap items-end gap-3 p-3 text-xs">
//           <div className="flex-1 min-w-[220px]">
//             <p className="mb-1 text-[11px] font-medium text-slate-600">
//               Search plots
//             </p>
//             <input
//               value={query}
//               onChange={(e) => setQuery(e.target.value)}
//               placeholder="Farmer, village, khasra, khata, claim ID..."
//               className="w-full rounded-full border border-slate-300 px-3 py-1 text-[11px] outline-none focus:ring-2 focus:ring-emerald-500"
//             />
//           </div>

//           <div className="min-w-[140px]">
//             <p className="mb-1 text-[11px] font-medium text-slate-600">
//               State
//             </p>
//             <select
//               value={stateFilter}
//               onChange={(e) => setStateFilter(e.target.value)}
//               className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
//             >
//               <option value="">All</option>
//               {stateOptions.map((s) => (
//                 <option key={s} value={s}>
//                   {s}
//                 </option>
//               ))}
//             </select>
//           </div>

//           <div className="min-w-[150px]">
//             <p className="mb-1 text-[11px] font-medium text-slate-600">
//               Area mismatch
//             </p>
//             <select
//               value={mismatchFilter}
//               onChange={(e) =>
//                 setMismatchFilter(
//                   e.target.value as "All" | "OnlyMismatch" | "OnlyClean"
//                 )
//               }
//               className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
//             >
//               <option value="All">All</option>
//               <option value="OnlyMismatch">Only mismatched</option>
//               <option value="OnlyClean">Only clean plots</option>
//             </select>
//           </div>

//           <div className="min-w-[150px]">
//             <p className="mb-1 text-[11px] font-medium text-slate-600">
//               Verification status
//             </p>
//             <select
//               value={statusFilter}
//               onChange={(e) =>
//                 setStatusFilter(
//                   e.target.value as PlotVerificationStatus | ""
//                 )
//               }
//               className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
//             >
//               <option value="">All</option>
//               <option value="Unverified">Unverified</option>
//               <option value="Verified">Verified</option>
//               <option value="Rejected">Rejected</option>
//               <option value="Needs field visit">Needs field visit</option>
//             </select>
//           </div>

//           <button
//             onClick={() => {
//               setQuery("");
//               setStateFilter("");
//               setMismatchFilter("All");
//               setStatusFilter("");
//               setSelectedPlotId(null);
//             }}
//             className="rounded-full border border-slate-300 px-3 py-1 text-[11px] text-slate-700 hover:bg-slate-50"
//           >
//             Clear filters
//           </button>

//           <p className="ml-auto text-[11px] text-slate-500">
//             Showing{" "}
//             <span className="font-semibold">{filteredPlots.length}</span> plots
//           </p>
//         </div>
//       </Card>

//       {/* List + detail layout */}
//       <div className="grid gap-4 lg:grid-cols-[minmax(0,1.7fr)_minmax(0,1.3fr)]">
//         {/* LEFT: plots table */}
//         <Card>
//           <div className="border-b px-4 py-2 text-[11px] font-semibold text-slate-600">
//             Plot verification queue
//           </div>
//           <div className="overflow-x-auto">
//             <table className="min-w-full border-separate border-spacing-y-1 text-xs">
//               <thead className="text-[11px] text-slate-500">
//                 <tr>
//                   <th className="px-3 py-2 text-left">Farmer</th>
//                   <th className="px-3 py-2 text-left">Location</th>
//                   <th className="px-3 py-2 text-left">Khata / Khasra</th>
//                   <th className="px-3 py-2 text-left">Area (ha)</th>
//                   <th className="px-3 py-2 text-left">Mismatch</th>
//                   <th className="px-3 py-2 text-left">Docs</th>
//                   <th className="px-3 py-2 text-left">Decision</th>
//                 </tr>
//               </thead>
//               <tbody>
//                 {filteredPlots.map((p) => {
//                   const isSelected = selectedPlotId === p.id;
//                   const diff = +(p.claimedAreaHa - p.gisAreaHa).toFixed(2);
//                   return (
//                     <tr
//                       key={p.id}
//                       onClick={() => handleRowClick(p.id)}
//                       className={
//                         "cursor-pointer rounded-xl bg-white shadow-sm hover:bg-slate-50 " +
//                         (isSelected ? "ring-1 ring-emerald-500" : "")
//                       }
//                     >
//                       <td className="px-3 py-2 align-top">
//                         <p className="text-xs font-semibold">{p.farmerName}</p>
//                         {p.claimId && (
//                           <p className="font-mono text-[10px] text-slate-500">
//                             {p.claimId}
//                           </p>
//                         )}
//                       </td>
//                       <td className="px-3 py-2 align-top text-[11px] text-slate-600">
//                         {p.village}, {p.district}, {p.state}
//                       </td>
//                       <td className="px-3 py-2 align-top text-[11px] text-slate-600">
//                         Khata {p.khataNumber} <br />
//                         Khasra {p.khasraNumber}
//                       </td>
//                       <td className="px-3 py-2 align-top text-[11px] text-slate-600">
//                         <span className="font-mono">
//                           {p.claimedAreaHa.toFixed(2)}
//                         </span>{" "}
//                         →
//                         <span className="font-mono">
//                           {" "}
//                           {p.gisAreaHa.toFixed(2)}
//                         </span>
//                       </td>
//                       <td className="px-3 py-2 align-top">
//                         <Pill className={mismatchColor[p.mismatchLevel]}>
//                           {p.mismatchLevel}
//                         </Pill>
//                         {diff !== 0 && (
//                           <p className="mt-0.5 text-[10px] text-slate-500">
//                             Δ {diff > 0 ? "+" : ""}
//                             {diff} ha
//                           </p>
//                         )}
//                       </td>
//                       <td className="px-3 py-2 align-top text-[11px] text-slate-600">
//                         {p.documents.length} document
//                         {p.documents.length !== 1 ? "s" : ""}
//                       </td>
//                       <td className="px-3 py-2 align-top">
//                         {getDecisionPill(p.id) || (
//                           <span className="text-[10px] text-slate-400">
//                             Not taken
//                           </span>
//                         )}
//                       </td>
//                     </tr>
//                   );
//                 })}
//                 {filteredPlots.length === 0 && (
//                   <tr>
//                     <td
//                       colSpan={7}
//                       className="px-3 py-4 text-center text-[11px] text-slate-500"
//                     >
//                       No plots match the current filters.
//                     </td>
//                   </tr>
//                 )}
//               </tbody>
//             </table>
//           </div>
//         </Card>

//         {/* RIGHT: detail + documents + decision */}
//         {selectedPlot && (
//           <Card>
//             <div className="flex items-start justify-between border-b px-4 py-3">
//               <div>
//                 <p className="text-sm font-semibold">
//                   {selectedPlot.farmerName}
//                 </p>
//                 <p className="text-[11px] text-slate-600">
//                   {selectedPlot.village}, {selectedPlot.district},{" "}
//                   {selectedPlot.state}
//                 </p>
//                 <p className="mt-1 font-mono text-[11px] text-slate-500">
//                   Plot ID: {selectedPlot.id}
//                   {selectedPlot.claimId && ` • ${selectedPlot.claimId}`}
//                 </p>
//               </div>
//               <button
//                 onClick={() => setSelectedPlotId(null)}
//                 className="rounded-full border border-slate-300 px-2 py-1 text-[10px] text-slate-600 hover:bg-slate-50"
//               >
//                 Close
//               </button>
//             </div>

//             <div className="space-y-3 px-4 py-3 text-xs">
//               {/* Area comparison */}
//               <div className="flex flex-wrap gap-4 text-[11px] text-slate-600">
//                 <div>
//                   <p className="text-[10px] uppercase tracking-wide text-slate-500">
//                     Claimed area (ha)
//                   </p>
//                   <p className="font-mono text-sm">
//                     {selectedPlot.claimedAreaHa.toFixed(2)}
//                   </p>
//                 </div>
//                 <div>
//                   <p className="text-[10px] uppercase tracking-wide text-slate-500">
//                     GIS area (ha)
//                   </p>
//                   <p className="font-mono text-sm">
//                     {selectedPlot.gisAreaHa.toFixed(2)}
//                   </p>
//                 </div>
//                 <div>
//                   <p className="text-[10px] uppercase tracking-wide text-slate-500">
//                     Mismatch
//                   </p>
//                   <Pill className={mismatchColor[selectedPlot.mismatchLevel]}>
//                     {selectedPlot.mismatchLevel}
//                   </Pill>
//                   {selectedPlot.mismatchReason && (
//                     <p className="mt-0.5 text-[10px] text-slate-500">
//                       {selectedPlot.mismatchReason}
//                     </p>
//                   )}
//                 </div>
//                 <div>
//                   <p className="text-[10px] uppercase tracking-wide text-slate-500">
//                     Status
//                   </p>
//                   <Pill
//                     className={statusLabelColor[selectedPlot.verificationStatus]}
//                   >
//                     {selectedPlot.verificationStatus}
//                   </Pill>
//                 </div>
//               </div>

//               {/* Documents */}
//               <div>
//                 <p className="mb-1 text-[11px] font-semibold text-slate-700">
//                   Uploaded documents ({selectedPlot.documents.length})
//                 </p>
//                 {selectedPlot.documents.length === 0 && (
//                   <p className="text-[11px] text-slate-500">
//                     No documents uploaded for this plot.
//                   </p>
//                 )}
//                 <div className="space-y-2">
//                   {selectedPlot.documents.map((doc) => (
//                     <Card key={doc.id}>
//                       <div className="flex items-start justify-between p-2 text-[11px]">
//                         <div>
//                           <p className="font-semibold">{doc.docType}</p>
//                           <p className="font-mono text-[10px] text-slate-500">
//                             {doc.docNumber}
//                           </p>
//                           <p className="mt-0.5 text-[10px] text-slate-500">
//                             Uploaded: {doc.uploadedAt}
//                           </p>
//                           <p className="mt-0.5 text-[10px] text-slate-500">
//                             {doc.fileName}
//                           </p>
//                         </div>
//                         <button
//                           className="rounded-full border border-slate-300 px-3 py-1 text-[10px] text-slate-700 hover:bg-slate-50"
//                           type="button"
//                         >
//                           View document
//                         </button>
//                       </div>
//                       {/* Placeholder viewer area */}
//                       <div className="mx-2 mb-2 flex h-24 items-center justify-center rounded-lg bg-slate-200 text-[10px] text-slate-500">
//                         Document preview placeholder (PDF / image)
//                       </div>
//                     </Card>
//                   ))}
//                 </div>
//               </div>

//               {/* Decision */}
//               <div className="border-t pt-2">
//                 <p className="mb-1 text-[11px] font-semibold text-slate-700">
//                   Verification decision
//                 </p>
//                 <div className="flex flex-wrap items-center gap-2">
//                   {getDecisionPill(selectedPlot.id) || (
//                     <span className="text-[10px] text-slate-400">
//                       No decision taken yet.
//                     </span>
//                   )}
//                 </div>
//                 <div className="mt-2 flex flex-wrap gap-2 text-[10px]">
//                   <button
//                     onClick={() =>
//                       handleDecision(selectedPlot.id, "Verified")
//                     }
//                     className="rounded-full bg-emerald-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-emerald-700"
//                   >
//                     Mark as verified
//                   </button>
//                   <button
//                     onClick={() =>
//                       handleDecision(selectedPlot.id, "Rejected")
//                     }
//                     className="rounded-full bg-red-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-red-700"
//                   >
//                     Reject documents
//                   </button>
//                   <button
//                     onClick={() =>
//                       handleDecision(selectedPlot.id, "Needs field visit")
//                     }
//                     className="rounded-full bg-blue-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-blue-700"
//                   >
//                     Mark for field visit
//                   </button>
//                 </div>
//               </div>
//             </div>
//           </Card>
//         )}
//       </div>
//     </div>
//   );
// };



// src/pages/PlotVerificationPage.tsx
import React, { useEffect, useMemo, useState } from "react";
import { Card } from "../components/ui/Card";
import { Pill } from "../components/ui/Pill";
import {
  MOCK_PLOTS,
  type PlotVerificationRecord,
  type PlotVerificationStatus,
  type PlotDocument,
} from "../data/mockData";
import { api } from "../lib/api";

type Decision = PlotVerificationStatus; // "Verified" | "Rejected" | "Needs field visit" | "Unverified"

// Mismatch UI removed

const statusLabelColor: Record<PlotVerificationStatus, string> = {
  Unverified: "bg-slate-200 text-slate-800",
  Verified: "bg-emerald-600 text-white",
  Rejected: "bg-red-600 text-white",
  "Needs field visit": "bg-blue-600 text-white",
};

// This should approximately match your backend PlotResponse
type BackendPlot = {
  id: string;
  plot_name?: string | null;
  address?: string | null;
  village?: string | null;
  district?: string | null;
  state?: string | null;
  area_hectares?: number | null;
  land_document_url?: string | null;
  land_document_type?: string | null;
  is_verified: boolean;
  verification_notes?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
  // If you later join claim + documents in backend, extend this type
};

// ---- API helpers ----

async function fetchAdminPlots(): Promise<PlotVerificationRecord[]> {
  try {
    const backendPlots = await api<BackendPlot[]>("/api/admin/dashboard/plots");
    if (Array.isArray(backendPlots) && backendPlots.length > 0) {
      const mapped: PlotVerificationRecord[] = backendPlots.map((p) => {
        const area = p.area_hectares ?? 0;
        const mismatchLevel: MismatchLevel = "None";
        const verificationStatus: PlotVerificationStatus = p.is_verified
          ? "Verified"
          : "Unverified";

        const documents: PlotDocument[] = (() => {
          const url = p.land_document_url ?? undefined;
          if (!url) return [];
          const uploadedAt = (p.updated_at ?? p.created_at ?? new Date().toISOString()).slice(0, 10);
          const fileName = (() => {
            try {
              const u = new URL(url);
              return u.pathname.split("/").pop() || "document";
            } catch {
              return "document";
            }
          })();
          return [
            {
              id: `${p.id}-doc-1`,
              plotId: p.id,
              docType: (p.land_document_type as PlotDocument["docType"]) || "Land record",
              docNumber: "-",
              uploadedAt,
              fileName,
              fileUrl: url,
            },
          ];
        })();

        const createdAt = p.created_at ?? new Date().toISOString().slice(0, 10);
        const lastUpdated = p.updated_at ?? p.created_at ?? new Date().toISOString().slice(0, 10);

        return {
          id: p.id,
          claimId: undefined,
          farmerName: p.plot_name ?? "Plot #" + p.id.slice(0, 5),
          village: p.village ?? (p.address ?? "Village A"),
          district: p.district ?? "District X",
          state: p.state ?? "Haryana",
          khataNumber: "KHT-" + Math.floor(100 + Math.random() * 900),
          khasraNumber: "KHS-" + Math.floor(100 + Math.random() * 900),
          claimedAreaHa: area,
          gisAreaHa: area,
          mismatchLevel,
          mismatchReason: p.verification_notes ?? undefined,
          verificationStatus,
          createdAt,
          lastUpdated,
          documents,
        };
      });
      return mapped;
    }
  } catch (err) {
    console.warn("fetchAdminPlots failed, using fallback data:", err);
  }
  return MOCK_PLOTS;
}

async function verifyPlot(plotId: string): Promise<void> {
  await api<{ message: string }>(`/api/plots/${plotId}/admin-verify`, {
    method: "POST",
  });
}

// ---- Page component ----

export const PlotVerificationPage: React.FC = () => {
  const [plots, setPlots] = useState<PlotVerificationRecord[]>(MOCK_PLOTS);
  const [loading, setLoading] = useState(false);
  const [error] = useState<string | null>(null);

  const [query, setQuery] = useState("");
  const [stateFilter, setStateFilter] = useState<string>("");
  const [statusFilter, setStatusFilter] = useState<
    PlotVerificationStatus | ""
  >("");

  const [selectedPlotId, setSelectedPlotId] = useState<string | null>(null);
  const [decisions, setDecisions] = useState<Record<string, Decision>>({});

  // ---- Load plots from backend or mock on mount ----
  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const mapped = await fetchAdminPlots();
        if (!cancelled) {
          const finalPlots = mapped.length > 0 ? mapped : MOCK_PLOTS;
          setPlots(finalPlots);
          const initialDecisions = Object.fromEntries(
            finalPlots
              .filter((p) => p.verificationStatus !== "Unverified")
              .map((p) => [p.id, p.verificationStatus])
          );
          setDecisions(initialDecisions);
        }
      } catch {
        if (!cancelled) {
          setPlots(MOCK_PLOTS);
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

  const filteredPlots = useMemo(() => {
  // ---- 1) Sort by createdAt descending ----
  const sorted = [...plots].sort(
    (a, b) =>
      new Date(b.createdAt).getTime() -
      new Date(a.createdAt).getTime()
  );
    return sorted.filter((p) => {
    if (stateFilter && p.state !== stateFilter) return false;

    if (statusFilter && p.verificationStatus !== statusFilter) return false;

    if (query.trim()) {
      const q = query.toLowerCase();
      const blob = `${p.farmerName} ${p.village} ${p.district} ${p.claimId ?? ""}`.toLowerCase();
      if (!blob.includes(q)) return false;
    }

    return true;
  });
}, [plots, query, stateFilter, statusFilter]);

  const selectedPlot: PlotVerificationRecord | null = useMemo(
    () => filteredPlots.find((p) => p.id === selectedPlotId) || null,
    [filteredPlots, selectedPlotId]
  );

  const handleRowClick = (id: string) => {
    setSelectedPlotId((prev) => (prev === id ? null : id)); // toggle open/close
  };

  const handleDecision = async (plotId: string, decision: Decision) => {
    setDecisions((prev) => ({ ...prev, [plotId]: decision }));

    // Optimistic update for all decisions (Verified, Rejected, Needs field visit)
    setPlots((prev) =>
      prev.map((p) =>
        p.id === plotId
          ? {
              ...p,
              verificationStatus: decision as PlotVerificationStatus,
            }
          : p
      )
    );

    if (decision === "Verified") {
      try {
        await verifyPlot(plotId);
      } catch (err) {
        console.warn("verifyPlot offline fallback:", err);
      }
    }
  };

  const getDecisionPill = (plotId: string) => {
    const d = decisions[plotId];
    if (!d) return null;
    return <Pill className={statusLabelColor[d]}>{d}</Pill>;
  };

  // ---- Loading / error states ----
  if (loading) {
    return (
      <div className="p-4 text-sm text-slate-600">
        Loading plots for verification...
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 text-sm text-red-600">
        Failed to load plots: {error}
      </div>
    );
  }

  // ---- Main UI ----
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-lg font-semibold text-slate-900">
          Plot verification
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Review farmer-submitted plot boundaries against GIS area and mark
          plots as verified, rejected or requiring field visit.
        </p>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex flex-wrap items-end gap-3 p-3">
          <div className="min-w-[200px] flex-1">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              Search by farmer, village, claim ID
            </p>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="e.g. Ram, Kota, C-001"
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            />
          </div>

          <div className="min-w-[160px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              State
            </p>
            <input
              value={stateFilter}
              onChange={(e) => setStateFilter(e.target.value)}
              placeholder="All states"
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            />
          </div>

          

          <div className="min-w-[150px]">
            <p className="mb-1 text-[11px] font-medium text-slate-600">
              Verification status
            </p>
            <select
              value={statusFilter}
              onChange={(e) =>
                setStatusFilter(
                  e.target.value as PlotVerificationStatus | ""
                )
              }
              className="w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option value="">All</option>
              <option value="Unverified">Unverified</option>
              <option value="Verified">Verified</option>
              <option value="Rejected">Rejected</option>
              <option value="Needs field visit">Needs field visit</option>
            </select>
          </div>

          <button
            onClick={() => {
              setQuery("");
              setStateFilter("");
              setStatusFilter("");
              setSelectedPlotId(null);
            }}
            className="rounded-full border border-slate-300 px-3 py-1 text-[11px] text-slate-700 hover:bg-slate-50"
          >
            Clear filters
          </button>

          <p className="ml-auto text-[11px] text-slate-500">
            Showing{" "}
            <span className="font-semibold">
              {filteredPlots.length}
            </span>{" "}
            plots
          </p>
        </div>
      </Card>

      {/* List + detail layout */}
      <div className="grid gap-4 lg:grid-cols-[minmax(0,1.7fr)_minmax(0,1.3fr)]">
        {/* LEFT: plots table */}
        <Card>
          <div className="border-b border-slate-200 px-3 py-2">
            <p className="text-[11px] font-medium uppercase tracking-wide text-slate-500">
              Plots requiring verification
            </p>
          </div>
          <div className="max-h-[480px] overflow-auto">
            <table className="min-w-full border-collapse text-[11px]">
              <thead className="text-[11px] text-slate-500">
              <tr>
                  <th className="px-3 py-2 text-left">Farmer</th>
                  <th className="px-3 py-2 text-left">Location</th>
                  <th className="px-3 py-2 text-left">Area (ha)</th>
                  <th className="px-3 py-2 text-left">Docs</th>
                  <th className="px-3 py-2 text-left">Decision</th>
              </tr>
              </thead>
              <tbody>
                {filteredPlots.map((p) => {
                  const isSelected = selectedPlotId === p.id;
                  const diff = +(p.claimedAreaHa - p.gisAreaHa).toFixed(2);

                  return (
                    <tr
                      key={p.id}
                      className={`cursor-pointer border-t border-slate-100 hover:bg-slate-50 ${
                        isSelected ? "bg-slate-50" : ""
                      }`}
                      onClick={() => handleRowClick(p.id)}
                    >
                      <td className="px-3 py-2 align-top">
                        <div className="font-semibold text-slate-900">
                          {p.farmerName}
                        </div>
                        <div className="mt-0.5 text-[10px] text-slate-500">
                          Plot ID: {p.id}
                          {p.claimId && ` • ${p.claimId}`}
                        </div>
                        <div className="mt-0.5 text-[10px] text-slate-400">
                          Created: {p.createdAt}
                        </div>
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {p.village}, {p.district}, {p.state}
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        <span className="font-mono">
                          {p.claimedAreaHa.toFixed(2)}
                        </span>{" "}
                        →
                        <span className="font-mono">
                          {" "}
                          {p.gisAreaHa.toFixed(2)}
                        </span>
                        <span className="ml-1 text-[10px] text-slate-500">
                          ({(p.claimedAreaHa * 2.471).toFixed(2)} → {(p.gisAreaHa * 2.471).toFixed(2)} acres)
                        </span>
                        {diff !== 0 && (
                          <p className="mt-0.5 text-[10px] text-slate-500">
                            Δ {diff > 0 ? "+" : ""}
                            {diff} ha
                          </p>
                        )}
                      </td>
                      <td className="px-3 py-2 align-top text-[11px] text-slate-600">
                        {p.documents.length} document
                        {p.documents.length !== 1 ? "s" : ""}
                      </td>
                      <td className="px-3 py-2 align-top">
                        {getDecisionPill(p.id) || (
                          <span className="text-[10px] text-slate-400">
                            Not taken
                          </span>
                        )}
                      </td>
                    </tr>
                  );
                })}

                {filteredPlots.length === 0 && (
                  <tr>
                    <td
                      colSpan={5}
                      className="px-3 py-6 text-center text-[11px] text-slate-500"
                    >
                      No plots match the current filters.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </Card>

        {/* RIGHT: detail + documents + decision */}
        {selectedPlot && (
          <Card>
            <div className="flex items-start justify-between border-b px-4 py-3">
              <div>
                <p className="text-sm font-semibold">
                  {selectedPlot.farmerName}
                </p>
                <p className="text-[11px] text-slate-600">
                  {selectedPlot.village}, {selectedPlot.district},{" "}
                  {selectedPlot.state}
                </p>
                <p className="mt-1 font-mono text-[11px] text-slate-500">
                  Plot ID: {selectedPlot.id}
                  {selectedPlot.claimId && ` • ${selectedPlot.claimId}`}
                </p>
              </div>
              <button
                onClick={() => setSelectedPlotId(null)}
                className="rounded-full border border-slate-300 px-2 py-1 text-[10px] text-slate-600 hover:bg-slate-50"
              >
                Close
              </button>
            </div>

            <div className="space-y-3 p-3">
              {/* Summary */}
              <div className="grid grid-cols-2 gap-3 text-[11px] text-slate-700">
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Claimed / GIS area (ha)
                  </p>
                  <p className="font-mono text-sm">
                    {selectedPlot.claimedAreaHa.toFixed(2)} →{" "}
                    {selectedPlot.gisAreaHa.toFixed(2)}
                    <span className="ml-1 text-[10px] text-slate-500">
                      ({(selectedPlot.claimedAreaHa * 2.471).toFixed(2)} → {(selectedPlot.gisAreaHa * 2.471).toFixed(2)} acres)
                    </span>
                  </p>
                </div>
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Created / Updated
                  </p>
                  <p>
                    {selectedPlot.createdAt} • {selectedPlot.lastUpdated}
                  </p>
                </div>
                <div>
                  
                </div>
                <div>
                  <p className="text-[10px] uppercase tracking-wide text-slate-500">
                    Status
                  </p>
                  <Pill
                    className={
                      statusLabelColor[selectedPlot.verificationStatus]
                    }
                  >
                    {selectedPlot.verificationStatus}
                  </Pill>
                </div>
              </div>

              {/* Documents */}
              <div>
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  Uploaded documents ({selectedPlot.documents.length})
                </p>
                {selectedPlot.documents.length === 0 && (
                  <p className="text-[11px] text-slate-500">
                    No documents uploaded for this plot.
                  </p>
                )}
                <div className="space-y-2">
                  {selectedPlot.documents.map((doc) => (
                    <Card key={doc.id}>
                      <div className="flex items-start justify-between p-2 text-[11px]">
                        <div>
                          <p className="font-semibold">{doc.docType}</p>
                          <p className="font-mono text-[10px] text-slate-500">
                            {doc.docNumber}
                          </p>
                          <p className="mt-0.5 text-[10px] text-slate-500">
                            Uploaded: {doc.uploadedAt}
                          </p>
                          <p className="mt-0.5 text-[10px] text-slate-500">
                            {doc.fileName}
                          </p>
                        </div>
                        <button
                          className="rounded-full border border-slate-300 px-3 py-1 text-[10px] text-slate-700 hover:bg-slate-50"
                          type="button"
                          onClick={() => {
                            if (doc.fileUrl) {
                              window.open(doc.fileUrl, "_blank");
                            }
                          }}
                        >
                          View document
                        </button>
                      </div>
                      {/* Placeholder viewer area */}
                      <div className="mx-2 mb-2 flex h-24 items-center justify-center rounded-lg bg-slate-200 text-[10px] text-slate-500">
                        Document preview placeholder (PDF / image)
                      </div>
                    </Card>
                  ))}
                </div>
              </div>

              {/* Decision */}
              <div className="border-t pt-2">
                <p className="mb-1 text-[11px] font-semibold text-slate-700">
                  Verification decision
                </p>
                <div className="flex flex-wrap items-center gap-2">
                  {getDecisionPill(selectedPlot.id) || (
                    <span className="text-[10px] text-slate-400">
                      No decision taken yet.
                    </span>
                  )}
                </div>
                <div className="mt-2 flex flex-wrap gap-2 text-[10px]">
                  <button
                    onClick={() =>
                      handleDecision(selectedPlot.id, "Verified")
                    }
                    className="rounded-full bg-emerald-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-emerald-700"
                  >
                    Mark as verified
                  </button>
                  <button
                    onClick={() =>
                      handleDecision(selectedPlot.id, "Rejected")
                    }
                    className="rounded-full bg-red-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-red-700"
                  >
                    Reject documents
                  </button>
                  <button
                    onClick={() =>
                      handleDecision(selectedPlot.id, "Needs field visit")
                    }
                    className="rounded-full bg-blue-600 px-3 py-1 text-[10px] font-medium text-white hover:bg-blue-700"
                  >
                    Mark for field visit
                  </button>
                </div>
              </div>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
};

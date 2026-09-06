// // src/pages/MapPage.tsx
// import React, { useEffect, useMemo, useRef, useState } from "react";
// import { useLocation } from "react-router-dom";
// import L, { Map as LeafletMap, LayerGroup, LatLngBounds } from "leaflet";
// import "leaflet/dist/leaflet.css";

// import { Card } from "../components/ui/Card";
// import { Pill } from "../components/ui/Pill";
// import { MOCK_FARMERS, severityColor, statusColor } from "../data/mockData";
// import type { Claim, Farmer, DamageSeverity, ClaimStatus } from "../types/domain";
// import { Info } from "lucide-react";
// import { api } from "../lib/api";

// // ---------------------------------------------------------
// // Types + mapping from backend
// // ---------------------------------------------------------

// type Decision = "Approve" | "Reject" | "Field Visit";

// type BackendClaim = {
//   id: string;
//   status: string;
//   severity?: string | null;
//   damage_type?: string | null;
//   claim_reason?: string | null;
//   crop_type?: string | null;
//   farmer_name?: string | null;
//   village?: string | null;
//   district?: string | null;
//   lat?: number | null;
//   lng?: number | null;
//   created_at?: string | null;
// };

// // Map backend ➜ frontend Claim (types/domain.ts)
// function mapBackendClaim(b: BackendClaim): Claim {
//   const status: ClaimStatus = (() => {
//     const s = (b.status || "pending").toLowerCase();
//     if (s.includes("approved")) return "Approved";
//     if (s.includes("rejected")) return "Rejected";
//     if (s.includes("review")) return "In Review";
//     return "Pending";
//   })();

//   const severity: DamageSeverity = (() => {
//     const s = (b.severity || "medium").toLowerCase();
//     if (s.includes("severe")) return "Severe";
//     if (s.includes("high")) return "High";
//     if (s.includes("low")) return "Low";
//     return "Medium";
//   })();

//   return {
//     id: String(b.id),
//     farmerName: b.farmer_name ?? "Unknown farmer",
//     cropType: b.crop_type ?? "Unknown crop",
//     damageType:
//       b.damage_type ?? b.claim_reason ?? "Unknown damage / claim reason",
//     severity,
//     status,
//     createdAt: b.created_at ?? new Date().toISOString(),
//     village: b.village ?? "",
//     district: b.district ?? "",
//     lat: typeof b.lat === "number" ? b.lat : undefined,
//     lng: typeof b.lng === "number" ? b.lng : undefined,
//   };
// }

// async function fetchAdminClaims(): Promise<Claim[]> {
//   const backendClaims = await api<BackendClaim[]>("/api/claim/admin/map");
//   return backendClaims.map(mapBackendClaim);
// }

// async function verifyClaimStatus(claimId: string, decision: Decision) {
//   if (decision === "Field Visit") return; // local only for now

//   const approved = decision === "Approve";
//   const qs = new URLSearchParams({ approve: String(approved) }).toString();

//   await api<{ message: string }>(
//     `/api/claim/${claimId}/admin-review?${qs}`,
//     { method: "POST" }
//   );
// }

// // ---------------------------------------------------------
// // Component
// // ---------------------------------------------------------

// export const MapPage: React.FC = () => {
//   const location = useLocation();
//   const [query, setQuery] = useState("");
//   const [claims, setClaims] = useState<Claim[]>([]);
//   const [loading, setLoading] = useState(true);
//   const [error, setError] = useState<string | null>(null);

//   const [selectedClaim, setSelectedClaim] = useState<Claim | null>(null);
//   const [decisions, setDecisions] = useState<Record<string, Decision>>({});

//   const mapRef = useRef<LeafletMap | null>(null);
//   const mapContainerRef = useRef<HTMLDivElement | null>(null);
//   const markersLayerRef = useRef<LayerGroup | null>(null);
//   const [mapBounds, setMapBounds] = useState<LatLngBounds | null>(null);

//   // ---- Fetch claims from backend ----
//   useEffect(() => {
//     let cancelled = false;

//     (async () => {
//       try {
//         const mapped = await fetchAdminClaims();
//         if (!cancelled) {
//           setClaims(mapped);
//         }
//       } catch (err: any) {
//         if (!cancelled) {
//           setError(err.message ?? "Failed to load claims");
//         }
//       } finally {
//         if (!cancelled) {
//           setLoading(false);
//         }
//       }
//     })();

//     return () => {
//       cancelled = true;
//     };
//   }, []);

//   // Select claim from URL query (id=...)
//   useEffect(() => {
//     const params = new URLSearchParams(location.search);
//     const id = params.get("id");
//     if (!id || claims.length === 0) return;
//     const found = claims.find((c) => c.id === id);
//     if (found) setSelectedClaim(found);
//   }, [location.search, claims]);

//   // Local decision state + backend update
//   const handleDecision = async (claimId: string, decision: Decision) => {
//     setDecisions((prev) => ({ ...prev, [claimId]: decision }));

//     if (decision === "Approve" || decision === "Reject") {
//       try {
//         await verifyClaimStatus(claimId, decision);
//         // optimistic status update
//         setClaims((prev) =>
//           prev.map((c) =>
//             c.id === claimId
//               ? {
//                   ...c,
//                   status:
//                     decision === "Approve"
//                       ? ("Approved" as ClaimStatus)
//                       : ("Rejected" as ClaimStatus),
//                 }
//               : c
//           )
//         );
//       } catch (err) {
//         console.error(err);
//         // optional: toast + revert
//       }
//     }
//   };

//   const getDecisionPill = (claimId: string) => {
//     const d = decisions[claimId];
//     if (!d) return null;

//     let className = "bg-slate-200 text-slate-800";
//     if (d === "Approve") className = "bg-emerald-600 text-white";
//     if (d === "Reject") className = "bg-red-600 text-white";
//     if (d === "Field Visit") className = "bg-blue-600 text-white";

//     return (
//       <span className={`rounded-full px-2 py-0.5 text-[10px] ${className}`}>
//         {d}
//       </span>
//     );
//   };

//   // ---- Data derived from claims ----

//   const claimsWithCoords = useMemo(
//     () =>
//       claims.filter(
//         (c) => typeof c.lat === "number" && typeof c.lng === "number"
//       ),
//     [claims]
//   );

//   const filteredClaims = useMemo(() => {
//     if (!query.trim()) return claimsWithCoords;
//     const q = query.toLowerCase();

//     return claimsWithCoords.filter((c) => {
//       return (
//         c.farmerName.toLowerCase().includes(q) ||
//         c.cropType.toLowerCase().includes(q) ||
//         c.village.toLowerCase().includes(q) ||
//         c.district.toLowerCase().includes(q) ||
//         c.id.toLowerCase().includes(q)
//       );
//     });
//   }, [claimsWithCoords, query]);

//   const selectedFarmer: Farmer | null = useMemo(() => {
//     if (!selectedClaim) return null;
//     return (
//       MOCK_FARMERS.find(
//         (f) =>
//           f.name === selectedClaim.farmerName &&
//           f.village === selectedClaim.village &&
//           f.district === selectedClaim.district
//       ) || null
//     );
//   }, [selectedClaim]);

//   const mapCenter: [number, number] = useMemo(() => {
//     if (selectedClaim && selectedClaim.lat != null && selectedClaim.lng != null) {
//       return [selectedClaim.lat, selectedClaim.lng];
//     }
//     // central India default
//     return [22.9734, 78.6569];
//   }, [selectedClaim]);

//   // ---- Leaflet map setup ----

//   // Initialize map once
//   useEffect(() => {
//     if (mapRef.current || !mapContainerRef.current) return;

//     const map = L.map(mapContainerRef.current, {
//       preferCanvas: true,
//       zoomControl: true,
//       zoomAnimation: false,
//       fadeAnimation: false,
//     }).setView(mapCenter, 5);
//     mapRef.current = map;

//     const tiles = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
//       attribution: '&copy; <a href="https://osm.org/copyright">OSM</a>',
//       crossOrigin: true,
//       detectRetina: true,
//     });
//     const fallbackTiles = L.tileLayer(
//       "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
//       { crossOrigin: true }
//     );
//     tiles.on("load", () => {
//       try {
//         map.invalidateSize(true);
//       } catch {}
//     });
//     tiles.on("tileerror", () => {
//       try {
//         if (!map.hasLayer(fallbackTiles)) {
//           fallbackTiles.addTo(map);
//         }
//       } catch {}
//     });
//     tiles.addTo(map);

//     markersLayerRef.current = L.layerGroup().addTo(map);

//     requestAnimationFrame(() => {
//       try {
//         map.invalidateSize(true);
//       } catch {}
//     });

//     setMapBounds(map.getBounds());
//     map.on("moveend", () => {
//       try {
//         setMapBounds(map.getBounds());
//       } catch {}
//     });

//     const el = mapContainerRef.current;
//     let ro: ResizeObserver | null = null;
//     if (el) {
//       ro = new ResizeObserver(() => {
//         try {
//           map.invalidateSize(true);
//         } catch {}
//       });
//       ro.observe(el);
//     }

//     const onResize = () => {
//       try {
//         map.invalidateSize(true);
//       } catch {}
//     };
//     window.addEventListener("resize", onResize);

//     return () => {
//       window.removeEventListener("resize", onResize);
//       if (ro) ro.disconnect();
//       map.remove();
//       mapRef.current = null;
//     };
//     // eslint-disable-next-line react-hooks/exhaustive-deps
//   }, []);

//   // Recenter map when selectedClaim changes
//   useEffect(() => {
//     if (!mapRef.current) return;
//     const map = mapRef.current;
//     map.setView(mapCenter, selectedClaim ? 7 : 5);
//     try {
//       map.invalidateSize(true);
//     } catch {}
//   }, [mapCenter, selectedClaim]);

//   // Render markers whenever filteredClaims or bounds change
//   useEffect(() => {
//     if (!markersLayerRef.current || !mapRef.current) return;
//     const layer = markersLayerRef.current;

//     layer.clearLayers();

//     const claimsToRender = (() => {
//       if (mapBounds) {
//         return filteredClaims.filter(
//           (c) =>
//             c.lat != null &&
//             c.lng != null &&
//             mapBounds.contains([c.lat!, c.lng!])
//         );
//       }
//       return filteredClaims;
//     })();

//     claimsToRender.forEach((c) => {
//       if (c.lat == null || c.lng == null) return;

//       const color = statusColor[c.status].includes("red")
//         ? "#dc2626"
//         : statusColor[c.status].includes("emerald")
//         ? "#059669"
//         : statusColor[c.status].includes("blue")
//         ? "#2563eb"
//         : "#6b7280";

//       const circle = L.circleMarker([c.lat, c.lng], {
//         radius: 5,
//         color,
//         weight: 1,
//         fillColor: color,
//         fillOpacity: 0.7,
//         bubblingMouseEvents: true,
//       })
//         .addTo(layer)
//         .on("click", () => {
//           setSelectedClaim(c);
//         });

//       circle.bindPopup(
//         `<div style="font-size:11px;">
//           <div style="font-weight:600;">${c.farmerName}</div>
//           <div style="color:#4b5563;">${c.cropType}</div>
//           <div style="color:#6b7280;font-size:10px;">${c.village}, ${c.district}</div>
//           <div style="color:#9ca3af;font-family:monospace;font-size:10px;margin-top:4px;">${c.id}</div>
//         </div>`
//       );
//     });
//   }, [filteredClaims, mapBounds]);

//   // ---- UI ----

//   return (
//     <div className="grid h-[calc(100vh-96px)] grid-cols-[320px,1fr] gap-4">
//       {/* Sidebar */}
//       <div className="flex h-full flex-col">
//         <Card className="flex-1">
//           <div className="border-b px-4 py-3">
//             <h2 className="text-sm font-semibold">Fasal Bima Geo View</h2>
//             <p className="text-[11px] text-slate-500">
//               Visualize crop insurance claims on the map.
//             </p>

//             {loading && (
//               <p className="mt-1 text-[11px] text-emerald-600">
//                 Loading claims from server...
//               </p>
//             )}

//             {error && !loading && (
//               <p className="mt-1 text-[11px] text-red-600">
//                 Failed to load claims: {error}
//               </p>
//             )}
//           </div>

//           <div className="flex h-full flex-col gap-3 px-4 py-3 text-xs overflow-y-auto">
//             {/* Search */}
//             <div>
//               <p className="mb-1 text-[11px] font-medium text-slate-600">
//                 Search
//               </p>
//               <input
//                 value={query}
//                 onChange={(e) => setQuery(e.target.value)}
//                 placeholder="Farmer, village, crop, claim ID..."
//                 className="w-full rounded-full border border-slate-300 px-3 py-1 text-[11px] outline-none focus:ring-2 focus:ring-emerald-500"
//               />
//               <p className="mt-1 text-[10px] text-slate-500">
//                 Showing {filteredClaims.length} of {claimsWithCoords.length}{" "}
//                 claims with coordinates.
//               </p>
//             </div>

//             {/* List of claims */}
//             <div className="space-y-2 overflow-y-auto">
//               {filteredClaims.map((c) => (
//                 <button
//                   key={c.id}
//                   onClick={() => setSelectedClaim(c)}
//                   className={
//                     "w-full rounded-xl border px-3 py-2 text-left hover:bg-slate-50 " +
//                     (selectedClaim?.id === c.id
//                       ? "border-emerald-500"
//                       : "border-slate-200")
//                   }
//                 >
//                   <div className="flex items-start justify-between gap-2">
//                     <div>
//                       <p className="text-xs font-semibold">{c.farmerName}</p>
//                       <p className="text-[11px] text-slate-600">
//                         {c.cropType}
//                       </p>
//                       <p className="mt-0.5 text-[10px] text-slate-500">
//                         {c.village}, {c.district}
//                       </p>
//                       <p className="mt-0.5 font-mono text-[10px] text-slate-400">
//                         {c.id}
//                       </p>
//                     </div>
//                     <div className="flex flex-col items-end gap-1">
//                       <Pill className={severityColor[c.severity]}>
//                         {c.severity}
//                       </Pill>
//                       <Pill className={statusColor[c.status]}>
//                         {c.status}
//                       </Pill>
//                     </div>
//                   </div>
//                 </button>
//               ))}

//               {filteredClaims.length === 0 && !loading && (
//                 <p className="text-center text-[11px] text-slate-500">
//                   No claims match the current search.
//                 </p>
//               )}
//             </div>

//             {/* Selected claim summary + decisions */}
//             {selectedClaim && (
//               <div className="mt-2 rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
//                 <div className="mb-1 flex items-center gap-2">
//                   <Info className="h-3 w-3 text-slate-500" />
//                   <p className="text-[11px] font-semibold text-slate-700">
//                     Selected claim
//                   </p>
//                 </div>
//                 <p className="text-xs font-semibold">
//                   {selectedClaim.farmerName}
//                 </p>
//                 <p className="text-[11px] text-slate-600">
//                   {selectedClaim.cropType}
//                 </p>
//                 <p className="mt-1 text-[10px] text-slate-500">
//                   {selectedClaim.village}, {selectedClaim.district}
//                 </p>
//                 <p className="mt-1 text-[10px] font-mono text-slate-400">
//                   {selectedClaim.id}
//                 </p>
//                 <div className="mt-2 flex flex-wrap gap-1">
//                   <Pill className={severityColor[selectedClaim.severity]}>
//                     {selectedClaim.severity}
//                   </Pill>
//                   <Pill className={statusColor[selectedClaim.status]}>
//                     {selectedClaim.status}
//                   </Pill>
//                 </div>
//                 {selectedFarmer && (
//                   <div className="mt-2 text-[10px] text-slate-600">
//                     <p>
//                       Phone: <span>{selectedFarmer.phone}</span>
//                     </p>
//                     <p>
//                       Total crops: <span>{selectedFarmer.totalCrops}</span>
//                     </p>
//                     <p>
//                       Open claims: <span>{selectedFarmer.openClaims}</span>
//                     </p>
//                   </div>
//                 )}
//                 {/* Decision buttons + pill */}
//                 <div className="mt-3 space-y-2">
//                   <div className="flex gap-1">
//                     <button
//                       onClick={() =>
//                         handleDecision(selectedClaim.id, "Approve")
//                       }
//                       className="rounded px-2 py-1 text-[10px] bg-emerald-600 text-white hover:bg-emerald-700 transition-colors"
//                     >
//                       Approve
//                     </button>
//                     <button
//                       onClick={() =>
//                         handleDecision(selectedClaim.id, "Reject")
//                       }
//                       className="rounded px-2 py-1 text-[10px] bg-red-600 text-white hover:bg-red-700 transition-colors"
//                     >
//                       Reject
//                     </button>
//                     <button
//                       onClick={() =>
//                         handleDecision(selectedClaim.id, "Field Visit")
//                       }
//                       className="rounded px-2 py-1 text-[10px] bg-blue-600 text-white hover:bg-blue-700 transition-colors"
//                     >
//                       Field Visit
//                     </button>
//                   </div>
//                   {getDecisionPill(selectedClaim.id)}
//                 </div>
//               </div>
//             )}
//           </div>
//         </Card>
//       </div>

//       {/* Map container */}
//       <div className="h-full overflow-hidden rounded-2xl border border-slate-200 bg-slate-200">
//         <div
//           ref={mapContainerRef}
//           style={{ width: "100%", height: "100%", minHeight: 320 }}
//         />
//       </div>
//     </div>
//   );
// };



// src/pages/MapPage.tsx
import React, { useEffect, useMemo, useRef, useState } from "react";
import { useLocation } from "react-router-dom";
import L, { Map as LeafletMap, LayerGroup, LatLngBounds } from "leaflet";
import "leaflet/dist/leaflet.css";

import { Card } from "../components/ui/Card";
import { Pill } from "../components/ui/Pill";
import {
  MOCK_FARMERS,
  MOCK_CLAIMS,
  severityColor,
  statusColor,
} from "../data/mockData";
import type { Claim, Farmer } from "../types/domain";
import { Info } from "lucide-react";

// ---------------------------------------------------------
// Types
// ---------------------------------------------------------

type Decision = "Approve" | "Reject" | "Field Visit";

// ---------------------------------------------------------
// Component
// ---------------------------------------------------------

export const MapPage: React.FC = () => {
  const location = useLocation();

  // 🔁 Use mock claims instead of backend
  const [claims, setClaims] = useState<Claim[]>(MOCK_CLAIMS);
  const [query, setQuery] = useState("");

  // no real API now, so keep these static
  const [loading] = useState(false);
  const [error] = useState<string | null>(null);

  const [selectedClaim, setSelectedClaim] = useState<Claim | null>(null);
  const [decisions, setDecisions] = useState<Record<string, Decision>>({});

  const mapRef = useRef<LeafletMap | null>(null);
  const mapContainerRef = useRef<HTMLDivElement | null>(null);
  const markersLayerRef = useRef<LayerGroup | null>(null);
  const [mapBounds, setMapBounds] = useState<LatLngBounds | null>(null);

  // Select claim from URL query (id=...)
  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const id = params.get("id");
    if (!id || claims.length === 0) return;
    const found = claims.find((c) => c.id === id);
    if (found) setSelectedClaim(found);
  }, [location.search, claims]);

  // Local decision state + update local status
  const handleDecision = (claimId: string, decision: Decision) => {
    setDecisions((prev) => ({ ...prev, [claimId]: decision }));

    if (decision === "Approve" || decision === "Reject") {
      setClaims((prev) =>
        prev.map((c) =>
          c.id === claimId
            ? {
                ...c,
                status:
                  decision === "Approve" ? "Approved" : "Rejected",
              }
            : c
        )
      );
    }
  };

  const getDecisionPill = (claimId: string) => {
    const d = decisions[claimId];
    if (!d) return null;

    let className = "bg-slate-200 text-slate-800";
    if (d === "Approve") className = "bg-emerald-600 text-white";
    if (d === "Reject") className = "bg-red-600 text-white";
    if (d === "Field Visit") className = "bg-blue-600 text-white";

    return (
      <span className={`rounded-full px-2 py-0.5 text-[10px] ${className}`}>
        {d}
      </span>
    );
  };

  // ---- Data derived from claims ----

  const claimsWithCoords = useMemo(
    () =>
      claims.filter(
        (c) => typeof c.lat === "number" && typeof c.lng === "number"
      ),
    [claims]
  );

  const filteredClaims = useMemo(() => {
    if (!query.trim()) return claimsWithCoords;
    const q = query.toLowerCase();

    return claimsWithCoords.filter((c) => {
      return (
        c.farmerName.toLowerCase().includes(q) ||
        c.cropType.toLowerCase().includes(q) ||
        c.village.toLowerCase().includes(q) ||
        c.district.toLowerCase().includes(q) ||
        c.id.toLowerCase().includes(q)
      );
    });
  }, [claimsWithCoords, query]);

  const selectedFarmer: Farmer | null = useMemo(() => {
    if (!selectedClaim) return null;
    return (
      MOCK_FARMERS.find(
        (f) =>
          f.name === selectedClaim.farmerName &&
          f.village === selectedClaim.village &&
          f.district === selectedClaim.district
      ) || null
    );
  }, [selectedClaim]);

  const mapCenter: [number, number] = useMemo(() => {
    if (
      selectedClaim &&
      selectedClaim.lat != null &&
      selectedClaim.lng != null
    ) {
      return [selectedClaim.lat, selectedClaim.lng];
    }
    // central India default
    return [22.9734, 78.6569];
  }, [selectedClaim]);

  // ---- Leaflet map setup ----

  // Initialize map once
  useEffect(() => {
    if (mapRef.current || !mapContainerRef.current) return;

    const map = L.map(mapContainerRef.current, {
      preferCanvas: true,
      zoomControl: true,
      zoomAnimation: false,
      fadeAnimation: false,
    }).setView(mapCenter, 5);
    mapRef.current = map;

    const tiles = L.tileLayer(
      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      {
        attribution:
          '&copy; <a href="https://osm.org/copyright">OSM</a>',
        crossOrigin: true,
        detectRetina: true,
      }
    );
    const fallbackTiles = L.tileLayer(
      "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
      { crossOrigin: true }
    );
    tiles.on("load", () => {
      try {
        map.invalidateSize(true);
      } catch {}
    });
    tiles.on("tileerror", () => {
      try {
        if (!map.hasLayer(fallbackTiles)) {
          fallbackTiles.addTo(map);
        }
      } catch {}
    });
    tiles.addTo(map);

    markersLayerRef.current = L.layerGroup().addTo(map);

    requestAnimationFrame(() => {
      try {
        map.invalidateSize(true);
      } catch {}
    });

    setMapBounds(map.getBounds());
    map.on("moveend", () => {
      try {
        setMapBounds(map.getBounds());
      } catch {}
    });

    const el = mapContainerRef.current;
    let ro: ResizeObserver | null = null;
    if (el) {
      ro = new ResizeObserver(() => {
        try {
          map.invalidateSize(true);
        } catch {}
      });
      ro.observe(el);
    }

    const onResize = () => {
      try {
        map.invalidateSize(true);
      } catch {}
    };
    window.addEventListener("resize", onResize);

    return () => {
      window.removeEventListener("resize", onResize);
      if (ro) ro.disconnect();
      map.remove();
      mapRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Recenter map when selectedClaim changes
  useEffect(() => {
    if (!mapRef.current) return;
    const map = mapRef.current;
    map.setView(mapCenter, selectedClaim ? 7 : 5);
    try {
      map.invalidateSize(true);
    } catch {}
  }, [mapCenter, selectedClaim]);

  // Render markers whenever filteredClaims or bounds change
  useEffect(() => {
    if (!markersLayerRef.current || !mapRef.current) return;
    const layer = markersLayerRef.current;

    layer.clearLayers();

    const claimsToRender = (() => {
      if (mapBounds) {
        return filteredClaims.filter(
          (c) =>
            c.lat != null &&
            c.lng != null &&
            mapBounds.contains([c.lat!, c.lng!])
        );
      }
      return filteredClaims;
    })();

    claimsToRender.forEach((c) => {
      if (c.lat == null || c.lng == null) return;

      const color = statusColor[c.status].includes("red")
        ? "#dc2626"
        : statusColor[c.status].includes("emerald")
        ? "#059669"
        : statusColor[c.status].includes("blue")
        ? "#2563eb"
        : "#6b7280";

      const circle = L.circleMarker([c.lat, c.lng], {
        radius: 5,
        color,
        weight: 1,
        fillColor: color,
        fillOpacity: 0.7,
        bubblingMouseEvents: true,
      })
        .addTo(layer)
        .on("click", () => {
          setSelectedClaim(c);
        });

      circle.bindPopup(
        `<div style="font-size:11px;">
          <div style="font-weight:600;">${c.farmerName}</div>
          <div style="color:#4b5563;">${c.cropType}</div>
          <div style="color:#6b7280;font-size:10px;">${c.village}, ${c.district}</div>
          <div style="color:#9ca3af;font-family:monospace;font-size:10px;margin-top:4px;">${c.id}</div>
        </div>`
      );
    });
  }, [filteredClaims, mapBounds]);

  // ---- UI ----

  return (
    <div className="grid h-[calc(100vh-96px)] grid-cols-[320px,1fr] gap-4">
      {/* Sidebar */}
      <div className="flex h-full flex-col">
        <Card className="flex-1">
          <div className="border-b px-4 py-3">
            <h2 className="text-sm font-semibold">Fasal Bima Geo View</h2>
            <p className="text-[11px] text-slate-500">
              Visualize crop insurance claims on the map.
            </p>

            {loading && (
              <p className="mt-1 text-[11px] text-emerald-600">
                Loading claims from server...
              </p>
            )}

            {error && !loading && (
              <p className="mt-1 text-[11px] text-red-600">
                Failed to load claims: {error}
              </p>
            )}
          </div>

          <div className="flex h-full flex-col gap-3 px-4 py-3 text-xs overflow-y-auto">
            {/* Search */}
            <div>
              <p className="mb-1 text-[11px] font-medium text-slate-600">
                Search
              </p>
              <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Farmer, village, crop, claim ID..."
                className="w-full rounded-full border border-slate-300 px-3 py-1 text-[11px] outline-none focus:ring-2 focus:ring-emerald-500"
              />
              <p className="mt-1 text-[10px] text-slate-500">
                Showing {filteredClaims.length} of {claimsWithCoords.length}{" "}
                claims with coordinates.
              </p>
            </div>

            {/* List of claims */}
            <div className="space-y-2 overflow-y-auto">
              {filteredClaims.map((c) => (
                <button
                  key={c.id}
                  onClick={() => setSelectedClaim(c)}
                  className={
                    "w-full rounded-xl border px-3 py-2 text-left hover:bg-slate-50 " +
                    (selectedClaim?.id === c.id
                      ? "border-emerald-500"
                      : "border-slate-200")
                  }
                >
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <p className="text-xs font-semibold">{c.farmerName}</p>
                      <p className="text-[11px] text-slate-600">
                        {c.cropType}
                      </p>
                      <p className="mt-0.5 text-[10px] text-slate-500">
                        {c.village}, {c.district}
                      </p>
                      <p className="mt-0.5 font-mono text-[10px] text-slate-400">
                        {c.id}
                      </p>
                    </div>
                    <div className="flex flex-col items-end gap-1">
                      <Pill className={severityColor[c.severity]}>
                        {c.severity}
                      </Pill>
                      <Pill className={statusColor[c.status]}>
                        {c.status}
                      </Pill>
                    </div>
                  </div>
                </button>
              ))}

              {filteredClaims.length === 0 && !loading && (
                <p className="text-center text-[11px] text-slate-500">
                  No claims match the current search.
                </p>
              )}
            </div>

            {/* Selected claim summary + decisions */}
            {selectedClaim && (
              <div className="mt-2 rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                <div className="mb-1 flex items-center gap-2">
                  <Info className="h-3 w-3 text-slate-500" />
                  <p className="text-[11px] font-semibold text-slate-700">
                    Selected claim
                  </p>
                </div>
                <p className="text-xs font-semibold">
                  {selectedClaim.farmerName}
                </p>
                <p className="text-[11px] text-slate-600">
                  {selectedClaim.cropType}
                </p>
                <p className="mt-1 text-[10px] text-slate-500">
                  {selectedClaim.village}, {selectedClaim.district}
                </p>
                <p className="mt-1 text-[10px] font-mono text-slate-400">
                  {selectedClaim.id}
                </p>
                <div className="mt-2 flex flex-wrap gap-1">
                  <Pill className={severityColor[selectedClaim.severity]}>
                    {selectedClaim.severity}
                  </Pill>
                  <Pill className={statusColor[selectedClaim.status]}>
                    {selectedClaim.status}
                  </Pill>
                </div>
                {selectedFarmer && (
                  <div className="mt-2 text-[10px] text-slate-600">
                    <p>
                      Phone: <span>{selectedFarmer.phone}</span>
                    </p>
                    <p>
                      Total crops: <span>{selectedFarmer.totalCrops}</span>
                    </p>
                    <p>
                      Open claims: <span>{selectedFarmer.openClaims}</span>
                    </p>
                  </div>
                )}
                {/* Decision buttons + pill */}
                <div className="mt-3 space-y-2">
                  <div className="flex gap-1">
                    <button
                      onClick={() =>
                        handleDecision(selectedClaim.id, "Approve")
                      }
                      className="rounded px-2 py-1 text-[10px] bg-emerald-600 text-white hover:bg-emerald-700 transition-colors"
                    >
                      Approve
                    </button>
                    <button
                      onClick={() =>
                        handleDecision(selectedClaim.id, "Reject")
                      }
                      className="rounded px-2 py-1 text-[10px] bg-red-600 text-white hover:bg-red-700 transition-colors"
                    >
                      Reject
                    </button>
                    <button
                      onClick={() =>
                        handleDecision(selectedClaim.id, "Field Visit")
                      }
                      className="rounded px-2 py-1 text-[10px] bg-blue-600 text-white hover:bg-blue-700 transition-colors"
                    >
                      Field Visit
                    </button>
                  </div>
                  {getDecisionPill(selectedClaim.id)}
                </div>
              </div>
            )}
          </div>
        </Card>
      </div>

      {/* Map container */}
      <div className="h-full overflow-hidden rounded-2xl border border-slate-200 bg-slate-200">
        <div
          ref={mapContainerRef}
          style={{ width: "100%", height: "100%", minHeight: 320 }}
        />
      </div>
    </div>
  );
};

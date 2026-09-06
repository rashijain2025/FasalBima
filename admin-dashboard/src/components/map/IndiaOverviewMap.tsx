// src/components/map/IndiaOverviewMap.tsx
import React, { useMemo } from "react";
import {
  ComposableMap,
  Geographies,
  Geography,
  Marker,
} from "react-simple-maps";
import type { ReactNode } from "react";

/**
 * We use a world topojson and extract only India.
 * The browser will fetch this file at runtime.
 */
const WORLD_TOPO_URL =
  "https://cdn.jsdelivr.net/npm/world-atlas@2/countries-110m.json";

export interface StateStats {
  state: string;
  farmerCount: number;
  claimCount: number;
  severeAlerts: number;
}

/**
 * Approximate coordinates (lon, lat) for some Indian states.
 * You can add more as your data grows.
 */
const STATE_COORDS: Record<string, [number, number]> = {
  Gujarat: [72.57, 22.3],
  Rajasthan: [73.8, 27],
  "Madhya Pradesh": [78.65, 23.5],
};

interface IndiaOverviewMapProps {
  statsByState: StateStats[];
  selectedState: string | null;
  onSelectState: (state: string | null) => void;
  footerSlot?: ReactNode;
}

export const IndiaOverviewMap: React.FC<IndiaOverviewMapProps> = ({
  statsByState,
  selectedState,
  onSelectState,
  footerSlot,
}) => {
  const markers = useMemo(
    () =>
      statsByState
        .filter((s) => STATE_COORDS[s.state])
        .map((s) => ({
          ...s,
          coordinates: STATE_COORDS[s.state],
        })),
    [statsByState]
  );

  return (
    <div className="flex h-[420px] flex-col">
      <div className="flex-1">
        <ComposableMap
          projection="geoMercator"
          projectionConfig={{
            center: [80, 22], // center on India
            scale: 950,
          }}
          style={{ width: "100%", height: "100%" }}
        >
          <Geographies geography={WORLD_TOPO_URL}>
            {({ geographies }) =>
              geographies
                .filter(
                  (geo) =>
                    geo.properties &&
                    (geo.properties.name === "India" ||
                      geo.properties.NAME === "India")
                )
                .map((geo) => (
                  <Geography
                    key={geo.rsmKey}
                    geography={geo}
                    fill="#e5e7eb"
                    stroke="#9ca3af"
                    strokeWidth={0.6}
                  />
                ))
            }
          </Geographies>

          {markers.map((m) => {
            const isActive = selectedState === m.state;
            const radius = Math.min(
              16,
              6 + Math.sqrt(m.claimCount * 6 + m.severeAlerts * 10)
            );

            return (
              <Marker
                key={m.state}
                coordinates={m.coordinates}
                onClick={() =>
                  onSelectState(isActive ? null : (m.state as string))
                }
              >
                <g cursor="pointer">
                  <circle
                    r={radius}
                    fill={isActive ? "#22c55e" : "#0ea5e9"}
                    fillOpacity={isActive ? 0.9 : 0.7}
                    stroke="#0f172a"
                    strokeWidth={isActive ? 1.3 : 0.8}
                  />
                  <text
                    textAnchor="middle"
                    y={radius + 10}
                    style={{
                      fontSize: "9px",
                      fontFamily: "system-ui, sans-serif",
                      fill: "#0f172a",
                    }}
                  >
                    {m.state}
                  </text>
                </g>
              </Marker>
            );
          })}
        </ComposableMap>
      </div>

      {footerSlot && (
        <div className="mt-2 text-[11px] text-slate-500">{footerSlot}</div>
      )}
    </div>
  );
};

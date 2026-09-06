// src/components/charts/ClaimsBySeverityChart.tsx
import React, { useMemo } from "react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { MOCK_CLAIMS } from "../../data/mockData";
import type { DamageSeverity } from "../../types/domain";

interface SeverityAgg {
  severity: DamageSeverity;
  count: number;
}

const SEVERITIES: DamageSeverity[] = ["Low", "Medium", "High", "Severe"];

export const ClaimsBySeverityChart: React.FC = () => {
  const data: SeverityAgg[] = useMemo(() => {
    const base: Record<DamageSeverity, number> = {
      Low: 0,
      Medium: 0,
      High: 0,
      Severe: 0,
    };
    for (const c of MOCK_CLAIMS) {
      base[c.severity]++;
    }
    return SEVERITIES.map((s) => ({ severity: s, count: base[s] }));
  }, []);

  return (
    <div className="h-64">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={data} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} />
          <XAxis dataKey="severity" fontSize={11} />
          <YAxis allowDecimals={false} fontSize={11} />
          <Tooltip
            cursor={{ fill: "rgba(15, 23, 42, 0.03)" }}
            contentStyle={{ fontSize: 11 }}
          />
          <Bar dataKey="count" radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

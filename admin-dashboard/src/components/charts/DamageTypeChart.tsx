// src/components/charts/DamageTypeChart.tsx
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

interface DamageAgg {
  damageType: string;
  count: number;
}

export const DamageTypeChart: React.FC = () => {
  const data: DamageAgg[] = useMemo(() => {
    const map = new Map<string, number>();
    for (const c of MOCK_CLAIMS) {
      const key = c.damageType || "Unknown";
      map.set(key, (map.get(key) ?? 0) + 1);
    }
    return Array.from(map.entries()).map(([damageType, count]) => ({
      damageType,
      count,
    }));
  }, []);

  return (
    <div className="h-64">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          data={data}
          layout="vertical"
          margin={{ top: 8, right: 12, left: 40, bottom: 0 }}
        >
          <CartesianGrid strokeDasharray="3 3" horizontal={false} />
          <XAxis type="number" allowDecimals={false} fontSize={11} />
          <YAxis
            type="category"
            dataKey="damageType"
            width={120}
            fontSize={11}
          />
          <Tooltip
            cursor={{ fill: "rgba(15, 23, 42, 0.03)" }}
            contentStyle={{ fontSize: 11 }}
          />
          <Bar dataKey="count" radius={[0, 6, 6, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

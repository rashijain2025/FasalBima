// src/components/charts/CropHealthChart.tsx
import React, { useMemo } from "react";
import {
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  Cell,
  Legend,
} from "recharts";
import { MOCK_CROPS } from "../../data/mockData";

interface HealthAgg {
  name: string;
  value: number;
}

const COLORS = ["#22c55e", "#fbbf24", "#ef4444"]; // healthy / stressed / damaged

export const CropHealthChart: React.FC = () => {
  const data: HealthAgg[] = useMemo(() => {
    const base = {
      Healthy: 0,
      Stressed: 0,
      Damaged: 0,
    };
    for (const c of MOCK_CROPS) {
      base[c.health]++;
    }
    return [
      { name: "Healthy", value: base.Healthy },
      { name: "Stressed", value: base.Stressed },
      { name: "Damaged", value: base.Damaged },
    ];
  }, []);

  return (
    <div className="h-64">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Tooltip contentStyle={{ fontSize: 11 }} />
          <Legend
            verticalAlign="bottom"
            height={24}
            wrapperStyle={{ fontSize: 11 }}
          />
          <Pie
            data={data}
            dataKey="value"
            nameKey="name"
            innerRadius={40}
            outerRadius={70}
            paddingAngle={2}
          >
            {data.map((entry, index) => (
              <Cell key={entry.name} fill={COLORS[index % COLORS.length]} />
            ))}
          </Pie>
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
};

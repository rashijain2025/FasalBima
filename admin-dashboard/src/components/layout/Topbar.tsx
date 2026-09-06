// src/components/layout/Topbar.tsx
import React from "react";
import { useLocation } from "react-router-dom";

const titles: Record<string, { title: string; subtitle: string }> = {
  "/": {
    title: "Dashboard · National overview",
    subtitle: "High-level view of farmers, crops, and claim load.",
  },
  "/dashboard": {
    title: "Dashboard · National overview",
    subtitle: "High-level view of farmers, crops, and claim load.",
  },
  "/map": {
    title: "Geo view · India map",
    subtitle:
      "Spatial view of farmers, crops and PMFBY claims across Indian states.",
  },
  "/plots": {
    title: "Plot Verification · Field & crop check",
    subtitle: "Verify land boundaries and synced satellite crop records.",
  },
  "/cases": {
    title: "Cases · Claim assessment & decisions",
    subtitle: "Review AI-assisted claim assessments and take decisions.",
  },
  "/analytics": {
    title: "Analytics · Model & risk insights",
    subtitle: "Monitor model performance and damage patterns.",
  },
  "/settings": {
    title: "Settings · Thresholds & integrations",
    subtitle: "Manage severity mapping and external data sources.",
  },
};

export const Topbar: React.FC = () => {
  const location = useLocation();
  const meta = titles[location.pathname] ?? titles["/"];
  const adminName = localStorage.getItem("admin_name") || "National Officer";

  return (
    <header className="flex items-center justify-between border-b bg-white/80 px-6 py-3 backdrop-blur">
      <div>
        <h1 className="text-sm font-semibold">{meta.title}</h1>
        <p className="text-[11px] text-slate-500">{meta.subtitle}</p>
      </div>
      <div className="flex items-center gap-3 text-xs">
        <span className="rounded-full bg-emerald-50 px-2 py-1 text-emerald-700">
          AI-enabled crop image analytics
        </span>
        <div className="h-8 w-px bg-slate-200" />
        <div className="text-right">
          <div className="font-medium text-slate-800">{adminName}</div>
          <div className="text-[11px] text-slate-500">
            PMFBY · Fasal Bima Console
          </div>
        </div>
      </div>
    </header>
  );
};

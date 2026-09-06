// src/components/layout/Shell.tsx
import React from "react";
import { Sidebar } from "./Sidebar";
import { Topbar } from "./Topbar";

export const Shell: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  return (
    <div className="flex h-screen bg-slate-50">
      <Sidebar />
      <main className="flex flex-1 flex-col overflow-hidden">
        <Topbar />
        <div className="flex-1 overflow-y-auto p-4 md:p-6 space-y-4">
          {children}
        </div>
      </main>
    </div>
  );
};

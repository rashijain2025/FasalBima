// src/components/ui/Card.tsx
import React from "react";

export const Card: React.FC<{
  children: React.ReactNode;
  className?: string;
}> = ({ children, className = "" }) => (
  <div
    className={
      "rounded-2xl border border-slate-100 bg-white shadow-sm " + className
    }
  >
    {children}
  </div>
);

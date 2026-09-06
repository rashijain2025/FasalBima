// src/components/ui/Pill.tsx
import React from "react";

export const Pill: React.FC<{
  children: React.ReactNode;
  className?: string;
}> = ({ children, className = "" }) => (
  <span className={"rounded-full px-2 py-0.5 text-[10px] " + className}>
    {children}
  </span>
);

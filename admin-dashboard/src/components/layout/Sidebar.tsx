// src/components/layout/Sidebar.tsx


import React from "react";
import { NavLink } from "react-router-dom";
import {
  LayoutDashboard,
  Map,
  ClipboardList,
  BarChart3,
  Settings,
  MapPinned,
  LogOut,
} from "lucide-react";

const navItems = [
  {
    to: "/dashboard",
    label: "Dashboard",
    icon: LayoutDashboard,
  },
  {
    to: "/map",
    label: "Map",
    icon: Map,
  },
  {
    to: "/plots",
    label: "Plot verification",
    icon: MapPinned,
  },
  {
    to: "/cases",
    label: "Cases",
    icon: ClipboardList,
  },
  { to: "/analytics", label: "Analytics", icon: BarChart3 },
  { to: "/settings", label: "Settings", icon: Settings },
];

const baseLinkClasses =
  "flex items-center gap-2 rounded-xl px-3 py-2 text-xs font-medium transition-colors";

export const Sidebar: React.FC = () => {
  const adminName = localStorage.getItem("admin_name") || "National Admin";

  const handleLogout = () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("admin_name");
    localStorage.removeItem("admin_phone");
    sessionStorage.clear();
    window.location.href = "/login";
  };

  return (
    <aside className="flex h-full w-56 flex-col border-r bg-white">
      <div className="flex items-center gap-2.5 px-4 py-3 border-b border-slate-100">
        <img
          src="/logo.png"
          alt="Fasal Bima Logo"
          className="h-9 w-9 rounded-lg object-contain"
        />
        <div>
          <p className="text-sm font-bold text-slate-800 leading-tight">
            Fasal Bima
          </p>
          <p className="text-[11px] font-medium text-emerald-700">
            Admin Console
          </p>
        </div>
      </div>

      <nav className="flex-1 space-y-1 px-2 py-3">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                [
                  baseLinkClasses,
                  isActive
                    ? "bg-emerald-50 text-emerald-700 font-semibold"
                    : "text-slate-600 hover:bg-slate-50",
                ].join(" ")
              }
            >
              <Icon className="h-4 w-4" />
              <span>{item.label}</span>
            </NavLink>
          );
        })}
      </nav>

      {/* User info & Logout button */}
      <div className="border-t border-slate-100 p-3 bg-slate-50/60">
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-2 overflow-hidden min-w-0">
            <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-emerald-600 text-xs font-bold text-white shadow-sm">
              {adminName.charAt(0).toUpperCase()}
            </div>
            <div className="truncate">
              <p className="truncate text-xs font-semibold text-slate-800">
                {adminName}
              </p>
              <p className="text-[10px] text-slate-500">Admin Account</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            title="Log Out"
            className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-500 hover:bg-red-50 hover:text-red-600 hover:border-red-200 transition-colors"
          >
            <LogOut className="h-4 w-4" />
          </button>
        </div>
      </div>
    </aside>
  );
};

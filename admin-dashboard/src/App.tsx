// src/App.tsx
import React from "react";
import {
  BrowserRouter,
  Route,
  Routes,
  Navigate,
  useLocation,
} from "react-router-dom";

import { Shell } from "./components/layout/Shell";
import { DashboardPage } from "./pages/DashboardPage";
import { MapPage } from "./pages/MapPage";
import { CasesPage } from "./pages/CasesPage";
import { PlotVerificationPage } from "./pages/PlotVerificationPage";
import { AnalyticsPage } from "./pages/AnalyticsPage";
import { SettingsPage } from "./pages/SettingsPage";
import { AdminLoginPage } from "./pages/AdminLoginPage";

// -----------------------------
// Direct Admin App (No login required)
// -----------------------------
const AdminApp: React.FC = () => {
  // Directly render shell + inner routes

  // Logged in -> render shell + inner routes
  return (
    <Shell>
      <Routes>
        {/* Redirect bare "/" to /dashboard */}
        <Route path="/" element={<Navigate to="/dashboard" replace />} />

        {/* Main pages (paths must match your sidebar links) */}
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/map" element={<MapPage />} />
        <Route path="/plots" element={<PlotVerificationPage />} />
        <Route path="/cases" element={<CasesPage />} />
        <Route path="/analytics" element={<AnalyticsPage />} />
        <Route path="/settings" element={<SettingsPage />} />
      </Routes>
    </Shell>
  );
};

// -----------------------------
// Root App
// -----------------------------
function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public login route */}
        <Route path="/login" element={<AdminLoginPage />} />

        {/* Main Admin App (Direct Access) */}
        <Route path="/*" element={<AdminApp />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;

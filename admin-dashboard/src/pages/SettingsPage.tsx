// src/pages/SettingsPage.tsx
import React, { useEffect, useState } from "react";
import { Card } from "../components/ui/Card";
import { api } from "../lib/api";

type CurrentUser = {
  id: string;
  full_name: string;
  phone: string;
  email?: string | null;
  role: string;
  is_verified?: boolean;
  address?: string | null;
  state?: string | null;
  district?: string | null;
  village?: string | null;
};

export const SettingsPage: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState<boolean>(false);

  const [form, setForm] = useState<Partial<CurrentUser>>({});
  const [settings, setSettings] = useState<any | null>(null);
  const [settingsSaving, setSettingsSaving] = useState<boolean>(false);

  // Load logged-in user – minimal backend connection
  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const me = await api<CurrentUser>("/api/auth/me");
        const s = await api<any>("/api/admin/settings");
        if (!cancelled) {
          setCurrentUser(me);
          setForm({
            full_name: me.full_name,
            phone: me.phone,
            email: me.email ?? "",
            address: me.address ?? "",
            state: me.state ?? "",
            district: me.district ?? "",
            village: me.village ?? "",
          });
          setSettings(s);
        }
      } catch (err: any) {
        if (!cancelled) {
          setError(err?.message ?? "Failed to load user");
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  const handleSave = async () => {
    if (!currentUser) return;
    setSaving(true);
    setError(null);
    try {
      const payload: any = {
        full_name: form.full_name,
        phone: form.phone,
        email: form.email,
        address: form.address,
        state: form.state,
        district: form.district,
        village: form.village,
      };
      await api<CurrentUser>(`/api/users/${currentUser.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
    } catch (err: any) {
      setError(err?.message ?? "Failed to save settings");
    } finally {
      setSaving(false);
    }
  };

  const handleSettingsSave = async () => {
    setSettingsSaving(true);
    setError(null);
    try {
      const payload = {
        threshold_low_max: settings?.threshold_low_max,
        threshold_medium_max: settings?.threshold_medium_max,
        threshold_high_max: settings?.threshold_high_max,
        auto_approve_threshold: settings?.auto_approve_threshold,
        manual_review_threshold: settings?.manual_review_threshold,
        max_claims_per_officer_per_day: settings?.max_claims_per_officer_per_day,
        auto_approve_enabled: settings?.auto_approve_enabled,
        max_auto_approval_payout: settings?.max_auto_approval_payout,
        max_pending_days_before_alert: settings?.max_pending_days_before_alert,
        notify_severe_email: settings?.notify_severe_email,
        notify_flood_sms: settings?.notify_flood_sms,
        notify_daily_digest: settings?.notify_daily_digest,
        default_escalation_role: settings?.default_escalation_role,
        active_model_version: settings?.active_model_version,
        retraining_cadence_days: settings?.retraining_cadence_days,
        confidence_calibration_factor: settings?.confidence_calibration_factor,
      };
      const updated = await api<any>("/api/admin/settings", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      setSettings(updated);
    } catch (err: any) {
      setError(err?.message ?? "Failed to save admin settings");
    } finally {
      setSettingsSaving(false);
    }
  };

  if (loading) {
  return (
    <div className="text-xs text-slate-500 px-2 py-4">
      Loading settings...
    </div>
  );
}
  return (
    <div className="grid gap-4 md:grid-cols-2 text-xs">
      {/* Small backend-powered info line */}
      {currentUser && (
        <div className="md:col-span-2 px-1">
          <p className="text-[10px] text-slate-500">
            Logged in as{" "}
            <span className="font-medium">
              {currentUser.full_name || currentUser.email || "admin"}
            </span>
            {currentUser.role ? ` (${currentUser.role})` : ""}
          </p>
        </div>
      )}

      {/* Profile settings */}
      <Card>
        <div className="p-3">
          <p className="text-sm font-semibold">Profile</p>
          <p className="mt-1 text-[11px] text-slate-600">
            Update your contact and address details.
          </p>
          <div className="mt-2 grid gap-3 md:grid-cols-2">
            <div>
              <p className="text-[11px] font-medium text-slate-600">Full name</p>
              <input
                value={form.full_name ?? ""}
                onChange={(e) => setForm((f) => ({ ...f, full_name: e.target.value }))}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">Phone</p>
              <input
                value={form.phone ?? ""}
                onChange={(e) => setForm((f) => ({ ...f, phone: e.target.value }))}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">Email</p>
              <input
                value={form.email ?? ""}
                onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">Address</p>
              <input
                value={form.address ?? ""}
                onChange={(e) => setForm((f) => ({ ...f, address: e.target.value }))}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">State</p>
              <input
                value={form.state ?? ""}
                onChange={(e) => setForm((f) => ({ ...f, state: e.target.value }))}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">District</p>
              <input
                value={form.district ?? ""}
                onChange={(e) => setForm((f) => ({ ...f, district: e.target.value }))}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">Village</p>
              <input
                value={form.village ?? ""}
                onChange={(e) => setForm((f) => ({ ...f, village: e.target.value }))}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
          </div>
          <div className="mt-3 flex items-center gap-2">
            <button
              type="button"
              onClick={handleSave}
              disabled={saving || !currentUser}
              className="rounded-lg border border-slate-300 bg-white px-3 py-1 text-[11px] font-medium text-slate-800 hover:bg-slate-50 disabled:opacity-60"
            >
              {saving ? "Saving..." : "Save changes"}
            </button>
            {error && (
              <span className="text-[11px] text-red-600">{error}</span>
            )}
          </div>
        </div>
      </Card>

      {/* Severity thresholds */}
      <Card>
        <div className="p-3">
          <p className="text-sm font-semibold">Severity thresholds</p>
          <p className="mt-1 text-[11px] text-slate-600">
            Define how AI damage scores map to Low / Medium / High / Severe.
          </p>
          <div className="mt-2 grid gap-3 md:grid-cols-3">
            <div>
              <p className="text-[11px] font-medium text-slate-600">Low max</p>
              <input
                type="number"
                step={0.01}
                min={0}
                max={1}
                value={settings?.threshold_low_max ?? 0.3}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, threshold_low_max: Number(e.target.value) }))
                }
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">Medium max</p>
              <input
                type="number"
                step={0.01}
                min={0}
                max={1}
                value={settings?.threshold_medium_max ?? 0.6}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, threshold_medium_max: Number(e.target.value) }))
                }
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">High max</p>
              <input
                type="number"
                step={0.01}
                min={0}
                max={1}
                value={settings?.threshold_high_max ?? 0.8}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, threshold_high_max: Number(e.target.value) }))
                }
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
          </div>
          <div className="mt-3">
            <button
              type="button"
              onClick={handleSettingsSave}
              disabled={settingsSaving}
              className="rounded-lg border border-slate-200 px-2 py-1 text-[11px] font-medium text-slate-800 hover:bg-slate-50 disabled:opacity-60"
            >
              {settingsSaving ? "Saving..." : "Save thresholds"}
            </button>
          </div>
        </div>
      </Card>

      {/* Operational rules */}
      <Card>
        <div className="p-3">
          <p className="text-sm font-semibold">Operational rules</p>
          <p className="mt-1 text-[11px] text-slate-600">
            Configure how and when AI decisions are escalated to officers.
          </p>

          <div className="mt-2 space-y-2">
            <div>
              <p className="text-[11px] font-medium text-slate-600">
                Auto-approve threshold
              </p>
              <p className="text-[11px] text-slate-500">
                Claims below this damage score can be auto-approved (subject to
                policy).
              </p>
              <input
                type="number"
                value={settings?.auto_approve_threshold ?? 0.35}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, auto_approve_threshold: Number(e.target.value) }))
                }
                step={0.01}
                min={0}
                max={1}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>

            <div>
              <p className="text-[11px] font-medium text-slate-600">
                Mandatory manual review above
              </p>
              <p className="text-[11px] text-slate-500">
                Claims above this damage score are always routed to a human
                officer.
              </p>
              <input
                type="number"
                value={settings?.manual_review_threshold ?? 0.75}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, manual_review_threshold: Number(e.target.value) }))
                }
                step={0.01}
                min={0}
                max={1}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>

            <div>
              <p className="text-[11px] font-medium text-slate-600">
                Max claims per officer / day
              </p>
              <input
                type="number"
                value={settings?.max_claims_per_officer_per_day ?? 60}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, max_claims_per_officer_per_day: Number(e.target.value) }))
                }
                min={1}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">Enable auto-approve</p>
              <label className="mt-1 flex items-center gap-2 text-[11px] text-slate-700">
                <input
                  type="checkbox"
                  checked={!!settings?.auto_approve_enabled}
                  onChange={(e) =>
                    setSettings((s: any) => ({ ...s, auto_approve_enabled: e.target.checked }))
                  }
                  className="h-3 w-3"
                />
                Enabled
              </label>
            </div>
          </div>
          <div className="mt-3">
            <button
              type="button"
              onClick={handleSettingsSave}
              disabled={settingsSaving}
              className="rounded-lg border border-slate-200 px-2 py-1 text-[11px] font-medium text-slate-800 hover:bg-slate-50 disabled:opacity-60"
            >
              {settingsSaving ? "Saving..." : "Save operational rules"}
            </button>
          </div>
        </div>
      </Card>

      {/* Notification & escalation */}
      <Card>
        <div className="p-3">
          <p className="text-sm font-semibold">Notification & escalation</p>
          <p className="mt-1 text-[11px] text-slate-600">
            Control how alerts are sent to admins, district officers and
            partners.
          </p>

          <div className="mt-2 space-y-2">
            <label className="flex items-center gap-2 text-[11px] text-slate-700">
              <input
                type="checkbox"
                checked={!!settings?.notify_severe_email}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, notify_severe_email: e.target.checked }))
                }
                className="h-3 w-3"
              />
              Email alerts for Severe claims
            </label>
            <label className="flex items-center gap-2 text-[11px] text-slate-700">
              <input
                type="checkbox"
                checked={!!settings?.notify_flood_sms}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, notify_flood_sms: e.target.checked }))
                }
                className="h-3 w-3"
              />
              SMS / WhatsApp for flood-related clusters
            </label>
            <label className="flex items-center gap-2 text-[11px] text-slate-700">
              <input
                type="checkbox"
                checked={!!settings?.notify_daily_digest}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, notify_daily_digest: e.target.checked }))
                }
                className="h-3 w-3"
              />
              Daily summary digest to officers
            </label>
          </div>

          <div className="mt-3">
            <p className="text-[11px] font-medium text-slate-600">
              Default escalation role
            </p>
            <select
              value={settings?.default_escalation_role ?? "District officer"}
              onChange={(e) =>
                setSettings((s: any) => ({ ...s, default_escalation_role: e.target.value }))
              }
              className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option>District officer</option>
              <option>State officer</option>
              <option>Insurance partner</option>
            </select>
          </div>

          <div className="mt-3">
            <button
              type="button"
              onClick={handleSettingsSave}
              disabled={settingsSaving}
              className="rounded-lg border border-slate-200 px-2 py-1 text-[11px] font-medium text-slate-800 hover:bg-slate-50 disabled:opacity-60"
            >
              {settingsSaving ? "Saving..." : "Save notification settings"}
            </button>
          </div>
        </div>
      </Card>

      {/* System settings */}
      <Card>
        <div className="border-b px-4 py-3 text-xs font-semibold text-slate-700">
          System settings
        </div>
        <div className="space-y-3 px-4 py-3 text-xs">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-[11px] font-medium text-slate-600">
                Auto-approve low severity cases
              </p>
              <p className="text-[11px] text-slate-500">
                Automatically approve low severity, high-confidence cases below
                a payout threshold.
              </p>
            </div>
            <input type="checkbox" className="h-4 w-4" />
          </div>
          <div className="grid gap-3 md:grid-cols-2">
            <div>
              <p className="text-[11px] font-medium text-slate-600">
                Max auto-approval payout (₹)
              </p>
              <input
                type="number"
                defaultValue={25000}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">
                Max pending days before alert
              </p>
              <input
                type="number"
                defaultValue={7}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
          </div>
        </div>
      </Card>

      {/* AI model controls */}
      <Card>
        <div className="border-b px-4 py-3 text-xs font-semibold text-slate-700">
          AI model controls
        </div>
        <div className="space-y-3 px-4 py-3 text-xs">
          <div>
            <p className="text-[11px] font-medium text-slate-600">
              Active model version
            </p>
            <select
              value={settings?.active_model_version ?? "v1.3"}
              onChange={(e) =>
                setSettings((s: any) => ({ ...s, active_model_version: e.target.value }))
              }
              className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
            >
              <option>v1.3</option>
              <option>v1.2</option>
              <option>v1.1</option>
            </select>
            <p className="mt-1 text-[11px] text-slate-500">
              Future: this can be wired to the actual model registry.
            </p>
          </div>

          <div className="grid gap-3 md:grid-cols-2">
            <div>
              <p className="text-[11px] font-medium text-slate-600">
                Retraining cadence (days)
              </p>
              <input
                type="number"
                value={settings?.retraining_cadence_days ?? 30}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, retraining_cadence_days: Number(e.target.value) }))
                }
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
            <div>
              <p className="text-[11px] font-medium text-slate-600">
                Confidence calibration factor
              </p>
              <input
                type="number"
                value={settings?.confidence_calibration_factor ?? 0.9}
                onChange={(e) =>
                  setSettings((s: any) => ({ ...s, confidence_calibration_factor: Number(e.target.value) }))
                }
                step={0.01}
                min={0}
                max={1}
                className="mt-1 w-full rounded-lg border border-slate-300 px-2 py-1 text-[11px] outline-none"
              />
            </div>
          </div>
          <div className="mt-3">
            <button
              type="button"
              onClick={handleSettingsSave}
              disabled={settingsSaving}
              className="rounded-lg border border-slate-200 px-2 py-1 text-[11px] font-medium text-slate-800 hover:bg-slate-50 disabled:opacity-60"
            >
              {settingsSaving ? "Saving..." : "Save model controls"}
            </button>
          </div>
        </div>
      </Card>

      {/* Logout */}
<Card>
  <div className="p-3">
    <p className="text-sm font-semibold text-red-600">Logout</p>
    <p className="mt-1 text-[11px] text-slate-600">
      Sign out from your admin dashboard.
    </p>

    <div className="mt-3">
      <button
        onClick={async () => {
          try {
            // If backend supports logout API
            await api("/api/auth/logout", { method: "POST" }).catch(() => {});

            // Remove stored tokens and session data
            localStorage.removeItem("access_token");
            localStorage.removeItem("admin_name");
            localStorage.removeItem("admin_phone");
            localStorage.removeItem("token");
            sessionStorage.clear();

            // Redirect to login page
            window.location.href = "/login";
          } catch (err) {
            console.error("Logout failed", err);
          }
        }}
        className="rounded-lg bg-red-600 px-3 py-1 text-[11px] font-medium text-white hover:bg-red-700"
      >
        Logout
      </button>
    </div>
  </div>
</Card>

    </div>
  );
};

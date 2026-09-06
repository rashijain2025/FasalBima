// src/hooks/useFarmers.ts
import { useEffect, useState } from "react";
import { api } from "../lib/api";
import type { Farmer } from "../types/domain"; // adapt to your backend schema

export function useFarmers() {
  const [farmers, setFarmers] = useState<Farmer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await api<Farmer[]>("/api/admin/farmers");
        if (!cancelled) setFarmers(data);
      } catch (err: any) {
        if (!cancelled) setError(err.message ?? "Failed to load farmers");
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  return { farmers, loading, error };
}

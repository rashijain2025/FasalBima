// src/lib/api.ts
const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8000";

export async function api<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const token = localStorage.getItem("access_token");

  const headers: HeadersInit = {
    "Content-Type": "application/json",
    ...(options.headers || {}),
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const url = `${API_BASE_URL}${path}`;

  // Optional: debug in console
  // console.log("API request:", url, options);

  const res = await fetch(url, {
    ...options,
    headers,
  });

  if (res.status === 401) {
    localStorage.removeItem("access_token");
    localStorage.removeItem("admin_name");
    localStorage.removeItem("admin_phone");
    if (window.location.pathname !== "/login") {
      window.location.href = "/login";
    }
  }

  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || `HTTP ${res.status}`);
  }

  if (res.status === 204) {
    // No content
    return {} as T;
  }

  return (await res.json()) as T;
}

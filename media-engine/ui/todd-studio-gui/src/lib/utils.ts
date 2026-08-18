import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/** Tailwind-aware class merge (shadcn `cn` helper). */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const env = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || "http://127.0.0.1:8080",
  adminToken: import.meta.env.VITE_ADMIN_TOKEN || "",
  viewerToken: import.meta.env.VITE_VIEWER_TOKEN || "",
  cricketManagerUrl:
    import.meta.env.VITE_CRICKET_MANAGER_URL ||
    "https://cricket-manager.traceodd.com",
  cricketMatchIds: import.meta.env.VITE_CRICKET_MATCH_IDS || "",
  whepBaseUrl:
    import.meta.env.VITE_WHEP_BASE_URL ||
    import.meta.env.VITE_API_BASE_URL ||
    "http://127.0.0.1:8080",
  stunUrl: import.meta.env.VITE_STUN_URL || "stun:stun.l.google.com:19302",
  turnUrl: import.meta.env.VITE_TURN_URL || "",
  gfxAssetUrl: import.meta.env.VITE_GFX_ASSET_URL || "",
};

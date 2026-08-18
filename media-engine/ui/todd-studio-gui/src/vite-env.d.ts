/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_ADMIN_TOKEN?: string;
  readonly VITE_VIEWER_TOKEN?: string;
  readonly VITE_CRICKET_MANAGER_URL?: string;
  readonly VITE_STUN_URL?: string;
  readonly VITE_TURN_URL?: string;
  readonly VITE_GFX_ASSET_URL?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

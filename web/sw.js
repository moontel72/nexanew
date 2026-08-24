/* =============================================================================
 * Trace Odd — minimal PWA service worker
 * =============================================================================
 * Strategy: NETWORK-FIRST everywhere. Flutter web bundles are versioned by
 * CI on every deploy (main.dart.<stamp>.js), so we never want to serve a
 * stale bundle from cache. Hashed /assets/ responses are cached only as an
 * offline fallback. This file exists mainly to satisfy browser PWA
 * installability (manifest + icons + SW + HTTPS) and to give a tiny offline
 * shell.
 * ========================================================================== */

const CACHE = "traceodd-pwa-v1";

const PRECACHE = [
    "./",
    "./manifest.json",
    "./icons/Icon-192.png",
    "./icons/Icon-512.png",
    "./favicon.png",
];

self.addEventListener("install", (event) => {
    event.waitUntil(
        caches
            .open(CACHE)
            .then((cache) => cache.addAll(PRECACHE))
            .then(() => self.skipWaiting()),
    );
});

self.addEventListener("activate", (event) => {
    event.waitUntil(
        caches
            .keys()
            .then((keys) =>
                Promise.all(
                    keys
                        .filter((key) => key !== CACHE)
                        .map((key) => caches.delete(key)),
                ),
            )
            .then(() => self.clients.claim()),
    );
});

self.addEventListener("fetch", (event) => {
    const { request } = event;
    if (request.method !== "GET") {
        return;
    }
    const url = new URL(request.url);
    if (url.origin !== self.location.origin) {
        return;
    }

    event.respondWith(
        fetch(request)
            .then((response) => {
                // Cache successful hashed-asset responses as an offline
                // fallback only — never use them ahead of the network.
                if (
                    response &&
                    response.ok &&
                    url.pathname.startsWith("/assets/")
                ) {
                    const copy = response.clone();
                    caches
                        .open(CACHE)
                        .then((cache) => cache.put(request, copy))
                        .catch(() => {});
                }
                return response;
            })
            .catch(() =>
                caches
                    .match(request)
                    .then((cached) => cached || caches.match("./")),
            ),
    );
});

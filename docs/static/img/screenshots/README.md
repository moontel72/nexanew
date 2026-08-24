# Screenshots folder

Drop manual screenshots here, then reference them from the book pages as:

```
/ScreenshotSlot usage:
<ScreenshotSlot title="Login screen" src="/img/screenshots/book2-login.png">
  ...
</ScreenshotSlot>

Plain markdown alternative:
![Login screen](/img/screenshots/book2-login.png)
```

Naming conventions:

- Lowercase, dashes instead of spaces (no spaces, no capitals).
- Prefix with the book + section: `book2-login.png`, `book3-larix-whip.png`.
- Prefer PNG for UI screenshots, JPG/WebP for photos.
- Keep each image under ~300 KB so the manual stays fast for field staff.

Deployment: push to `mainnew` — the docs deploy workflow publishes the
site automatically (no manual upload needed).

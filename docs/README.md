# NexaTrace Documentation Site — docs.traceodd.com

Operator manuals for the NexaTrace platform, built with
[Docusaurus](https://docusaurus.io/).

- **Live:** Cricket System — Book 0 (Prerequisites) and Book 1 (Cricket
  Manager Panel), written in **English + Roman Urdu** (tabbed sections).
- **Planned:** Books 2–3 (Todd Studio, Ground Cameras) and the Bus Fleet,
  Factory, Goods Company, B2B Ecommerce and Customer App modules.

## Develop

```bash
npm install
npm start          # http://localhost:3000
```

## Production build

```bash
npm run build      # outputs to build/
npm run serve      # preview the build locally
```

Every page is print-ready: `Ctrl+P` → "Save as PDF" prints only the
article (nav chrome is removed by the print stylesheet) — for ground
crews working offline.

## Deployment

Pushing to `main` / `mainnew` under `docs/**` triggers
`.github/workflows/docs-deploy.yml`, which builds the site on
GitHub Actions and rsyncs `build/` to `/var/www/docs` on the Hetzner
server (nginx server block: `.nginx/docs-traceodd.conf`,
served at `https://docs.traceodd.com`).

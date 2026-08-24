import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// ---------------------------------------------------------------------------
// NexaTrace Documentation Site — docs.traceodd.com
//
// Central operator manual for the NexaTrace platform. Cricket is the first
// fully-written module (Books 0–3); the other platform modules are
// published as "coming soon" landing pages so the top navigation is final.
// ---------------------------------------------------------------------------

const config: Config = {
  title: 'NexaTrace Docs',
  tagline: 'Platform operator manuals — Cricket, Fleet, Factory & more',
  favicon: 'img/favicon.ico',

  // docs.traceodd.com serves from the domain root.
  url: 'https://docs.traceodd.com',
  baseUrl: '/',

  organizationName: 'moontel72',
  projectName: 'nexanew',

  onBrokenLinks: 'warn',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/', // the manual IS the homepage
          editUrl: undefined,
        },
        blog: false, // no blog in v1 — operator manual only
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      defaultMode: 'light',
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: '', // logo-only navbar — the lockup already carries the brand name
      logo: {
        alt: 'NexaTrace Docs',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'dropdown',
          label: '🏏 Cricket',
          position: 'left',
          items: [
            {to: '/cricket/intro', label: 'Cricket Overview'},
            {to: '/cricket/book0-prerequisites', label: 'Book 0 — Prerequisites'},
            {to: '/cricket/book1-manager-panel', label: 'Book 1 — Manager Panel'},
            {to: '/cricket/book2-todd-studio', label: 'Book 2 — Todd Studio'},
            {to: '/cricket/book3-broadcaster', label: 'Book 3 — Ground Cameras'},
          ],
        },
        {to: '/bus-fleet', label: '🚌 Bus Fleet', position: 'left'},
        {to: '/factory', label: '🏭 Factory', position: 'left'},
        {to: '/goods-company', label: '🚛 Goods Company', position: 'left'},
        {to: '/b2b-ecommerce', label: '🛒 B2B Ecommerce', position: 'left'},
        {to: '/customer-app', label: '📱 Customer App', position: 'left'},
        {
          href: 'https://traceodd.com/download/',
          label: '⬇ Download App',
          position: 'right',
        },
        {
          href: 'https://studio.traceodd.com',
          label: 'Open Todd Studio ↗',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Cricket Manual',
          items: [
            {label: 'Overview', to: '/cricket/intro'},
            {label: 'Book 0 — Prerequisites', to: '/cricket/book0-prerequisites'},
            {label: 'Book 1 — Manager Panel', to: '/cricket/book1-manager-panel'},
            {label: 'Book 2 — Todd Studio', to: '/cricket/book2-todd-studio'},
            {label: 'Book 3 — Ground Cameras', to: '/cricket/book3-broadcaster'},
          ],
        },
        {
          title: 'Platform',
          items: [
            {label: 'Bus Fleet (soon)', to: '/bus-fleet'},
            {label: 'Factory (soon)', to: '/factory'},
            {label: 'Goods Company (soon)', to: '/goods-company'},
            {label: 'B2B Ecommerce (soon)', to: '/b2b-ecommerce'},
            {label: 'Customer App (soon)', to: '/customer-app'},
          ],
        },
        {
          title: 'Live Systems',
          items: [
            {label: 'Todd Studio', href: 'https://studio.traceodd.com'},
            {label: 'Cricket Manager', href: 'https://cricket-manager.traceodd.com'},
            {label: 'Cricket Public', href: 'https://cricket.traceodd.com'},
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Trace Odd. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;

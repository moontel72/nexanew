import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// ---------------------------------------------------------------------------
// Sidebar layout — Cricket is fully populated (Books 0–3); the remaining
// platform modules are "coming soon" landing pages.
// ---------------------------------------------------------------------------

const sidebars: SidebarsConfig = {
  cricket: [
    {type: 'doc', id: 'overview', label: '🏠 Platform Overview'},
    {
      type: 'category',
      label: '🏏 Cricket System',
      link: {type: 'doc', id: 'cricket/intro'},
      collapsed: false,
      items: [
        'cricket/intro',
        'cricket/book0-prerequisites',
        'cricket/book1-manager-panel',
        'cricket/book2-todd-studio',
        'cricket/book3-broadcaster',
      ],
    },
  ],
};

export default sidebars;

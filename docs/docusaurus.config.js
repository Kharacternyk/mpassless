/** @type {import('@docusaurus/types').Config} */
const config = {
  title: "mpassless",
  url: "https://www.mpassless.org",
  baseUrl: "/",
  trailingSlash: false,
  presets: [
    [
      "classic",
      {
        docs: {
          routeBasePath: "/",
          breadcrumbs: false,
        },
        theme: {
          customCss: "custom.css",
        },
      },
    ],
  ],
  themeConfig: {
    navbar: {
      title: "mpassless",
      logo: {
        src: "logo.svg",
      },
    },
    colorMode: {
      respectPrefersColorScheme: true,
    },
  },
  markdown: {
    mermaid: true,
  },
};

export default config;

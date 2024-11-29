// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/core_web.ex",
    "../lib/core_web/**/*.*ex"
  ],
  theme: {
    fontFamily: {
      'sans': ['Noto Sans', 'ui-sans-serif', 'system-ui'],
      'serif': ['Noto Serif', 'ui-serif'],
    },
    extend: {
      colors: {
        'big-stone': {
          '50': '#f4f6fb',
          '100': '#e9ecf5',
          '200': '#ced8e9',
          '300': '#a3b7d6',
          '400': '#7290be',
          '500': '#5072a7',
          '600': '#3d598c',
          '700': '#324872',
          '800': '#2d3f5f',
          '900': '#26324a',
          '950': '#1b2336',
        },
        'merino': {
          '50': '#faf7f2',
          '100': '#f6f2ea',
          '200': '#e5d8c3',
          '300': '#d4be9d',
          '400': '#c29f75',
          '500': '#b5885a',
          '600': '#a7754f',
          '700': '#8b5f43',
          '800': '#714d3b',
          '900': '#5c4132',
          '950': '#312019',
        },
        'falu-red': {
          '50': '#fff2f1',
          '100': '#ffe1e0',
          '200': '#ffc8c6',
          '300': '#ffa39f',
          '400': '#ff6e67',
          '500': '#fc4037',
          '600': '#ea2118',
          '700': '#c51810',
          '800': '#a21812',
          '900': '#881b16',
          '950': '#490906',
        },
        'clementine': {
          '50': '#fff8ed',
          '100': '#fef0d6',
          '200': '#fcdcac',
          '300': '#fac277',
          '400': '#f69e41',
          '500': '#f4821b',
          '600': '#ed6b12',
          '700': '#be4e10',
          '800': '#973e15',
          '900': '#793415',
          '950': '#421908',
        },
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),

    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"]))
  ]
};

// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  daisyui: {
    themes: ["light"],
  },
  theme: {
    fontFamily: {
      'sans': ['Noto Sans', 'ui-sans-serif', 'system-ui'],
      'serif': ['Noto Serif', 'ui-serif'],
    },
    extend: {
      colors: {
        dark: {
          100: "#d4d6db",
          200: "#a8adb7",
          300: "#7d8492",
          400: "#515b6e",
          500: "#26324a",
          600: "#1e283b",
          700: "#171e2c",
          800: "#0f141e",
          900: "#080a0f"
        },
        light: {
          100: "#fdfcfb",
          200: "#fbfaf7",
          300: "#faf7f2",
          400: "#f8f5ee",
          500: "#f6f2ea",
          600: "#c5c2bb",
          700: "#94918c",
          800: "#62615e",
          900: "#31302f"
        },
        contrast: {
          100: "#e7d1d0",
          200: "#cfa4a2",
          300: "#b87673",
          400: "#a04945",
          500: "#881b16",
          600: "#6d1612",
          700: "#52100d",
          800: "#360b09",
          900: "#1b0504"
        },
        highlight: {
          100: "#fbe1d0",
          200: "#f8c4a0",
          300: "#f4a671",
          400: "#f18941",
          500: "#ed6b12",
          600: "#be560e",
          700: "#8e400b",
          800: "#5f2b07",
          900: "#2f1504"
        },
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("daisyui"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"]))
  ]
};

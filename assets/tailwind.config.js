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
  theme: {
    extend: {
      colors: {
        dark: {
          100: "#e4d2cf",
          200: "#caa69e",
          300: "#af796e",
          400: "#954d3d",
          500: "#7a200d",
          600: "#621a0a",
          700: "#491308",
          800: "#310d05",
          900: "#180603"
        },
        light: {
          100: "#fffcf8",
          200: "#fef9f1",
          300: "#fef7ea",
          400: "#fdf4e3",
          500: "#fdf1dc",
          600: "#cac1b0",
          700: "#989184",
          800: "#656058",
          900: "#33302c"
        },
        contrast: {
          100: "#e9d4cf",
          200: "#d3a89f",
          300: "#be7d70",
          400: "#a85140",
          500: "#922610",
          600: "#751e0d",
          700: "#58170a",
          800: "#3a0f06",
          900: "#1d0803"
        },
        highlight: {
          100: "#faebd4",
          200: "#f5d7a9",
          300: "#f0c27e",
          400: "#ebae53",
          500: "#e69a28",
          600: "#b87b20",
          700: "#8a5c18",
          800: "#5c3e10",
          900: "#2e1f08"
        },
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require('@tailwindcss/typography'),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    // plugin(function({matchComponents, theme}) {
    //   let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
    //   let values = {}
    //   let icons = [
    //     ["", "/24/outline"],
    //     ["-solid", "/24/solid"],
    //     ["-mini", "/20/solid"]
    //   ]
    //   icons.forEach(([suffix, dir]) => {
    //     fs.readdirSync(path.join(iconsDir, dir)).map(file => {
    //       let name = path.basename(file, ".svg") + suffix
    //       values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
    //     })
    //   })
    //   matchComponents({
    //     "hero": ({name, fullPath}) => {
    //       let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
    //       return {
    //         [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
    //         "-webkit-mask": `var(--hero-${name})`,
    //         "mask": `var(--hero-${name})`,
    //         "mask-repeat": "no-repeat",
    //         "background-color": "currentColor",
    //         "vertical-align": "middle",
    //         "display": "inline-block",
    //         "width": theme("spacing.5"),
    //         "height": theme("spacing.5")
    //       }
    //     }
    //   }, {values})
    // })
  ]
};

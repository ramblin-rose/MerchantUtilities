import { series, watch, src, dest, parallel } from "gulp";
import newer from "gulp-newer";
import path from "path";
import replace from "gulp-replace";
import touch from "gulp-touch-cmd";
import { deleteSync } from "del";
// work around to easily load json in this ES module
import { createRequire } from "module";
const require = createRequire(import.meta.url);
let packageJson = require("./package.json");
//////////////////////////////////
class util {
  static get name() {
    return packageJson.title.replace(/\s+/gm, "");
  }
  static get distro() {
    return `./${util.name}-${packageJson.version}`;
  }
}
//////////////////////////////////
function configure(cb) {
  const output = "build";

  delete require.cache[require.resolve("./package.json")];
  packageJson = require("./package.json");

  return src("package.json", { ignoreInitial: false })
    .pipe(dest(output))
    .pipe(touch());
}

//////////////////////////////////
function codes(cb) {
  const output = "build";
  return src(["src/**/*.lua", "src/**/*.xml"], { ignoreInitial: false })
    .pipe(dest(output))
    .pipe(touch());
}
//////////////////////////////////
function assets(cb) {
  const output = "build";
  return src("src/**/*.png", { ignoreInitial: false, encoding: false })
    .pipe(dest(output))
    .pipe(touch());
}
//////////////////////////////////
function toc(cb) {
  const output = "build";
  return src(`src/${util.name}.toc`)
    .pipe(
      replace(/^[\s]*##[\s]*Title[\s]*:.*$/gm, "## Title: " + packageJson.title)
    )
    .pipe(
      replace(
        /^[\s]*##[\s]*Description[\s]*:.*$/gm,
        "## Description: " + packageJson.description
      )
    )
    .pipe(
      replace(
        /^[\s]*##[\s]*Version[\s]*:.*$/gm,
        "## Version: " + packageJson.version
      )
    )
    .pipe(
      replace(
        /^[\s]*##[\s]*Interface[\s]*:.*$/gm,
        "## Interface: " + packageJson.interface
      )
    )
    .pipe(
      replace(
        /^[\s]*##[\s]*Author[\s]*:.*$/gm,
        "## Author: " + packageJson.author
      )
    )
    .pipe(dest(output))
    .pipe(touch());
}
function attributions(cb) {
  const output = "build";
  return src(["src/**/attribution.*"], { ignoreInitial: false })
    .pipe(dest(output))
    .pipe(touch());
}
//////////////////////////////////
function addons(cb) {
  const output = path.join(
    process.env.WOW_ADDON_DEST_FOLDER,
    packageJson.title.replace(/(\s)+/g, "")
  );

  return src("build/**/*", { ignoreInitial: false, encoding: false })
    .pipe(newer(output))
    .pipe(dest(output))
    .pipe(touch());
}
//////////////////////////////////
// watch and write changes to wow addon folder.
function dev(_) {
  clean();
  watch(
    ["package.json", "src/**/*"],
    { ignoreInitial: false },
    series(configure, codes, assets, toc, addons)
  );
}

export default dev;
//////////////////////////////////
export function clean(cb) {
  deleteSync(["build/*"], { force: true });
  if (cb) cb();
}

export const build = series(clean, codes, assets, attributions, toc);

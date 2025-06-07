#!/usr/bin/env deno --allow-write --allow-read

// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { walk } from "jsr:@std/fs/walk";
import { globToRegExp } from "jsr:@std/path/glob-to-regexp";

const EXTENSIONS: [string, string][] = [
  [".ts", "//"],
  [".gd", "#"],
  [".tscn", ";"],
];
const EXCLUDED_DIRS = [
  "**/.godot",
  "**/addons/gut",
];

const ROOT = new URL("../", import.meta.url);
const CHECK = Deno.args.includes("--check");
const FIRST_YEAR = 2024;
const CURRENT_YEAR = new Date().getFullYear();
const RX_COPYRIGHT = new RegExp(
  "Copyright ([0-9]{4})-([0-9]{4}) the Bisterix Studio authors\\. All rights reserved\\. MIT license\\.\n",
);
const COPYRIGHT =
  `Copyright ${FIRST_YEAR}-${CURRENT_YEAR} the Bisterix Studio authors. All rights reserved. MIT license.`;

let failed = false;

for await (
  const { path } of walk(ROOT, {
    exts: EXTENSIONS.map((ext) => ext[0]),
    skip: EXCLUDED_DIRS.map((path) => globToRegExp(path)),
    includeDirs: false,
  })
) {
  const content = await Deno.readTextFile(path);
  const match = content.match(RX_COPYRIGHT);

  if (!match) {
    if (CHECK) {
      console.error(`Missing copyright header: ${path}`);
      failed = true;
    } else {
      const prefix = EXTENSIONS.find((ext) => path.endsWith(ext[0]))?.[1];
      if (!prefix) {
        console.error(`Unable to find comment prefix for path: ${path}`);
        failed = true;
      } else {
        const contentWithCopyright = prefix + " " + COPYRIGHT + "\n\n" +
          content;
        await Deno.writeTextFile(path, contentWithCopyright);
        console.log("Copyright header automatically added to " + path);
      }
    }
  } else if (
    (match[1] && parseInt(match[1]) !== FIRST_YEAR) ||
    (match[2] && parseInt(match[2]) !== CURRENT_YEAR)
  ) {
    if (CHECK) {
      console.error(`Incorrect copyright year: ${path}`);
      failed = true;
    } else {
      const index = match.index ?? 0;
      const contentWithoutCopyright = content.replace(match[0], "");
      const contentWithCopyright = contentWithoutCopyright.substring(0, index) +
        COPYRIGHT + "\n" + contentWithoutCopyright.substring(index);
      await Deno.writeTextFile(path, contentWithCopyright);
      console.log("Copyright header automatically updated in " + path);
    }
  }
}

if (failed) {
  console.info(`Copyright header should be "${COPYRIGHT}"`);
  Deno.exit(1);
}

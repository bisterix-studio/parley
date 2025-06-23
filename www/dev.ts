#!/usr/bin/env -S deno run -A --watch=static/,routes/

// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { Builder } from "fresh/dev";
import { app } from "./main.ts";
import { tailwind } from "@fresh/plugin-tailwind";

const builder = new Builder({ target: "safari12" });
tailwind(builder, app, {});

if (Deno.args.includes("build")) {
  await builder.build(app);
} else {
  await builder.listen(app);
}

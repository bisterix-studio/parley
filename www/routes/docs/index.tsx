// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { define } from "../../utils/state.ts";

export const handler = define.handlers({
  GET(ctx) {
    return ctx.redirect("/docs/introduction");
  },
});

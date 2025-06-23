// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { App, fsRoutes, staticFiles, trailingSlashes } from "fresh";

export const app = new App({ root: import.meta.url })
  .use(staticFiles())
  .use(trailingSlashes("never"));

await fsRoutes(app, {
  loadIsland: (path) => import(`./islands/${path}`),
  loadRoute: (path) => import(`./routes/${path}`),
});

if (import.meta.main) {
  await app.listen();
}

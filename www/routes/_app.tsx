// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { asset } from "fresh/runtime";
import { define } from "../utils/state.ts";

// Adapted from: https://github.com/denoland/fresh

export default define.page(function App({ Component, state, url }) {
  return (
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        {state.title ? <title>{state.title}</title> : null}
        {state.description
          ? <meta name="description" content={state.description} />
          : null}
        {state.title
          ? <meta property="og:title" content={state.title} />
          : null}
        {state.description
          ? <meta property="og:description" content={state.description} />
          : null}
        <meta property="og:type" content="website" />
        <meta property="og:url" content={url.href} />
        {state.ogImage
          ? <meta property="og:image" content={state.ogImage} />
          : null}
        {state.noIndex ? <meta name="robots" content="noindex" /> : null}
        <meta name="color-scheme" content="light dark" />
        <link
          rel="preload"
          href={asset("/fonts/JosefinSansVariable.woff2")}
          as="font"
          type="font/woff2"
          crossorigin="anonymous"
        />
        <link rel="stylesheet" href={asset("/styles.css")} />
        {url.pathname === "/"
          ? <link rel="stylesheet" href={asset("/prism.css")} />
          : null}
        {url.pathname.startsWith("/docs/")
          ? (
            <>
              <link rel="stylesheet" href={asset("/markdown.css")} />
            </>
          )
          : null}
        <script
          type="module"
          // deno-lint-ignore react-no-danger
          dangerouslySetInnerHTML={{
            __html: `
const isDarkMode = localStorage.theme !== "light";
document.documentElement.dataset.theme = isDarkMode ? "dark" : "light";`,
          }}
        >
        </script>
      </head>
      <body>
        <Component />
      </body>
    </html>
  );
});

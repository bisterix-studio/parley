// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import Prism from "prismjs";

// Adapted from: https://github.com/denoland/fresh

export function CodeBlock(
  { code, lang }: {
    code: string;
    lang: "js" | "ts" | "jsx" | "md" | "bash" | "json";
  },
) {
  return (
    <pre
      class="rounded-lg text-base leading-relaxed bg-slate-800 text-white p-4 sm:p-6 md:p-4 lg:p-6 2xl:p-8 overflow-x-auto"
      data-language={lang}
      // deno-lint-ignore react-no-danger
    ><code dangerouslySetInnerHTML={{ __html: Prism.highlight(code, Prism.languages[lang], lang)}} /></pre>
  );
}

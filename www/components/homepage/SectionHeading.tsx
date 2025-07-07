// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import type { ComponentChildren } from "preact";

// Adapted from: https://github.com/denoland/fresh

export function SectionHeading(
  { children }: { children: ComponentChildren },
) {
  return (
    <h2 class="text-3xl lg:text-4xl xl:text-5xl text-foreground-secondary font-bold text-balance">
      {children}
    </h2>
  );
}

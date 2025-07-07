// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import type { PageProps } from "fresh";
import StarrySky from "../islands/StarrySky.tsx";

export default function Layout({ Component }: PageProps) {
  return (
    <StarrySky>
      <div class="layout relative">
        <div class="bg-none bg-transparent bg-no-repeat bg-right text-foreground-primary">
          <div class="flex flex-col min-h-screen mx-auto max-w-screen-2xl">
            <Component />
          </div>
        </div>
      </div>
    </StarrySky>
  );
}

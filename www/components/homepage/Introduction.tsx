// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { PageSection } from "../../components/PageSection.tsx";

export function Introduction() {
  return (
    <PageSection class="text-foreground-secondary !mb-12 !mt-20">
      <div class="text-center max-w-max mx-auto flex flex-col gap-4">
        <p class="italic text-lg">
          Introducing Parley:
        </p>
        <h2 class="text-4xl sm:text-5xl md:text-6xl lg:text-7xl sm:tracking-tight sm:leading-[1.1]! font-extrabold text-balance">
          A graph-based dialogue management plugin for Godot.
        </h2>
        <p class="text-xl text-balance max-w-prose mx-auto">
          Designed for game writers and developers alike, Parley makes writing,
          testing, and running Dialogue Sequences at scale a breeze.
        </p>
      </div>
    </PageSection>
  );
}

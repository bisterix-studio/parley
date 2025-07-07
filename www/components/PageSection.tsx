// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import type { JSX } from "preact";

// Adapted from: https://github.com/denoland/fresh

export function PageSection(props: JSX.HTMLAttributes<HTMLDivElement>) {
  return (
    <section
      id={props.id ?? ""}
      class={`w-full max-w-screen-xl mx-auto my-16 md:my-24 lg:my-32 px-4 sm:px-8 lg:px-16 2xl:px-0 flex flex-col gap-8 md:gap-16 ${
        props.class ?? ""
      }`}
    >
      {props.children}
    </section>
  );
}

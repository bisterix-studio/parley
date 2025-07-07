// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import type { JSX } from "preact";

// Adapted from: https://github.com/denoland/fresh

export function ExampleArrow(
  props: JSX.HTMLAttributes<HTMLDivElement>,
): JSX.Element {
  return (
    <svg
      aria-hidden="true"
      width="100%"
      height="100%"
      viewBox="0 0 137 291"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xml:space="preserve"
      style="fill-rule:evenodd;clip-rule:evenodd;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:1.5;"
      class={`w-12 -my-8 relative z-10 mx-auto ${props?.class ?? ""}`}
    >
      <path
        d="M50.704,18c46.89,80.967 38.288,189.344 5.941,254.255"
        style="fill:none;stroke:#fff;stroke-width:36px;"
      />
      <path
        d="M18,207.944c13.297,11.903 33.957,43.376 38.645,64.311c19.034,-17.758 43.173,-31.125 62.237,-36.621"
        style="fill:none;stroke:#fff;stroke-width:36px;"
      />
      <path
        d="M50.704,18c47.238,81.059 38.288,189.344 5.941,254.255"
        style="fill:none;stroke-width:18px;"
        class="stroke-background-primary"
      />
      <path
        d="M18,207.944c13.044,11.646 33.957,43.376 38.645,64.311c19.034,-17.758 43.173,-31.125 62.237,-36.621"
        style="fill:none;stroke-width:18px;"
        class="stroke-background-primary"
      />
    </svg>
  );
}

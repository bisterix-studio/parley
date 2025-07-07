// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import type { JSX } from "preact/jsx-runtime";

// Adapted from: https://github.com/denoland/fresh

type ColumnConfiguration = "1/1" | "2/3" | "3/2";

interface SideBySideProps extends JSX.HTMLAttributes<HTMLDivElement> {
  mdColSplit?: ColumnConfiguration;
  lgColSplit?: ColumnConfiguration;
  reverseOnDesktop?: boolean;
}

export function SideBySide(props: SideBySideProps) {
  let mdSplitClass = "md:grid-cols-2";
  let lgSplitClass = "lg:grid-cols-2";

  if (props.mdColSplit === "2/3") {
    mdSplitClass = "md:grid-cols-[minmax(0,2fr)_minmax(0,3fr)]";
  } else if (props.mdColSplit === "3/2") {
    mdSplitClass = "md:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]";
  }

  if (props.lgColSplit === "2/3") {
    lgSplitClass = " lg:grid-cols-[minmax(0,2fr)_minmax(0,3fr)]";
  } else if (props.lgColSplit === "3/2") {
    lgSplitClass = "lg:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]";
  }

  return (
    <div
      class={`grid grid-cols-1 items-center gap-12 md:gap-16 xl:gap-32 ${
        props.reverseOnDesktop ? "md:first:[&>*]:order-1" : ""
      } ${mdSplitClass} ${lgSplitClass} ${props.class ?? ""}`}
    >
      {props.children}
    </div>
  );
}

// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { createDefine } from "fresh";

// Adapted from: https://github.com/denoland/fresh

export interface State {
  title?: string;
  description?: string;
  ogImage?: string;
  noIndex?: boolean;
}

export const define = createDefine<State>();

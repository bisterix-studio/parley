// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import type { FreshContext } from "fresh";

export async function handler(
  ctx: FreshContext,
): Promise<Response> {
  let res: Response;
  try {
    const resp = await ctx.next();
    const headers = new Headers(resp.headers);
    res = new Response(resp.body, { status: resp.status, headers });
    return res;
  } catch (e) {
    res = new Response("Internal Server Error", {
      status: 500,
    });
    throw e;
  }
}

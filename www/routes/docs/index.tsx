import { define } from "../../utils/state.ts";

export const handler = define.handlers({
  GET(ctx) {
    return ctx.redirect("/docs/introduction");
  },
});

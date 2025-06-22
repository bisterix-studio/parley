import { page } from "fresh";
import { asset } from "fresh/runtime";
import Header from "../components/Header.tsx";
import { define } from "../utils/state.ts";

const TITLE = "Showcase | Parley";
const DESCRIPTION = "Selection of games that have been built with Parley.";

export const handler = define.handlers({
  GET(ctx) {
    ctx.state.title = TITLE;
    ctx.state.description = DESCRIPTION;
    ctx.state.ogImage = new URL(asset("/og-image.png"), ctx.url).href;
    return page();
  },
});

export default define.page<typeof handler>(function ShowcasePage() {
  return (
    <>
      <Header title="showcase" active="/showcase" />
      <section class="max-w-screen-lg mx-auto my-16 px-4 sm:px-6 md:px-8 space-y-4">
        <h2 class="text-3xl font-bold">
          Showcase
        </h2>
        <p>
          Below is a selection of games that have been built with Parley.{" "}
          <a
            href="https://github.com/bisterix-studio/parley/blob/main/www/data/showcase.json"
            class="text-blue-500 hover:underline"
          >
            Add yours!
          </a>
        </p>
        {/* <Projects items={items} class="gap-16" /> */}
      </section>
    </>
  );
});

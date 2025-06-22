import { page } from "fresh";
import { asset } from "fresh/runtime";
import Header from "../components/Header.tsx";
import { ArchitectureSection } from "../components/homepage/ArchitectureSection.tsx";
import { CTA } from "../components/homepage/CTA.tsx";
import { GraphViewSection } from "../components/homepage/GraphViewSection.tsx";
import { Hero } from "../components/homepage/Hero.tsx";
import { Introduction } from "../components/homepage/Introduction.tsx";
import { StoresSection } from "../components/homepage/StoresSection.tsx";
import { define } from "../utils/state.ts";

export const handler = define.handlers({
  GET(ctx) {
    ctx.state.title =
      "Parley - The easy to use, writer-first, scalable dialogue management system.";
    ctx.state.description =
      "Parley is designed to be used by game writers and developers alike for easy writing, testing, running of Dialogue Sequences at scale to make game writing a breeze.";
    ctx.state.ogImage = new URL(asset("/og-image.png"), ctx.url).href;

    return page();
  },
});

export default define.page<typeof handler>(function MainPage() {
  return (
    <>
      <Header title="" active="/" />
      <div class="flex flex-col -mt-20 relative">
        <Hero />
        <Introduction />
        <GraphViewSection />
        <ArchitectureSection />
        <StoresSection />
        <CTA />
      </div>
    </>
  );
});

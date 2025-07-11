// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { page } from "fresh";
import { asset } from "fresh/runtime";
import Footer from "../components/Footer.tsx";
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
      "Parley | The easy-to-use, writer-first, scalable dialogue management system.";
    ctx.state.description =
      "Designed for game writers and developers alike, Parley makes writing, testing, and running Dialogue Sequences at scale a breeze.";
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
      <Footer class="mt-auto" />
    </>
  );
});

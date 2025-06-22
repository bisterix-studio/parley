import { FancyLink } from "../../components/FancyLink.tsx";
import { BisterixStudioLogo } from "../BisterixStudioLogo.tsx";

export function Hero() {
  return (
    <div class="mt-0 pt-32 md:pt-48 !mb-0">
      <div class="md:grid grid-cols-5 gap-8 md:gap-16 items-center w-full max-w-screen-xl mx-auto px-4 md:px-8 lg:px-16 2xl:px-0">
        <div class="flex-1 text-center md:text-left md:col-span-3 pb-8 md:pb-32">
          <h2 class="text-foreground-primary text-[calc(1rem+4vw)] leading-tight sm:text-5xl lg:text-6xl sm:tracking-tight sm:leading-none! font-extrabold">
            The easy to use, writer-first, scalable dialogue management system
          </h2>
          <div class="mt-12 flex flex-wrap justify-center items-stretch md:justify-start gap-4">
            <FancyLink href="/docs/getting-started">Get started</FancyLink>
          </div>
        </div>
        <div class="hidden sm:flex md:col-span-2 justify-center items-end mr-auto h-full w-full flex-col">
          <p class="italic text-base text-center mt-24 ml-20 mr-auto">
            Brought to you by:
          </p>
          <BisterixStudioLogo class="max-w-56 mb-auto ml-8 mr-auto" />
        </div>
      </div>
    </div>
  );
}

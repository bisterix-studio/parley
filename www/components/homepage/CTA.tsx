import { FancyLink } from "../FancyLink.tsx";

export function CTA() {
  return (
    <div class="relative">
      <div class="text-center pb-32 md:pb-48 xl:pb-56 !my-0">
        <div class="flex flex-col gap-4">
          <h2 class="pt-24 text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-extrabold z-0">
            Let's roll
          </h2>
          <div class="flex flex-col justify-start items-center gap-4 z-0">
            <p class="text-xl text-balance max-w-prose">
              Jump in and build your Godot Dialogue Sequences with Parley. Learn
              everything you need to know in moments.
            </p>
            <FancyLink
              href="/docs/getting-started"
              class="mx-auto mt-4"
            >
              Get started
            </FancyLink>
          </div>
        </div>
      </div>
    </div>
  );
}

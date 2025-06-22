import { PageSection } from "../../components/PageSection.tsx";

export function Introduction() {
  return (
    <PageSection class="text-foreground-secondary !mb-12 !mt-20">
      <div class="text-center max-w-max mx-auto flex flex-col gap-4">
        <p class="italic text-lg">
          Introducing Parley:
        </p>
        <h2 class="text-4xl sm:text-5xl md:text-6xl lg:text-7xl sm:tracking-tight sm:leading-[1.1]! font-extrabold text-balance">
          A graph-based dialogue management plugin for Godot.
        </h2>
        <p class="text-xl text-balance max-w-prose mx-auto">
          Parley is designed to be used by game writers and developers alike for
          easy writing, testing, running of Dialogue Sequences at scale to make
          game writing a breeze.
        </p>
      </div>
    </PageSection>
  );
}

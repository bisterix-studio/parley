import { SectionHeading } from "../../components/homepage/SectionHeading.tsx";
import { PageSection } from "../../components/PageSection.tsx";
import { SideBySide } from "../../components/SideBySide.tsx";

export function GraphViewSection() {
  return (
    <PageSection>
      <SideBySide mdColSplit="2/3" lgColSplit="2/3" class="!items-start">
        <div class="flex flex-col gap-4 md:sticky md:top-4 md:mt-8">
          <SectionHeading>
            Build complex dialogue sequences with ease
          </SectionHeading>
          <p>
            Parley utilises the inbuilt Godot Graph View system to provide a
            clear and easy way of writing and managing complex dialogue
            sequences at scale.
          </p>
          <p>Simple to write; easy to maintain.</p>
        </div>
        <div class="flex flex-col gap-4 h-full">
          <img
            src="/illustration/parley-graph-view.gif"
            class="w-full h-auto m-auto max-w-[48rem]"
            alt="Parley Graph View"
          />
        </div>
      </SideBySide>
    </PageSection>
  );
}

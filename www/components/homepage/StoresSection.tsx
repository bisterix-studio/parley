import { FancyLink } from "../../components/FancyLink.tsx";
import { PageSection } from "../../components/PageSection.tsx";
import { SideBySide } from "../../components/SideBySide.tsx";
import { SectionHeading } from "../../components/homepage/SectionHeading.tsx";
import { ExampleArrow } from "./ExampleArrow.tsx";

export function StoresSection() {
  return (
    <PageSection>
      <SideBySide
        mdColSplit="2/3"
        lgColSplit="2/3"
        class="!items-start"
      >
        <div class="flex flex-col gap-4 md:sticky md:top-4 md:mt-4">
          <SectionHeading>Stores for your data</SectionHeading>
          <p>
            Parley provides Fact, Action, and Character stores to manage data
            associated with each entity. These off the shelf building blocks can
            be used by nodes to customise the behaviour of dialogue sequences
            with ease.
          </p>
          <p>
            Examples include: conditionally displaying dialogue according to
            character attitude, triggering journal events, randomising the
            dialogue responses. The list goes on!
          </p>
          <FancyLink href="/docs/stores" class="mt-2">
            Learn more about stores
          </FancyLink>
        </div>
        <div class="flex flex-col gap-4 h-full">
          <img
            src="/illustration/action-store-view.png"
            class="w-full h-auto m-auto max-w-[48rem]"
            alt="Parley Graph View"
          />
          <ExampleArrow class="[transform:rotateY(-180deg)]" />
          <img
            src="/illustration/action-store-usage.png"
            class="w-full h-auto m-auto max-w-[48rem]"
            alt="Parley Graph View"
          />
        </div>
      </SideBySide>
    </PageSection>
  );
}

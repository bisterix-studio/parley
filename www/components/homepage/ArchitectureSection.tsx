import { FancyLink } from "../../components/FancyLink.tsx";
import { PageSection } from "../../components/PageSection.tsx";
import { SideBySide } from "../../components/SideBySide.tsx";
import { SectionHeading } from "../../components/homepage/SectionHeading.tsx";
import { CodeBlock } from "../CodeBlock.tsx";
import { CodeWindow } from "../CodeWindow.tsx";
import { ExampleArrow } from "./ExampleArrow.tsx";

export function ArchitectureSection() {
  return (
    <PageSection>
      <SideBySide
        mdColSplit="3/2"
        lgColSplit="3/2"
        reverseOnDesktop
        class="!items-start"
      >
        <div class="flex flex-col gap-4 md:sticky md:top-4 md:mt-4">
          <SectionHeading>Graph-based architecture</SectionHeading>
          <p>
            Parley uses graph-based architecture to offer a wide range of
            functionalities and an innately flexible approach to writing complex
            Dialogue Sequences.
          </p>
          <FancyLink href="/docs/concepts" class="mt-2">
            Learn more
          </FancyLink>
        </div>
        <div class="flex flex-col gap-4 relative">
          <img
            src="/illustration/parley-graph-view.png"
            class="w-full h-auto m-auto max-w-[48rem]"
            alt="Parley Graph View"
          />
          <ExampleArrow class="[transform:rotateY(-180deg)]" />
          <CodeWindow name="islands/Counter.tsx">
            <CodeBlock
              code={exampleDialogueSequenceJson}
              lang="json"
            />
          </CodeWindow>
        </div>
      </SideBySide>
    </PageSection>
  );
}

const exampleDialogueSequenceJson = `{
  "title": "All",
  "nodes": [
    // ...
    {
      "id": "node:3",
      "type": "DIALOGUE",
      // ...
      "text": "Look. I made a whatdyamacallit."
    },
    // ...
  ],
  "edges": [
    {
      "id": "edge:1",
      "from_node": "node:3",
      // ...
    }
  ]
}`;

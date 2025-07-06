// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import PARLEY_VERSIONS from "../versions.json" with { type: "json" };

type RawTableOfContents = Record<
  string,
  {
    label: string;
    content: Record<string, RawTableOfContentsEntry>;
  }
>;

interface RawTableOfContentsEntry {
  title: string;
  link?: string;
  pages?: [string, string, string?][];
}

const toc: RawTableOfContents = {
  latest: {
    label: PARLEY_VERSIONS[0],
    content: {
      introduction: {
        title: "Introduction",
      },
      "getting-started": {
        title: "Getting Started",
        pages: [
          ["installation", "Installation"],
          ["create-dialogue-sequence", "Create a Dialogue Sequence"],
          ["run-dialogue-sequence", "Run a Dialogue Sequence"],
          ["create-start-node", "Create a Start Node"],
          ["create-dialogue-node", "Create a Dialogue Node"],
          ["create-dialogue-option-node", "Create a Dialogue Option Node"],
          ["create-condition-node", "Create a Condition Node"],
          ["create-match-node", "Create a Match Node"],
          ["create-action-node", "Create an Action Node"],
          ["create-group-node", "Create a Group Node"],
          ["create-end-node", "Create an End Node"],
          ["register-fact", "Register a Fact"],
          ["register-action", "Register an Action"],
          ["register-character", "Register a Character"],
        ],
      },
      concepts: {
        title: "Concepts",
        pages: [
          ["architecture", "Architecture"],
          ["parley-runtime", "Parley Runtime"],
        ],
      },
      nodes: {
        title: "Nodes",
        pages: [
          ["dialogue-node", "Dialogue Node"],
          ["dialogue-option-node", "Dialogue Option Node"],
          ["condition-node", "Condition Node"],
          ["match-node", "Match Node"],
          ["action-node", "Action Node"],
          ["start-node", "Start Node"],
          ["end-node", "End Node"],
          ["group-node", "Group Node"],
        ],
      },
      stores: {
        title: "Stores",
        pages: [
          ["fact-store", "Fact Store"],
          ["action-store", "Action Store"],
          ["character-store", "Character Store"],
        ],
      },
      examples: {
        title: "Examples",
        pages: [],
      },
      reference: {
        title: "Reference",
        pages: [
          ["parley-settings", "Parley settings"],
        ],
      },
    },
  },
};

export default toc;

---
description: |
  Parley uses a graph-based architecture for its Dialogue Sequences. A Graph-based
  Architecture revolves around the concepts of nodes and edges. Here, nodes are the atomic
  building blocks of a graph and are linked together by
  edges.
---

Parley uses a graph-based architecture for its Dialogue Sequences. A Graph-based
Architecture revolves around the concepts of nodes and edges. Here, nodes are
the atomic building blocks of the graph and are linked together by edges.

## Dialogue Sequence

A Dialogue Sequence is a conversational structure for a branching dialogue
between multiple characters for a particular scene or scenes. They can include:

- The raw dialogue itself
- Options for the player to select
- Conditions to only render dialogue in certain situations
- Actions that trigger upon events within Dialogue Sequence.
- And much much more!

Under the hood in Parley, a Dialogue Sequence is a graph. These are built up of
Nodes (for example, a Dialogue Node and associated Dialogue Options). These are
connected together by edges to create the branching dialogue from start to
finish.

Parley utilises what is known as a directed-graph. This means that edges have a
direction, which is critical for defining how a Dialogue Sequence progresses.

The advantage of a graph-based architecture allows Parley to be highly-flexible
in how dialogues can be defined and at its core, gives the users to ability to
create highly complex branching dialogues (including loops and multiple paths)
whilst keeping it easy to maintain with a visual representation of the dialogue
that is strongly-tied to the underlying data structure.

## Node

The atomic building block of a Dialogue Sequence. Every piece of functionality
in Parley is at its core a Node. These can be defined and combined countless
times within a Dialogue Sequence to create highly intricate behaviours and
gameplay. The sky is the limit for how these can be combined!

For information about Nodes can be found [here](../nodes/index.md).

## Edge

A connection between two nodes. They have a direction defined by two attributes:

- "from Node"
- "to Node"

These tell Parley what the next Node(s) will be after processing the current
Node.

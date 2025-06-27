---
description: |
  Parley uses a graph-based architecture for its dialogue sequences. A Graph-based
  Architecture revolves around the concepts of nodes and edges. Here, nodes are the atomic
  building blocks of a graph and are linked together by
  edges.
---

Parley uses a graph-based architecture for its dialogue sequences. A Graph-based
Architecture revolves around the concepts of nodes and edges. Here, nodes are
the atomic building blocks of the graph and are linked together by edges.

## Dialogue Sequence

In Parley, a Dialogue Sequence is a graph. These are built up of Nodes (for
example, a dialogue node and associated dialogue options). These are connected
together by edges to create the branching dialogue from start to finish.

Parley utilises what is known as a directed-graph. This means that edges have a
direction, which is critical for defining how a dialogue sequence progresses.

The advantage of a graph-based architecture allows Parley to be highly-flexible
in how dialogues can be defined and at its core, gives the users to ability to
create highly complex branching dialogues (including loops and multiple paths)
whilst keeping it easy to maintain with a visual representation of the dialogue
that is strongly-tied to the underlying data structure.

## Node

The atomic building block of a Dialogue Sequence. Every piece of functionality
in Parley is at its core a node. These can be defined and combined countless
times within a dialogue sequence to create highly intricate behaviours and
gameplay. The sky is the limit for how these can be combined!

## Edge

A connection between two nodes. They have a direction defined by two attributes:

- "from node"
- "to node"

These tell Parley what the next node(s) will be after processing the current
node.

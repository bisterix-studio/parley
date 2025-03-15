# Match Node

A Match Node is useful for selecting the next node based on the well-known value
of a variable or expression.

![match-node](./images/match/match-node.png)

They have the following characteristics:

## Description

A human-readable description of the match node to aid future understanding of
the node at a quick glance.

## Fact

The fact to evaluate for the match node. These are stored in the fact store and
determine the available cases that can be used to select against.

## Cases

The values that are selected against. For example, if a fact evaluates to a
values of `WAVE` and there is a case called `WAVE`, then these will match. If a
node a node is connected to this case, then this will be next node that is
processed as part of the dialogue sequence.

Parley also supports a fallback case for when nothing is matched. This is useful
to ensure the dialogue can continue in these cases. However, it is optional as
one might not want a fallback case in these situations.

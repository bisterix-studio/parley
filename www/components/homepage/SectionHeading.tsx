import type { ComponentChildren } from "preact";

export function SectionHeading(
  { children }: { children: ComponentChildren },
) {
  return (
    <h2 class="text-3xl lg:text-4xl xl:text-5xl text-foreground-secondary font-bold text-balance">
      {children}
    </h2>
  );
}

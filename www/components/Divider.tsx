import { JSX } from "preact";

interface DividerProps {
  mode?: DividerMode;
}

export function Divider(props: DividerProps): JSX.Element {
  const { mode = DividerMode.SIMPLE } = props;
  switch (mode) {
    case DividerMode.SIMPLE: {
      return (
        <hr class="border-1 w-full my-4 sm:my-8 border-foreground-secondary/40 mx-6 lg:mx-12 rounded-md" />
      );
    }
    case DividerMode.AUTO: {
      return (
        <hr class="border-1 w-full my-4 sm:my-8 border-foreground-secondary/40 mx-auto rounded-md" />
      );
    }
    case DividerMode.NAVBAR: {
      return (
        <hr class="border-1 border-foreground-secondary/40 mx-4 sm:mx-16 2xl:mx-0 rounded-md" />
      );
    }
    default: {
      return (
        <div class="inline-flex items-center justify-center w-full">
          <hr class="w-full h-0.5 my-4 sm:my-8 bg-brand-primary border-0 rounded-md" />
        </div>
      );
    }
  }
}

export const DividerMode = {
  SIMPLE: "SIMPLE",
  AUTO: "AUTO",
  NAVBAR: "NAVBAR",
} as const;
export type DividerMode = (typeof DividerMode)[keyof typeof DividerMode];

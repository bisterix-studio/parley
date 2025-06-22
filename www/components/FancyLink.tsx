import type { ComponentChildren } from "preact";

export function FancyLink(
  props: { href: string; children: ComponentChildren; class?: string },
) {
  return (
    <a
      href={props.href}
      class={`group p-4 px-5 pb-3.5 bg-gradient-to-br from-foreground-secondary/60 to-foreground-secondary font-semibold rounded leading-none flex items-center justify-center hover:bg-foreground-secondary transition-colors duration-200 ease-in-out max-w-max text-balance text-background-primary ${
        props.class ?? ""
      }`}
    >
      {props.children}
      <svg
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        class="icon icon-tabler icon-tabler-arrow-right relative ml-2 bottom-[0.05em] transition-transform ease-out duration-150 group-hover:translate-x-1"
        width="1em"
        height="1em"
        viewBox="0 0 24 24"
        stroke-width="3"
        stroke="currentColor"
        fill="none"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <path stroke="none" d="M0 0h24v24H0z" fill="none" />
        <path d="M5 12l14 0" />
        <path d="M13 18l6 -6" />
        <path d="M13 6l6 6" />
      </svg>
    </a>
  );
}

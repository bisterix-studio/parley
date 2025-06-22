import type { JSX } from "preact";

const LINKS = [
  {
    title: "Source",
    href: "https://github.com/bisterix-studio/parley",
  },
  {
    title: "License",
    href: "https://github.com/bisterix-studio/parley/blob/main/LICENSE",
  },
  {
    title: "Code of Conduct",
    href:
      "https://github.com/bisterix-studio/parley/blob/main/CODE_OF_CONDUCT.md",
  },
];

export default function Footer(props: JSX.HTMLAttributes<HTMLElement>) {
  return (
    <footer
      class={`border-t-2 border-foreground-secondary/40 md:h-16 flex mt-16 justify-center md:mx-16 ${props.class}`}
    >
      <div class="flex flex-col sm:flex-row gap-4 justify-between items-center max-w-screen-xl mx-auto w-full sm:px-6 md:px-8 p-4">
        <div class="text-foreground-secondary text-center">
          <span>© {new Date().getFullYear()} Bisterix Studio</span>
        </div>

        <div class="flex items-center gap-8">
          {LINKS.map((link) => (
            <a
              href={link.href}
              class="text-foreground-secondary hover:underline"
              target="_blank"
            >
              {link.title}
            </a>
          ))}
          <a href="https://fresh.deno.dev" target="_blank">
            <img
              width="197"
              height="37"
              src="https://fresh.deno.dev/fresh-badge.svg"
              alt="Made with Fresh"
            />
          </a>
        </div>
      </div>
    </footer>
  );
}

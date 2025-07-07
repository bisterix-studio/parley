// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import ThemeToggle from "../islands/ThemeToggle.tsx";
import * as Icons from "./Icons.tsx";

// Adapted from: https://github.com/denoland/fresh

export default function NavigationBar(
  props: NavigationBarProps,
) {
  const items = [
    {
      name: "Docs",
      href: "/docs",
    },
    {
      name: "Showcase",
      href: "/showcase",
    },
  ];
  return (
    <nav class={"flex " + (props.class ?? "")} f-client-nav={false}>
      <ul class="flex items-center gap-x-2 sm:gap-4 mx-4 my-2 sm:my-6 flex-wrap lg:mx-8 2xl:mr-0">
        {items.map((item) => (
          <li key={item.name}>
            <a
              href={item.href}
              class="p-1 sm:p-2 text-foreground-secondary hover:underline aria-[current]:font-bold"
            >
              {item.name}
            </a>
          </li>
        ))}

        <li class="flex items-center">
          <a
            href="https://github.com/bisterix-studio/parley"
            class="hover:text-info inline-block transition"
            aria-label="GitHub"
            target="_blank"
          >
            <Icons.GitHub />
          </a>
        </li>
        <li class="flex items-center">
          <ThemeToggle />
        </li>
      </ul>
    </nav>
  );
}

interface NavigationBarProps {
  active?: string;
  class?: string;
}

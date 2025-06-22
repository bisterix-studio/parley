import { BisterixStudioLogo } from "./BisterixStudioLogo.tsx";
import { Divider } from "./Divider.tsx";
import NavigationBar from "./NavigationBar.tsx";

export default function Header(props: HeaderProps) {
  const isDocs = props.active == "/docs";
  const isSticky = isDocs;

  return (
    <header
      f-client-nav={false}
      class={[
        "z-50",
        isSticky ? "sticky top-0" : "",
      ].join(" ")}
    >
      <div
        class={[
          "mx-auto flex gap-3 items-center justify-between overflow-visible max-w-screen-2xl w-full h-20",
          isSticky ? "bg-background-primary" : "",
        ].join(" ")}
      >
        <div class="p-4 2xl:pl-0 h-full flex items-center">
          <a
            href="/"
            class="pr-4 h-full hidden sm:flex"
            aria-label="Top Page"
          >
            <BisterixStudioLogo
              class="sm:border-r-[1px] sm:border-foreground-secondary/40 pr-4"
              aria-label="Bisterix Studio logo"
              preserveAspectRatio="xMinYMin"
            />
            <p class="pl-4 my-auto text-2xl">Parley</p>
          </a>
        </div>
        <NavigationBar class="" active={props.active} />
      </div>
      <Divider mode="NAVBAR" />
    </header>
  );
}

interface HeaderProps {
  title: string;
  active?: string;
}

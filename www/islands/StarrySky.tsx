// @ts-types="@types/animejs"
import anime from "animejs";
import { ComponentChildren } from "preact";
import { useCallback, useEffect, useState } from "preact/hooks";

interface StarrySkyProps {
  children: ComponentChildren;
}

export default function StarrySky(props: StarrySkyProps) {
  const [num] = useState(60);
  const [vw] = useState(globalThis.innerWidth ?? 0);
  const [vh] = useState(globalThis.innerHeight ?? 0);
  const getRandomX = useCallback(
    (): number => Math.floor(Math.random() * Math.floor(vw)),
    [vw],
  );
  const getRandomY = useCallback(
    (): number => Math.floor(Math.random() * Math.floor(vh)),
    [vh],
  );

  useEffect(() => {
    starryNight();
    shootingStars();
  }, [vw, vh]);

  return (
    <div class="w-full h-full min-h-screen bg-background-primary -z-10">
      <svg
        class="w-[100vw] h-[100vh] min-h-screen fixed overflow-clip m-0 p-0"
        id="sky"
      >
        {[...Array(num)].map((_x, y) => (
          <circle
            cx={getRandomX()}
            cy={getRandomY()}
            r={randomRadius()}
            stroke="none"
            strokeWidth="0"
            fill="white"
            key={y}
            className="star"
          />
        ))}
      </svg>
      <div
        class="w-[150vh] h-[100vw] m-0 p-0 fixed overflow-clip"
        id="shootingstars"
      >
        {[...Array(60)].map((_x, y) => (
          <div
            key={y}
            className="wish"
            style={{
              left: `${getRandomY()}px`,
              top: `${getRandomX()}px`,
              height: "2px",
              width: "100px",
              margin: 0,
              opacity: 0,
              padding: 0,
            }}
          />
        ))}
      </div>
      {props.children}
    </div>
  );
}

function starryNight(): void {
  anime({
    targets: ["#sky .star"],
    opacity: [
      { duration: 700, value: "0" },
      { duration: 700, value: "1" },
    ],
    easing: "linear",
    loop: true,
    delay: (_: unknown, i: number) => 50 * i,
  });
}
function shootingStars(): void {
  anime({
    targets: ["#shootingstars .wish"],
    easing: "linear",
    loop: true,
    delay: (_: unknown, i: number) => 2000 * i,
    opacity: [{ duration: 700, value: "1" }],
    width: [
      { value: "150px" },
      { value: "0px" },
    ],
    translateX: 350,
  });
}

function randomRadius(): number {
  return Math.random() * 0.7 + 0.6;
}

import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";

export const Route = createFileRoute("/")({ component: Home });

const LAPS_KEY = "mikerun-laps";

const facts = [
  { k: "Ticker", v: "MICRUN" },
  { k: "Pair", v: "MU" },
  { k: "Line", v: "He runs. Micron remembers." },
  { k: "Site", v: "mikerun.lol" },
];

export function Home() {
  const [laps, setLaps] = useState(0);
  const [burst, setBurst] = useState(0);

  useEffect(() => {
    const saved = Number(window.localStorage.getItem(LAPS_KEY) ?? "0");
    if (Number.isFinite(saved)) setLaps(saved);
  }, []);

  function runLap() {
    const next = laps + 1;
    setLaps(next);
    setBurst((n) => n + 1);
    window.localStorage.setItem(LAPS_KEY, String(next));
  }

  return (
    <main className="mx-auto max-w-5xl px-4 pb-20 pt-6">
      <header className="flex items-end justify-between gap-4">
        <p className="font-display text-2xl tracking-wide text-cream">MICRUN</p>
        <p className="text-right text-sm text-mute">
          anchored to MU
          <br />
          <a href="https://x.com/micrun_mu" className="text-cream">
            @micrun_mu
          </a>
        </p>
      </header>

      <section className="mt-6 overflow-hidden rounded-2xl border border-line bg-panel">
        <img
          src="/mikerun/banner.png"
          alt="MIKERUN, tires for legs, fire behind the sprint"
          className="block max-h-[28rem] w-full object-cover object-center"
        />
      </section>

      <section className="mt-8 grid gap-6 md:grid-cols-[1.4fr_0.8fr] md:items-end">
        <div>
          <p className="font-display text-6xl leading-none text-cream sm:text-8xl">MIKERUN</p>
          <p className="mt-4 max-w-xl text-xl text-gold">He runs. Micron remembers.</p>
          <p className="mt-3 max-w-xl text-base leading-relaxed text-mute">
            The legs are tires. The lap does not end. Memory is the only thing that keeps the pace.
            Anchored to MU. Not Tyson. Not Micron.
          </p>
        </div>
        <div className="rounded-2xl border border-line bg-panel p-5">
          <p className="text-sm text-mute">Laps on this browser</p>
          <p className="font-display text-6xl leading-none text-cream">{laps}</p>
          <div className="relative mt-4 h-2 overflow-hidden rounded-full bg-ink">
            <span key={burst} className="lap-dot absolute top-0 h-2 w-8 rounded-full bg-ember" />
          </div>
          <button
            type="button"
            onClick={runLap}
            className="mt-5 min-h-11 w-full rounded-full bg-ember px-5 text-base font-bold text-ink"
          >
            Run a lap
          </button>
        </div>
      </section>

      <section className="mt-8 grid grid-cols-2 gap-3 md:grid-cols-4">
        {facts.map((fact) => (
          <article key={fact.k} className="rounded-2xl border border-line bg-panel p-4">
            <p className="text-xs uppercase tracking-widest text-mute">{fact.k}</p>
            <p className="mt-2 text-lg font-bold text-cream">{fact.v}</p>
          </article>
        ))}
      </section>

      <section className="mt-10 grid gap-3 md:grid-cols-3">
        <figure className="overflow-hidden rounded-2xl border border-line md:col-span-1">
          <img src="/mikerun/track.png" alt="Runner on the track, tires for legs" className="h-full w-full object-cover" />
        </figure>
        <figure className="overflow-hidden rounded-2xl border border-line md:col-span-2">
          <img src="/mikerun/tires.jpg" alt="Two tires burning down a red track" className="h-full max-h-80 w-full object-cover" />
        </figure>
        <figure className="overflow-hidden rounded-2xl border border-line md:col-span-1">
          <img src="/mikerun/line.jpg" alt="Starting line, black kit, wheels for legs" className="h-full max-h-96 w-full object-cover" />
        </figure>
        <article className="flex flex-col justify-between rounded-2xl border border-line bg-panel p-6 md:col-span-2">
          <p className="font-display text-5xl leading-none text-cream">DISCIPLINE BUILDS FREEDOM</p>
          <p className="mt-4 text-base leading-relaxed text-mute">
            One lap is a click. The ticker is MICRUN. The stock on the other side is MU. The cow already
            moos. This one just runs.
          </p>
        </article>
      </section>

      <footer className="mt-12 text-sm text-mute">
        MIKERUN is a joke. Not Mike Tyson. Not Micron Technology.
      </footer>
    </main>
  );
}

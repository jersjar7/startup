import React from 'react';
import { markFor } from '../components/brand/ChapterCoin';
import './heroProblems.css';

// The hero's drawing: one lifted card of graph paper that works a real FE
// problem from five chapters in turn, six seconds each (30s loop). Every
// answer is correct and every drawing is to scale with standard symbols;
// engineers read these, so check both before changing anything.
//
//   Structural      Pratt truss, 24 kN at G, cut through FG, FC, BC.
//                   Moments about F on the left part: 12(3) = 3 BC, so BC = 12 kN (T).
//   Fluid           Continuity, V2 = V1 (D1/D2)^2 = 2 (0.30/0.15)^2 = 8 m/s.
//                   The narrow pipe is drawn at half the height and the dots move 4x faster.
//   Transportation  Crest curve G1 +3%, G2 -2%, L 400 ft: x = G1 L / (G1 - G2) = 240 ft.
//   Surveying       Elev B = 100.00 + 1.52 - 0.87 = 100.65 m (rods drawn to that scale).
//   Geotechnical    18(2) + 20(4) - 9.81(4) = 76.8 kPa.
//
// The animation is CSS only (no library, no video). It pauses while the hero is
// off screen and stays on the first scene, fully drawn, for reduced motion.
const SCENES = [
  { id: 'structural', cap: 'Structural · Method of sections', accent: 'forest', ans: 'BC = 12 kN (T)', ax: 300 },
  { id: 'fluid-mechanics', cap: 'Fluid mechanics · Continuity', accent: 'forest', ans: 'V₂ = 8 m/s', ax: 330 },
  { id: 'transportation', cap: 'Transportation · Crest curve', accent: 'sunbeam', ans: 'high point 240 ft from PVC', ax: 200 },
  { id: 'surveying', cap: 'Surveying · Differential leveling', accent: 'ember', ans: 'Elev B = 100.65 m', ax: 300 },
  { id: 'geotechnical', cap: 'Geotechnical · Effective stress', accent: 'ember', ans: 'σ′ at P = 76.8 kPa', ax: 250 },
];

const hatch = (x0, x1, y, cls = 'hp-m hp-thin') =>
  Array.from({ length: Math.floor((x1 - x0 - 8) / 9) + 1 }, (_, i) => {
    const x = x0 + 8 + i * 9;
    return <line key={x} className={cls} x1={x} y1={y} x2={x - 7} y2={y + 8} />;
  });

// stagger helper for strokes that draw themselves
const o = (s) => ({ '--o': `${s}s` });

function Structural() {
  const members = [[70, 250, 490, 250], [175, 145, 385, 145], [70, 250, 175, 145], [385, 145, 490, 250],
    [175, 145, 175, 250], [280, 145, 280, 250], [385, 145, 385, 250], [175, 145, 280, 250], [385, 145, 280, 250]];
  const nodes = [[70, 250, 'A', -30, 4], [175, 250, 'B', 10, 24], [280, 250, 'C', 10, 24], [385, 250, 'D', 10, 24],
    [490, 250, 'E', 20, 4], [175, 145, 'F', -18, -12], [280, 145, 'G', -18, -12], [385, 145, 'H', -18, -12]];
  return (
    <>
      {members.map(([a, b, c, d], i) => (
        <line key={i} className="hp-m hp-draw" pathLength="1" style={o(i * 0.05)} x1={a} y1={b} x2={c} y2={d} />
      ))}
      <g className="hp-fade">
        <path d="M70 254 l-14 22 h28 z" className="hp-n" />
        <circle cx="490" cy="266" r="10" className="hp-n" />
        <line className="hp-m hp-thin" x1="46" y1="277" x2="94" y2="277" />{hatch(46, 94, 277)}
        <line className="hp-m hp-thin" x1="466" y1="277" x2="514" y2="277" />{hatch(466, 514, 277)}
        {nodes.map(([x, y, t, dx, dy]) => (
          <g key={t}><circle cx={x} cy={y} r="6.5" className="hp-n" /><text className="hp-lbl" x={x + dx} y={y + dy}>{t}</text></g>
        ))}
      </g>
      <g className="hp-drop">
        <line x1="280" y1="58" x2="280" y2="128" className="hp-m" strokeWidth="3.5" />
        <path d="M270 122 l10 16 l10 -16 z" className="hp-ink" />
        <text className="hp-giv" x="292" y="78">24 kN</text>
      </g>
      <line className="hp-ember hp-wy1" x1="228" y1="108" x2="228" y2="292" strokeWidth="2.5" strokeDasharray="8 7" />
      <line className="hp-ember hp-dl" pathLength="1" x1="175" y1="250" x2="280" y2="250" strokeWidth="6" strokeLinecap="round" />
    </>
  );
}

function Fluid() {
  return (
    <>
      <path className="hp-water hp-fill" d="M60 110 H230 L300 140 H500 V200 H300 L230 230 H60 Z" />
      <path className="hp-m hp-draw" pathLength="1" d="M60 110 H230 L300 140 H500" />
      <path className="hp-m hp-draw" pathLength="1" style={o(0.1)} d="M60 230 H230 L300 200 H500" />
      <line className="hp-m hp-thin hp-mute hp-fade-early" x1="60" y1="170" x2="500" y2="170" strokeDasharray="6 8" />
      <g className="hp-fade">
        <text className="hp-giv" x="80" y="96">D₁ = 0.30 m</text>
        <text className="hp-giv" x="330" y="126">D₂ = 0.15 m</text>
        <text className="hp-giv" x="80" y="262">V₁ = 2 m/s</text>
      </g>
      <g className="hp-fade">
        {[-1, 0, 1].map((lane) => [0, 1, 2, 3].map((k) => (
          <circle key={`${lane}${k}`} className={`hp-dot hp-dot--${lane === 0 ? 'mid' : lane < 0 ? 'top' : 'bot'}`}
            cx="60" cy="170" r="4.5" style={{ animationDelay: `${-k * 0.8}s` }} />
        )))}
      </g>
    </>
  );
}

function crestPath() {
  let d = '';
  for (let x = 0; x <= 400; x += 10) {
    const y = 230 - (0.03 * x - 0.05 * x * x / 800) * 12;   // 1 px per ft, vertical x12
    d += `${x ? 'L' : 'M'}${80 + x} ${y.toFixed(1)}`;
  }
  return d;
}

function Transportation() {
  return (
    <>
      <path className="hp-m hp-thin hp-mute hp-draw" pathLength="1" d="M80 262 V278 M80 270 H480 M480 262 V278" />
      <line className="hp-m hp-thin hp-mute hp-fade-early" x1="80" y1="230" x2="280" y2="158" strokeDasharray="6 7" />
      <line className="hp-m hp-thin hp-mute hp-fade-early" x1="280" y1="158" x2="480" y2="206" strokeDasharray="6 7" />
      <path className="hp-m hp-draw" pathLength="1" style={o(0.15)} d={crestPath()} />
      <g className="hp-fade">
        {[[80, 230, 'PVC'], [280, 158, 'PVI'], [480, 206, 'PVT']].map(([x, y, t]) => (
          <g key={t}><circle cx={x} cy={y} r="6" className="hp-n" /><text className="hp-lbl" x={x - 16} y={y - 14}>{t}</text></g>
        ))}
        <text className="hp-giv" x="120" y="185">+3%</text>
        <text className="hp-giv" x="400" y="160">-2%</text>
        <text className="hp-giv" x="355" y="294">L = 400 ft</text>
      </g>
      <line className="hp-ember hp-in-c" x1="320" y1="186.8" x2="320" y2="270" strokeWidth="2.5" strokeDasharray="6 6" />
      <circle className="hp-crest-dot" cx="80" cy="230" r="8" />
    </>
  );
}

function Surveying() {
  return (
    <>
      <path className="hp-m hp-thin hp-mute hp-draw" pathLength="1" d="M50 262 L110 250 L280 236 L450 207 L510 200" />
      <g className="hp-fade-early">
        <rect className="hp-n" x="100" y="110" width="20" height="140" rx="3" />
        <rect className="hp-n" x="440" y="110" width="20" height="97" rx="3" />
        {Array.from({ length: 13 }, (_, i) => <line key={`a${i}`} className="hp-m hp-thin" x1="100" x2="110" y1={120 + i * 10} y2={120 + i * 10} />)}
        {Array.from({ length: 9 }, (_, i) => <line key={`b${i}`} className="hp-m hp-thin" x1="440" x2="450" y1={120 + i * 10} y2={120 + i * 10} />)}
      </g>
      {/* an automatic level on its tripod: legs spread down to the ground */}
      <g className="hp-fade-early" style={o(0.3)}>
        <path className="hp-m" d="M280 172 L250 238 M280 172 L282 235 M280 172 L312 231" />
        <rect className="hp-n" x="264" y="166" width="32" height="7" rx="2" />
        <rect className="hp-n" x="270" y="159" width="20" height="7" rx="2" />
        <rect className="hp-n" x="256" y="141" width="48" height="18" rx="6" />
        <rect className="hp-n" x="304" y="145" width="7" height="10" rx="2" />
      </g>
      <line className="hp-ember hp-wx1 hp-from-right" x1="120" y1="150" x2="256" y2="150" strokeWidth="2.5" />
      <line className="hp-ember hp-wx2" x1="311" y1="150" x2="440" y2="150" strokeWidth="2.5" />
      <g className="hp-fade">
        <text className="hp-lbl" x="88" y="284">A</text>
        <text className="hp-giv" x="60" y="304">BM 100.00 m</text>
        <text className="hp-lbl" x="444" y="232">B</text>
      </g>
      <text className="hp-giv hp-in-a" x="128" y="140">BS 1.52</text>
      <text className="hp-giv hp-in-b" x="370" y="140">FS 0.87</text>
    </>
  );
}

function Geotechnical() {
  return (
    <>
      <rect className="hp-water hp-fy" x="150" y="140" width="250" height="120" />
      <path className="hp-m hp-draw" pathLength="1" d="M130 80 H420" />
      <path className="hp-m hp-draw" pathLength="1" style={o(0.15)} d="M130 260 H420" />
      <line className="hp-wt hp-fade-early" x1="150" y1="140" x2="400" y2="140" strokeDasharray="7 6" />
      <path className="hp-m hp-thin hp-mute hp-draw" pathLength="1" style={o(0.1)} d="M110 80 V260 M103 80 H117 M103 140 H117 M103 260 H117" />
      <g className="hp-fade">
        {hatch(130, 420, 80, 'hp-m hp-thin hp-mute')}
        <path d="M352 128 l8 12 l8 -12 z" className="hp-wt-fill" />
        <line x1="353" y1="146" x2="367" y2="146" className="hp-wt" />
        <line x1="356" y1="151" x2="364" y2="151" className="hp-wt" />
        <text className="hp-lbl" x="372" y="132">WT</text>
        <text className="hp-giv" x="170" y="116">γ = 18 kN/m³</text>
        <text className="hp-giv" x="170" y="205">γsat = 20 kN/m³</text>
        <text className="hp-lbl" x="62" y="116">2 m</text>
        <text className="hp-lbl" x="62" y="205">4 m</text>
        <circle cx="275" cy="260" r="7" className="hp-ink" />
        <text className="hp-giv" x="288" y="284">P</text>
      </g>
    </>
  );
}

const BODIES = [Structural, Fluid, Transportation, Surveying, Geotechnical];

function Coin({ id, accent, style, className }) {
  return (
    <span className={`hp-coin coin coin--${accent} ${className}`} style={style} aria-hidden="true">
      <span className="coin-rim" />
      <span className="coin-face"><img src={markFor(id)} alt="" width="96" height="96" draggable="false" /></span>
    </span>
  );
}

export function HeroProblems() {
  const ref = React.useRef(null);
  const [placed, setPlaced] = React.useState(false);

  // Desktop: the card's top edge lines up with the hero overline, and the card
  // (with its front coin) shrinks if needed to clear the FE4 RACCOONS lockup
  // by 32px. Narrow screens stack it under the text, sized to the column.
  React.useLayoutEffect(() => {
    const el = ref.current;
    const hero = el?.closest('.hero');
    if (!el || !hero) return undefined;
    const place = () => {
      const stacked = window.matchMedia('(max-width: 1024px)').matches;
      if (stacked) {
        el.style.top = ''; el.style.left = '';
        el.style.setProperty('--hp-s', Math.min(1, el.clientWidth / 560));
      } else {
        const hr = hero.getBoundingClientRect();
        const top = hero.querySelector('.hero-overline').getBoundingClientRect().top - hr.top;
        const lock = hero.querySelector('.hero-lockup').getBoundingClientRect().top - hr.top;
        const s = Math.max(0.6, Math.min(1, (lock - 32 - top) / 372));
        el.style.setProperty('--hp-s', s);
        el.style.top = `${top}px`;
        el.style.left = `${Math.min(hr.width - 560 * s - 90, hr.width * 0.5)}px`;
      }
      setPlaced(true);
    };
    place();
    const ro = new ResizeObserver(place);
    ro.observe(hero);
    document.fonts?.ready.then(place);
    return () => ro.disconnect();
  }, []);

  // Pause every animation while the hero is off screen.
  React.useEffect(() => {
    const el = ref.current;
    if (!el || !('IntersectionObserver' in window)) return undefined;
    const io = new IntersectionObserver(([e]) => el.classList.toggle('hp--paused', !e.isIntersecting));
    io.observe(el);
    return () => io.disconnect();
  }, []);

  return (
    <div className={`hp ${placed ? 'is-placed' : ''}`} ref={ref} aria-hidden="true">
      <div className="hp-box">
        <div className="hp-float hp-float--back">
          {SCENES.map((s, i) => (
            <Coin key={s.id} id={SCENES[(i + 1) % 5].id} accent={SCENES[(i + 1) % 5].accent}
              className="hp-coin--back" style={{ '--d': `${i * 6}s` }} />
          ))}
        </div>
        <div className="hp-float hp-float--card">
          <div className="hp-card">
            {SCENES.map((s, i) => {
              const Body = BODIES[i];
              return (
                <div key={s.id} className="hp-scene" style={{ '--d': `${i * 6}s` }}>
                  <span className="hp-cap">{s.cap}</span>
                  <svg viewBox="0 0 560 340" width="560" height="340"><Body /></svg>
                  <span className="hp-ans" style={{ left: s.ax }}>{s.ans}</span>
                </div>
              );
            })}
          </div>
        </div>
        <div className="hp-float hp-float--front">
          {SCENES.map((s, i) => (
            <Coin key={s.id} id={s.id} accent={s.accent} className="hp-coin--front" style={{ '--d': `${i * 6}s` }} />
          ))}
        </div>
      </div>
    </div>
  );
}

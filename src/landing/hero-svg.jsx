import React from 'react';

const PHASE_TOPICS = [
  'Structural Analysis',
  'Fluid Mechanics',
  'Circuits',
  'Surveying',
  'Geotechnical',
];

/* ── Phase 1: Truss Bridge ── */
function Truss() {
  return (
    <g className="svg-phase svg-phase--1">
      {/* Bottom chord */}
      <line x1="200" y1="500" x2="1000" y2="500" className="svg-line svg-draw" />
      {/* Top chord */}
      <line x1="350" y1="320" x2="850" y2="320" className="svg-line svg-draw" />
      {/* Verticals */}
      <line x1="350" y1="500" x2="350" y2="320" className="svg-line svg-draw" />
      <line x1="500" y1="500" x2="500" y2="320" className="svg-line svg-draw" />
      <line x1="650" y1="500" x2="650" y2="320" className="svg-line svg-draw" />
      <line x1="800" y1="500" x2="800" y2="320" className="svg-line svg-draw" />
      {/* Diagonals */}
      <line x1="200" y1="500" x2="350" y2="320" className="svg-line svg-draw" />
      <line x1="350" y1="500" x2="500" y2="320" className="svg-line svg-draw" />
      <line x1="500" y1="500" x2="650" y2="320" className="svg-line svg-draw" />
      <line x1="650" y1="500" x2="800" y2="320" className="svg-line svg-draw" />
      <line x1="800" y1="500" x2="1000" y2="500" className="svg-line svg-draw" />
      <line x1="850" y1="320" x2="1000" y2="500" className="svg-line svg-draw" />
      {/* Force arrows */}
      <line x1="500" y1="220" x2="500" y2="310" className="svg-arrow svg-draw" />
      <polygon points="492,305 500,320 508,305" className="svg-arrow-head" />
      <line x1="650" y1="200" x2="650" y2="310" className="svg-arrow svg-draw" />
      <polygon points="642,305 650,320 658,305" className="svg-arrow-head" />
      <line x1="800" y1="230" x2="800" y2="310" className="svg-arrow svg-draw" />
      <polygon points="792,305 800,320 808,305" className="svg-arrow-head" />
      {/* Nodes */}
      {[
        [200, 500], [350, 500], [500, 500], [650, 500], [800, 500], [1000, 500],
        [350, 320], [500, 320], [650, 320], [800, 320], [850, 320],
      ].map(([cx, cy], i) => (
        <circle key={i} cx={cx} cy={cy} r="4" className="svg-node svg-node-pulse" />
      ))}
    </g>
  );
}

/* ── Phase 2: Fluid Mechanics ── */
function Fluid() {
  return (
    <g className="svg-phase svg-phase--2">
      {/* Flow paths */}
      <path d="M150,300 C300,280 400,350 550,320 C700,290 800,370 1050,340" className="svg-flow svg-draw" />
      <path d="M150,400 C320,370 420,440 580,410 C740,380 850,450 1050,420" className="svg-flow svg-draw" />
      <path d="M150,500 C280,480 400,530 560,500 C720,470 840,540 1050,510" className="svg-flow svg-draw" />
      <path d="M200,240 C340,220 440,290 600,260 C760,230 880,300 1000,270" className="svg-flow svg-draw" />
      <path d="M180,580 C310,560 430,620 590,590 C750,560 870,620 1050,600" className="svg-flow svg-draw" />
      {/* Vortex */}
      <circle cx="700" cy="420" r="40" className="svg-vortex" fill="none" />
    </g>
  );
}

/* ── Phase 3: Circuits ── */
function Circuits() {
  return (
    <g className="svg-phase svg-phase--3">
      {/* Main paths */}
      <line x1="250" y1="350" x2="450" y2="350" className="svg-line svg-draw" />
      <line x1="550" y1="350" x2="750" y2="350" className="svg-line svg-draw" />
      <line x1="850" y1="350" x2="950" y2="350" className="svg-line svg-draw" />
      <line x1="950" y1="350" x2="950" y2="500" className="svg-line svg-draw" />
      <line x1="950" y1="500" x2="750" y2="500" className="svg-line svg-draw" />
      <line x1="650" y1="500" x2="450" y2="500" className="svg-line svg-draw" />
      <line x1="350" y1="500" x2="250" y2="500" className="svg-line svg-draw" />
      <line x1="250" y1="500" x2="250" y2="350" className="svg-line svg-draw" />
      {/* Resistors */}
      <rect x="450" y="340" width="100" height="20" rx="2" className="svg-resistor" />
      <rect x="350" y="490" width="100" height="20" rx="2" className="svg-resistor" />
      {/* Capacitors */}
      <line x1="750" y1="340" x2="750" y2="360" className="svg-cap svg-draw" />
      <line x1="730" y1="340" x2="770" y2="340" className="svg-cap svg-draw" />
      <line x1="730" y1="360" x2="770" y2="360" className="svg-cap svg-draw" />
      <line x1="650" y1="490" x2="650" y2="510" className="svg-cap svg-draw" />
      <line x1="630" y1="490" x2="670" y2="490" className="svg-cap svg-draw" />
      <line x1="630" y1="510" x2="670" y2="510" className="svg-cap svg-draw" />
      {/* Voltage source */}
      <circle cx="850" cy="425" r="18" className="svg-vsource" fill="none" />
      <line x1="850" y1="407" x2="850" y2="350" className="svg-line svg-draw" />
      <line x1="850" y1="443" x2="850" y2="500" className="svg-line svg-draw" />
      <line x1="843" y1="420" x2="857" y2="420" className="svg-vsource-mark" />
      <line x1="850" y1="413" x2="850" y2="427" className="svg-vsource-mark" />
      <line x1="843" y1="432" x2="857" y2="432" className="svg-vsource-mark" />
      {/* Nodes */}
      {[
        [250, 350], [950, 350], [950, 500], [250, 500],
        [500, 350], [750, 350], [650, 500], [400, 500],
      ].map(([cx, cy], i) => (
        <circle key={i} cx={cx} cy={cy} r="3.5" className="svg-node svg-node-pulse" />
      ))}
    </g>
  );
}

/* ── Phase 4: Surveying ── */
function Surveying() {
  return (
    <g className="svg-phase svg-phase--4">
      {/* Triangulation lines */}
      <line x1="300" y1="550" x2="600" y2="280" className="svg-survey svg-draw" />
      <line x1="600" y1="280" x2="900" y2="520" className="svg-survey svg-draw" />
      <line x1="900" y1="520" x2="300" y2="550" className="svg-survey svg-draw" />
      <line x1="600" y1="280" x2="450" y2="450" className="svg-survey svg-draw" />
      <line x1="450" y1="450" x2="750" y2="430" className="svg-survey svg-draw" />
      <line x1="750" y1="430" x2="600" y2="280" className="svg-survey svg-draw" />
      {/* Angle arcs */}
      <path d="M320,540 A30,30 0 0,1 310,520" className="svg-arc svg-draw" fill="none" />
      <path d="M620,295 A30,30 0 0,1 585,295" className="svg-arc svg-draw" fill="none" />
      <path d="M880,515 A30,30 0 0,0 890,495" className="svg-arc svg-draw" fill="none" />
      {/* Dashed sight lines */}
      <line x1="300" y1="550" x2="150" y2="580" className="svg-sight svg-draw" />
      <line x1="600" y1="280" x2="600" y2="160" className="svg-sight svg-draw" />
      <line x1="900" y1="520" x2="1050" y2="560" className="svg-sight svg-draw" />
      {/* Survey points */}
      {[
        [300, 550], [600, 280], [900, 520], [450, 450], [750, 430],
      ].map(([cx, cy], i) => (
        <circle key={i} cx={cx} cy={cy} r="5" className="svg-node svg-node-pulse" />
      ))}
    </g>
  );
}

/* ── Phase 5: Geotechnical ── */
function Geotech() {
  return (
    <g className="svg-phase svg-phase--5">
      {/* Foundation */}
      <rect x="450" y="300" width="300" height="60" rx="4" className="svg-foundation" />
      {/* Soil strata */}
      <path d="M150,360 C300,355 500,370 700,358 C850,350 1000,365 1100,360" className="svg-strata svg-strata--1 svg-draw" />
      <path d="M150,430 C280,425 480,445 680,432 C840,422 1000,440 1100,430" className="svg-strata svg-strata--2 svg-draw" />
      <path d="M150,500 C320,495 490,510 700,502 C870,496 1000,508 1100,500" className="svg-strata svg-strata--3 svg-draw" />
      <path d="M150,570 C300,567 510,578 720,570 C880,564 1010,575 1100,570" className="svg-strata svg-strata--4 svg-draw" />
      <path d="M150,640 C290,636 500,648 710,640 C860,634 1000,644 1100,640" className="svg-strata svg-strata--5 svg-draw" />
      {/* Soil particles */}
      {[
        [220, 390], [380, 400], [550, 385], [720, 395], [880, 388], [1000, 392],
        [260, 460], [420, 470], [600, 455], [760, 465], [920, 458],
        [200, 530], [350, 540], [530, 525], [700, 535], [860, 528], [980, 532],
        [280, 600], [450, 608], [640, 595], [810, 605], [950, 598],
      ].map(([cx, cy], i) => (
        <circle key={i} cx={cx} cy={cy} r="2" className="svg-particle" />
      ))}
    </g>
  );
}

/* ── Main exported components ── */

export function HeroSvg() {
  return (
    <svg
      className="hero-svg"
      viewBox="0 0 1200 800"
      preserveAspectRatio="xMidYMid meet"
      aria-hidden="true"
    >
      <Truss />
      <Fluid />
      <Circuits />
      <Surveying />
      <Geotech />
    </svg>
  );
}

export function TopicLabel() {
  const [index, setIndex] = React.useState(0);
  const [visible, setVisible] = React.useState(true);
  const startRef = React.useRef(null);

  React.useEffect(() => {
    // Sync label to the same 15s / 5-phase cycle as the CSS animations
    const CYCLE = 15000; // total loop duration (ms)
    const PHASE = 3000;  // each phase duration (ms)
    const FADE  = 400;   // fade-out time before switching text

    startRef.current = performance.now();

    let rafId;
    let lastPhase = -1;

    function tick() {
      const elapsed = performance.now() - startRef.current;
      const posInCycle = elapsed % CYCLE;
      const currentPhase = Math.min(Math.floor(posInCycle / PHASE), 4);

      if (currentPhase !== lastPhase) {
        // Phase changed — fade out, swap text, fade in
        setVisible(false);
        setTimeout(() => {
          setIndex(currentPhase);
          setVisible(true);
        }, FADE);
        lastPhase = currentPhase;
      }

      rafId = requestAnimationFrame(tick);
    }

    rafId = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(rafId);
  }, []);

  return (
    <div className="hero-topic-label" aria-live="polite">
      <span className="hero-topic-dot" />
      <span className={`hero-topic-text ${visible ? 'is-visible' : 'is-hidden'}`}>
        {PHASE_TOPICS[index]}
      </span>
    </div>
  );
}

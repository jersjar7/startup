import React from 'react';
import {
  AbsoluteFill, Series, Audio, staticFile, useCurrentFrame, useVideoConfig, interpolate, spring,
} from 'remotion';
import { loadFont as loadDM } from '@remotion/google-fonts/DMSans';
import { loadFont as loadInter } from '@remotion/google-fonts/Inter';
import { loadFont as loadMono } from '@remotion/google-fonts/JetBrainsMono';

const dm = loadDM().fontFamily;
const inter = loadInter().fontFamily;
const mono = loadMono().fontFamily;

export const FPS = 30;
const S1 = 90, S2 = 165, S3 = 240, S4 = 165, S5 = 120;
export const DURATION_IN_FRAMES = S1 + S2 + S3 + S4 + S5; // 780 = 26s

const C = {
  cream: '#FFF9F0', creamDark: '#F5EDE0', charcoal: '#2C2C2C',
  ember: '#E8683A', emberBg: '#FEF0EA', sunbeam: '#F5B731',
  forest: '#2D7A5F', gray: '#6B6B6B',
};

// Entrance: spring fade + rise. delay in frames.
function enter(frame, fps, delay = 0, damping = 200) {
  const s = spring({ frame: frame - delay, fps, config: { damping } });
  return { opacity: interpolate(s, [0, 1], [0, 1]), y: interpolate(s, [0, 1], [24, 0]), s };
}
// Exit fade over the last `len` frames of a scene of length `total`.
function exitFade(frame, total, len = 12) {
  return interpolate(frame, [total - len, total], [1, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' });
}

const Bg = ({ children }) => (
  <AbsoluteFill style={{ background: C.cream, fontFamily: inter, justifyContent: 'center', alignItems: 'center' }}>
    {/* ember accent bar, brand signature */}
    <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 8, background: C.ember }} />
    {children}
  </AbsoluteFill>
);

const Overline = ({ children, color = C.ember }) => (
  <span style={{ fontFamily: dm, fontWeight: 600, fontSize: 26, letterSpacing: 6, textTransform: 'uppercase', color }}>
    {children}
  </span>
);

/* ── Scene 1: Brand ── */
function SceneBrand() {
  const frame = useCurrentFrame(); const { fps } = useVideoConfig();
  const e = enter(frame, fps, 0, 12);
  const op = exitFade(frame, S1);
  return (
    <Bg>
      <div style={{ textAlign: 'center', opacity: e.opacity * op, transform: `scale(${interpolate(e.s, [0, 1], [0.9, 1])})` }}>
        <div style={{ fontFamily: dm, fontWeight: 700, fontSize: 180, letterSpacing: -6, lineHeight: 1, color: C.charcoal }}>
          FE<span style={{ color: C.ember }}>4</span>
        </div>
        <div style={{ fontFamily: dm, fontWeight: 700, fontSize: 40, letterSpacing: 18, color: C.charcoal, marginTop: 8 }}>RACCOONS</div>
        <div style={{ marginTop: 28 }}><Overline>FE Civil Exam Prep</Overline></div>
      </div>
    </Bg>
  );
}

/* ── Scene 2: The problem (cost) ── */
function SceneProblem() {
  const frame = useCurrentFrame(); const { fps } = useVideoConfig();
  const head = enter(frame, fps, 0);
  const op = exitFade(frame, S2);
  const chips = [
    { label: 'PPI2Pass', price: '$1,800' },
    { label: 'School of PE', price: '$990' },
    { label: 'PrepFE', price: '$110' },
  ];
  const freeIn = enter(frame, fps, 105, 14);
  return (
    <Bg>
      <div style={{ opacity: op, textAlign: 'center', width: 1400 }}>
        <div style={{ opacity: head.opacity, transform: `translateY(${head.y}px)` }}>
          <span style={{ fontFamily: dm, fontWeight: 700, fontSize: 64, color: C.charcoal, letterSpacing: -2 }}>
            FE prep shouldn't cost a paycheck.
          </span>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center', gap: 28, marginTop: 56 }}>
          {chips.map((c, i) => {
            const ce = enter(frame, fps, 26 + i * 14);
            return (
              <div key={c.label} style={{
                opacity: ce.opacity, transform: `translateY(${ce.y}px)`,
                background: 'white', borderRadius: 16, padding: '24px 36px',
                boxShadow: '0 4px 16px rgba(44,44,44,0.08)', minWidth: 240,
              }}>
                <div style={{ fontFamily: inter, fontSize: 24, color: C.gray }}>{c.label}</div>
                <div style={{ fontFamily: mono, fontWeight: 700, fontSize: 52, color: C.charcoal, textDecoration: 'line-through', textDecorationColor: C.ember }}>{c.price}</div>
              </div>
            );
          })}
        </div>
        <div style={{ marginTop: 48, opacity: freeIn.opacity, transform: `scale(${interpolate(freeIn.s, [0, 1], [0.8, 1])})` }}>
          <span style={{ fontFamily: dm, fontWeight: 700, fontSize: 84, color: C.ember, letterSpacing: -3 }}>Ours is free.</span>
          <div style={{ fontFamily: inter, fontSize: 30, color: C.gray, marginTop: 14 }}>The whole platform — no trial, no card.</div>
        </div>
      </div>
    </Bg>
  );
}

/* ── Scene 3: The solution (stats) ── */
function SceneSolution() {
  const frame = useCurrentFrame(); const { fps } = useVideoConfig();
  const head = enter(frame, fps, 0);
  const op = exitFade(frame, S3);
  const count = Math.round(interpolate(frame, [20, 70], [0, 1126], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }));
  const features = ['Spaced repetition', 'Custom diagrams', 'Gamified progress', 'Free diagnostic'];
  return (
    <Bg>
      <div style={{ opacity: op, textAlign: 'center', width: 1500 }}>
        <div style={{ opacity: head.opacity, transform: `translateY(${head.y}px)` }}>
          <Overline color={C.forest}>Everything you need to pass</Overline>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center', gap: 80, marginTop: 40 }}>
          <Stat value={count.toLocaleString()} label="practice problems" />
          <Stat value="15" label="chapters · full FE Civil" />
        </div>
        <div style={{ display: 'flex', justifyContent: 'center', flexWrap: 'wrap', gap: 20, marginTop: 56, maxWidth: 1100, marginLeft: 'auto', marginRight: 'auto' }}>
          {features.map((f, i) => {
            const fe = enter(frame, fps, 80 + i * 12);
            return (
              <span key={f} style={{
                opacity: fe.opacity, transform: `translateY(${fe.y}px)`,
                fontFamily: dm, fontWeight: 600, fontSize: 30, color: C.charcoal,
                background: C.emberBg, borderRadius: 999, padding: '14px 32px',
              }}>{f}</span>
            );
          })}
        </div>
      </div>
    </Bg>
  );
}
function Stat({ value, label }) {
  return (
    <div>
      <div style={{ fontFamily: mono, fontWeight: 700, fontSize: 130, color: C.ember, lineHeight: 1, letterSpacing: -4 }}>{value}</div>
      <div style={{ fontFamily: inter, fontSize: 30, color: C.gray, marginTop: 8 }}>{label}</div>
    </div>
  );
}

/* ── Scene 4: How it works ── */
function SceneHow() {
  const frame = useCurrentFrame(); const { fps } = useVideoConfig();
  const head = enter(frame, fps, 0);
  const op = exitFade(frame, S4);
  const steps = ['Take the diagnostic', 'Learn the lessons', 'Drill the problems', 'Sit the 110-Q exam sim'];
  return (
    <Bg>
      <div style={{ opacity: op, textAlign: 'center', width: 1500 }}>
        <div style={{ opacity: head.opacity, transform: `translateY(${head.y}px)`, marginBottom: 56 }}>
          <span style={{ fontFamily: dm, fontWeight: 700, fontSize: 64, color: C.charcoal, letterSpacing: -2 }}>A clear path to exam day</span>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 0 }}>
          {steps.map((s, i) => {
            const se = enter(frame, fps, 20 + i * 22);
            return (
              <React.Fragment key={s}>
                <div style={{ opacity: se.opacity, transform: `translateY(${se.y}px)`, display: 'flex', flexDirection: 'column', alignItems: 'center', width: 300 }}>
                  <div style={{
                    width: 84, height: 84, borderRadius: 999, background: i === 3 ? C.ember : 'white',
                    color: i === 3 ? 'white' : C.ember, border: `3px solid ${C.ember}`,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontFamily: mono, fontWeight: 700, fontSize: 40, boxShadow: '0 4px 16px rgba(44,44,44,0.08)',
                  }}>{i + 1}</div>
                  <div style={{ fontFamily: dm, fontWeight: 600, fontSize: 28, color: C.charcoal, marginTop: 20, maxWidth: 240 }}>{s}</div>
                </div>
                {i < steps.length - 1 && (
                  <div style={{ width: 60, height: 3, background: C.creamDark, opacity: enter(frame, fps, 31 + i * 22).opacity }} />
                )}
              </React.Fragment>
            );
          })}
        </div>
      </div>
    </Bg>
  );
}

/* ── Scene 5: CTA ── */
function SceneCTA() {
  const frame = useCurrentFrame(); const { fps } = useVideoConfig();
  const e = enter(frame, fps, 0, 14);
  const url = enter(frame, fps, 30);
  return (
    <Bg>
      <div style={{ textAlign: 'center', opacity: e.opacity, transform: `scale(${interpolate(e.s, [0, 1], [0.9, 1])})` }}>
        <Overline>The only thing that costs money</Overline>
        <div style={{ fontFamily: dm, fontWeight: 700, fontSize: 132, color: C.charcoal, letterSpacing: -5, marginTop: 16, lineHeight: 1 }}>
          $29 <span style={{ color: C.ember }}>students</span>
        </div>
        <div style={{ fontFamily: inter, fontSize: 32, color: C.gray, marginTop: 10 }}>$49 standard · one-time · no subscription</div>
        <div style={{ fontFamily: inter, fontSize: 28, color: C.charcoal, marginTop: 18, maxWidth: 900, marginLeft: 'auto', marginRight: 'auto', lineHeight: 1.5 }}>
          …for the full timed exam simulation. Everything else stays free.
        </div>
        <div style={{ marginTop: 48, opacity: url.opacity, transform: `translateY(${url.y}px)` }}>
          <span style={{ fontFamily: dm, fontWeight: 700, fontSize: 56, color: C.ember }}>fe4raccoons.com</span>
        </div>
      </div>
    </Bg>
  );
}

export function Explainer() {
  return (
    <>
      {/* Soft background music bed. Swap explainer-music.mp3 for any licensed
          track to change it — no other code change needed. */}
      <Audio src={staticFile('explainer-music.mp3')} volume={0.55} />
      <Series>
        <Series.Sequence durationInFrames={S1}><SceneBrand /></Series.Sequence>
        <Series.Sequence durationInFrames={S2}><SceneProblem /></Series.Sequence>
        <Series.Sequence durationInFrames={S3}><SceneSolution /></Series.Sequence>
        <Series.Sequence durationInFrames={S4}><SceneHow /></Series.Sequence>
        <Series.Sequence durationInFrames={S5}><SceneCTA /></Series.Sequence>
      </Series>
    </>
  );
}

// Draws the pass card onto a canvas.
//
// In the browser rather than on the server on purpose. The card is type and
// rectangles, so a headless browser on the box would buy nothing and cost a
// 300MB dependency and the memory to run it. Every number comes from
// src/data/passCard.js, which the Flutter painter mirrors.
//
// Pure apart from the canvas it is handed: no DOM, no fetch, no state. That is
// what lets it be tested and what lets the same call render the full card and
// the thumbnail on the result page.

import { CARD, CARD_INK, BOOKS, BOOK_COVERS } from '../../data/passCard.js';
import peekUrl from '../../assets/brand/raccoon-peek.png';

/// Canvas has no letter-spacing in Safari, so it is done by hand. Without this
/// the mono labels set solid and the card stops looking like a drawing sheet.
function tracked(ctx, text, x, y, spacing) {
  let cursor = x;
  for (const ch of text) {
    ctx.fillText(ch, cursor, y);
    cursor += ctx.measureText(ch).width + spacing;
  }
}

function roundedPath(ctx, x, y, w, h, r) {
  ctx.beginPath();
  if (ctx.roundRect) {
    ctx.roundRect(x, y, w, h, r);
  } else {
    // Safari before 16 and every headless renderer older than it.
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + w, y, x + w, y + h, r);
    ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r);
    ctx.arcTo(x, y, x + w, y, r);
  }
}

function roundedBar(ctx, x, y, w, h, r) {
  roundedPath(ctx, x, y, w, h, r);
  ctx.fill();
}

/// The warm corner light (CARD.glow), drawn over the paper.
function glow(ctx, w, h) {
  const g = CARD.glow;
  ctx.save();
  ctx.translate(g.cx * w, g.cy * h);
  ctx.scale(1, g.ry * h / (g.rx * w));
  const r = g.rx * w;
  const grad = ctx.createRadialGradient(0, 0, 0, 0, 0, r);
  grad.addColorStop(0, g.ink);
  grad.addColorStop(1, 'rgba(232,104,58,0)');
  ctx.fillStyle = grad;
  ctx.fillRect(-r, -r, 2 * r, 2 * r);
  ctx.restore();
}

/// The fifteen chapters as a stack of books, chapter 15 on top. Each book is
/// drawn in its own tilted frame; lower books are drawn later so they sit over
/// the edge of the one above, as a real stack would. `peek` is the raccoon
/// image, seated on the top book; without it the stack is drawn alone.
function bookStack(ctx, chapters, peek) {
  const S = CARD.stack;
  const H = S.bookHeight;
  const step = H * (1 - S.overlap);
  for (let k = 0; k < chapters.length; k++) {
    const i = chapters.length - 1 - k; // chapter index, top book first
    const b = BOOKS[i];
    const c = BOOK_COVERS[b.cover];
    const w = S.width * b.w / 100;
    const x = S.x + b.dx;
    const y = S.top + k * step;
    ctx.save();
    ctx.translate(x + w / 2, y + H / 2);
    ctx.rotate(b.tilt * Math.PI / 180);
    ctx.translate(-w / 2, -H / 2);

    // Cover, with a soft shadow under it.
    ctx.shadowColor = 'rgba(44,44,44,0.16)';
    ctx.shadowBlur = 10;
    ctx.shadowOffsetY = 3;
    ctx.fillStyle = c.fill;
    roundedBar(ctx, 0, 0, w, H, S.radius);
    ctx.shadowColor = 'transparent';

    // Rounded spine: light along the top edge, dark along the bottom.
    const shade = ctx.createLinearGradient(0, 0, 0, H);
    shade.addColorStop(0, 'rgba(255,255,255,0.16)');
    shade.addColorStop(0.3, 'rgba(255,255,255,0)');
    shade.addColorStop(0.7, 'rgba(0,0,0,0)');
    shade.addColorStop(1, 'rgba(0,0,0,0.16)');
    ctx.fillStyle = shade;
    roundedBar(ctx, 0, 0, w, H, S.radius);

    ctx.fillStyle = c.band;
    for (const fromRight of S.bandsFromRight) {
      roundedBar(ctx, w - fromRight, H * S.bandInset, S.bandWidth, H * (1 - 2 * S.bandInset), 1.5);
    }

    ctx.textBaseline = 'middle';
    ctx.fillStyle = c.text;
    ctx.globalAlpha = 0.6;
    ctx.font = '700 10.5px "JetBrains Mono", monospace';
    ctx.fillText(String(i + 1).padStart(2, '0'), S.padLeft, H / 2 + 1);
    ctx.globalAlpha = 1;
    ctx.font = '700 12.5px "DM Sans", sans-serif';
    tracked(ctx, chapters[i].toUpperCase(), S.padLeft + S.numberGap, H / 2 + 1, 1.25);

    if (k === 0 && peek && peek.width) {
      const pw = S.peek.width;
      const ph = pw * peek.height / peek.width;
      ctx.drawImage(peek, w * S.peek.along - pw / 2, -ph * S.peek.seat, pw, ph);
    }
    ctx.restore();
  }
  ctx.textBaseline = 'alphabetic';
}

/// The raccoon, loaded once. Resolves to null if it cannot load: the card is
/// still theirs without it.
let peekLoad = null;
export function loadPeek() {
  if (typeof Image === 'undefined') return Promise.resolve(null);
  peekLoad = peekLoad || new Promise((resolve) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = () => resolve(null);
    img.src = peekUrl;
  });
  return peekLoad;
}

function engineeringPaper(ctx, w, h) {
  ctx.fillStyle = CARD.paper;
  ctx.fillRect(0, 0, w, h);
  for (const grid of [CARD.gridFine, CARD.gridBold]) {
    ctx.strokeStyle = grid.ink;
    ctx.lineWidth = 1;
    // The half pixel keeps a 1px line on a pixel instead of across two, which
    // is the difference between a crisp grid and a grey haze.
    for (let x = 0; x <= w; x += grid.step) {
      ctx.beginPath();
      ctx.moveTo(x + 0.5, 0);
      ctx.lineTo(x + 0.5, h);
      ctx.stroke();
    }
    for (let y = 0; y <= h; y += grid.step) {
      ctx.beginPath();
      ctx.moveTo(0, y + 0.5);
      ctx.lineTo(w, y + 0.5);
      ctx.stroke();
    }
  }
}

/// Draw the card at whatever size the canvas already is.
///
/// The canvas keeps its own pixel dimensions; this scales the design to fit, so
/// the same function paints the 2400px export and a 300px thumbnail with no
/// second set of numbers.
export function drawPassCard(canvas, data, { peek = null } = {}) {
  const ctx = canvas.getContext('2d');
  if (!ctx || !data) return;

  const { width: W, height: H, pad: PAD } = CARD;
  const scale = canvas.width / W;

  ctx.save();
  ctx.scale(scale, scale);
  ctx.clearRect(0, 0, W, H);
  engineeringPaper(ctx, W, H);
  glow(ctx, W, H);

  ctx.textBaseline = 'alphabetic';
  ctx.textAlign = 'left';

  // ── The claim ──
  ctx.fillStyle = CARD_INK.ember;
  ctx.font = `700 ${CARD.eyebrow.size}px "JetBrains Mono", monospace`;
  tracked(ctx, 'FUNDAMENTALS OF ENGINEERING', PAD, PAD + CARD.eyebrow.y, CARD.eyebrow.tracking);

  ctx.fillStyle = CARD_INK.ink;
  ctx.font = `800 ${CARD.headline.size}px "DM Sans", sans-serif`;
  ctx.fillText('FE Civil', PAD + CARD.headline.nudge, PAD + CARD.headline.lineOne);
  ctx.fillText('passed.', PAD + CARD.headline.nudge, PAD + CARD.headline.lineTwo);

  // A card with no name is a bug upstream, not something to paper over here:
  // the caller is supposed to have asked. Drawing nothing is louder than
  // drawing a placeholder, and far better than drawing an email address.
  if (data.name) {
    ctx.font = `700 ${CARD.name.size}px "DM Sans", sans-serif`;
    ctx.fillText(data.name, PAD + CARD.name.nudge, PAD + CARD.name.y);
  }

  ctx.fillStyle = CARD_INK.mute;
  ctx.font = `400 ${CARD.footnote.size}px "Inter", sans-serif`;
  ctx.fillText(CARD.footnote.text, PAD - 1, PAD + CARD.footnote.y);

  // ── What the exam covers ──
  bookStack(ctx, data.chapters, peek);
  ctx.fillStyle = CARD_INK.soft;
  ctx.font = '600 12px "JetBrains Mono", monospace';
  tracked(ctx, `ALL FIFTEEN CHAPTERS. ${data.totalQuestions} QUESTIONS.`,
    CARD.stack.caption.x, CARD.stack.caption.y, 2);

  // ── The title block ──
  const TY = H - CARD.titleBlock.fromBottom;
  ctx.strokeStyle = CARD_INK.ink;
  ctx.lineWidth = CARD.titleBlock.ruleWidth;
  ctx.beginPath();
  ctx.moveTo(PAD, TY);
  ctx.lineTo(CARD.titleBlock.ruleEnd, TY);
  ctx.stroke();

  let x = PAD;
  for (const [label, value] of [
    ['DISCIPLINE', data.discipline],
    ['RESULT', data.result],
    ['DATE', data.when],
  ]) {
    ctx.fillStyle = CARD_INK.mute;
    ctx.font = '500 11px "JetBrains Mono", monospace';
    tracked(ctx, label, x, TY + CARD.titleBlock.labelY, 1.8);
    ctx.fillStyle = CARD_INK.ink;
    ctx.font = '600 17px "DM Sans", sans-serif';
    ctx.fillText(value, x, TY + CARD.titleBlock.valueY);
    x += CARD.titleBlock.cellPitch;
  }

  ctx.textAlign = 'right';
  ctx.fillStyle = CARD_INK.ink;
  ctx.font = '700 23px "DM Sans", sans-serif';
  ctx.fillText('FE4RACCOONS', W - PAD, TY + CARD.titleBlock.valueY);

  ctx.restore();
}

/// A canvas at export size, drawn and ready to hand to the browser.
///
/// Waits on the brand faces first. Canvas takes whatever font is loaded at the
/// moment fillText runs, with no callback and no error: draw too early and the
/// card silently ships in Helvetica.
export async function renderPassCard(data, { scale = CARD.exportScale } = {}) {
  if (document.fonts?.ready) {
    try {
      await document.fonts.ready;
    } catch {
      // A font that never resolves must not cost them the card.
    }
  }
  const peek = await loadPeek();
  const canvas = document.createElement('canvas');
  canvas.width = CARD.width * scale;
  canvas.height = CARD.height * scale;
  drawPassCard(canvas, data, { peek });
  return canvas;
}

/// The PNG itself.
export function passCardBlob(canvas) {
  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => (blob ? resolve(blob) : reject(new Error('The image could not be created.'))),
      'image/png',
    );
  });
}

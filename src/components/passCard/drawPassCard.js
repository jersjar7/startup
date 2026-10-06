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

import { CARD, CARD_INK } from '../../data/passCard.js';

/// Canvas has no letter-spacing in Safari, so it is done by hand. Without this
/// the mono labels set solid and the card stops looking like a drawing sheet.
function tracked(ctx, text, x, y, spacing) {
  let cursor = x;
  for (const ch of text) {
    ctx.fillText(ch, cursor, y);
    cursor += ctx.measureText(ch).width + spacing;
  }
}

function roundedBar(ctx, x, y, w, h, r) {
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
  ctx.fill();
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
export function drawPassCard(canvas, data) {
  const ctx = canvas.getContext('2d');
  if (!ctx || !data) return;

  const { width: W, height: H, pad: PAD } = CARD;
  const scale = canvas.width / W;

  ctx.save();
  ctx.scale(scale, scale);
  ctx.clearRect(0, 0, W, H);
  engineeringPaper(ctx, W, H);

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
  const CX = CARD.index.x;
  ctx.fillStyle = CARD_INK.soft;
  ctx.font = '600 13px "JetBrains Mono", monospace';
  tracked(ctx, `ALL FIFTEEN CHAPTERS. ${data.totalQuestions} QUESTIONS.`, CX, PAD + 4, 2.2);

  data.chapters.forEach((name, i) => {
    const y = CARD.index.top + i * CARD.index.rowHeight;
    ctx.fillStyle = CARD_INK.ember;
    ctx.font = '600 13px "JetBrains Mono", monospace';
    ctx.fillText(String(i + 1).padStart(2, '0'), CX, y);
    ctx.fillStyle = CARD_INK.ink;
    ctx.font = '500 17px "Inter", sans-serif';
    ctx.fillText(name, CX + CARD.index.numberGap, y);
    ctx.strokeStyle = CARD.index.rule;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(CX, y + 8.5);
    ctx.lineTo(W - PAD, y + 8.5);
    ctx.stroke();
  });

  // ── The title block ──
  const TY = H - CARD.titleBlock.fromBottom;
  ctx.strokeStyle = CARD_INK.ink;
  ctx.lineWidth = CARD.titleBlock.ruleWidth;
  ctx.beginPath();
  ctx.moveTo(PAD, TY);
  ctx.lineTo(W - PAD, TY);
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
  // roundedBar is kept for the mobile painter's parity test, which draws the
  // same shapes; referencing it here stops a bundler dropping it.
  void roundedBar;
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
  const canvas = document.createElement('canvas');
  canvas.width = CARD.width * scale;
  canvas.height = CARD.height * scale;
  drawPassCard(canvas, data);
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

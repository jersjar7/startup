import React from 'react';
import './chapterCoin.css';

// The app's chapter coin: the chapter's own mark on a raised disc, in the
// website's soft accent colours (peach, butter, cream) rather than the app's.
// The marks are exported from the app (mobile/tool/export_chapter_marks_test.dart).
const MARKS = import.meta.glob('../../assets/brand/marks/*.png', { eager: true, import: 'default' });

export function markFor(chapterId) {
  return MARKS[`../../assets/brand/marks/${chapterId}.png`];
}

export function ChapterCoin({ chapterId, accent = 'forest', size = 34, className = '' }) {
  const src = markFor(chapterId);
  return (
    <span
      className={`coin coin--${accent} ${className}`}
      style={{ '--coin-d': `${size}px` }}
      aria-hidden="true"
    >
      <span className="coin-rim" />
      <span className="coin-face">
        {src && <img src={src} alt="" width="96" height="96" draggable="false" />}
      </span>
    </span>
  );
}

import React from 'react';
import { CheckCircle, Circle } from '@phosphor-icons/react';
import { CHAPTERS } from '../data/chapters';

// The finite, visible "X / 15 chapters" readiness map. Sampled chapters show
// their familiarity bar; unsampled ones read "not measured yet". Rendered in
// the system's chapter order so the map mirrors the order the user meets them.
export function ChapterMap({ order, familiarity = {}, sampled = [], currentChapterId = null, totalChapters = 15 }) {
  const sampledSet = new Set(sampled);
  const sampledCount = sampled.length;
  const pct = totalChapters > 0 ? Math.round((sampledCount / totalChapters) * 100) : 0;
  const nameOf = (id) => (CHAPTERS.find((c) => c.id === id)?.name || id);

  return (
    <div className="qs-map">
      <div className="qs-map-head">
        <span className="qs-map-title">Your readiness map</span>
        <span className="qs-map-count">{sampledCount} / {totalChapters} chapters</span>
      </div>

      <div className="qs-map-progress">
        <div className="qs-map-progress-fill" style={{ width: `${pct}%` }} />
      </div>

      <ul className="qs-map-list">
        {order.map((id) => {
          const isSampled = sampledSet.has(id);
          const val = familiarity[id] || 0;
          const isCurrent = id === currentChapterId;
          return (
            <li key={id} className={`qs-map-row${isCurrent ? ' qs-map-row--current' : ''}`}>
              <span className="qs-map-icon">
                {isSampled
                  ? <CheckCircle size={16} weight="fill" style={{ color: 'var(--forest)' }} />
                  : <Circle size={16} weight="regular" style={{ color: 'var(--gray-300)' }} />}
              </span>
              <span className="qs-map-name">{nameOf(id)}</span>
              {isSampled ? (
                <span className="qs-map-bar-wrap">
                  <span className="qs-map-bar-track">
                    <span className="qs-map-bar-fill" style={{ width: `${val}%` }} />
                  </span>
                  <span className="qs-map-val">{val}%</span>
                </span>
              ) : (
                <span className="qs-map-unmeasured">not measured yet</span>
              )}
            </li>
          );
        })}
      </ul>
    </div>
  );
}

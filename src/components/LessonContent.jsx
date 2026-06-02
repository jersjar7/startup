import React from 'react';
import katex from 'katex';
import { Lightbulb, WarningCircle, Exam, Calculator } from '@phosphor-icons/react';
import { MathText } from './MathText';
import { DIAGRAM_REGISTRY } from './diagrams';

const CALLOUT_ICONS = {
  tip: Lightbulb,
  warning: WarningCircle,
  exam: Exam,
  calculator: Calculator,
};

export function LessonContent({ blocks }) {
  if (!blocks || !Array.isArray(blocks)) return null;

  return (
    <div className="lc-blocks">
      {blocks.map((block, i) => {
        switch (block.type) {
          case 'text':
            return (
              <p key={i} className="lc-text">
                <MathText text={block.body} />
              </p>
            );

          case 'heading':
            return (
              <h4 key={i} className="lc-heading">
                <MathText text={block.body} />
              </h4>
            );

          case 'formula': {
            let html;
            try {
              html = katex.renderToString(block.latex, {
                displayMode: true,
                throwOnError: false,
                strict: false,
              });
            } catch {
              html = block.latex;
            }
            return (
              <div key={i} className="lc-formula">
                <div dangerouslySetInnerHTML={{ __html: html }} />
                {block.label && (
                  <span className="lc-formula-label">{block.label}</span>
                )}
              </div>
            );
          }

          case 'callout': {
            const variant = block.variant || 'tip';
            const Icon = CALLOUT_ICONS[variant];
            return (
              <div key={i} className={`lc-callout lc-callout--${variant}`}>
                {Icon && <Icon size={16} weight="fill" className="lc-callout-icon" />}
                <p><MathText text={block.body} /></p>
              </div>
            );
          }

          case 'diagram': {
            const Comp = DIAGRAM_REGISTRY[block.component];
            if (!Comp) return null;
            return (
              <div key={i} className="lc-diagram">
                <Comp {...(block.props || {})} />
              </div>
            );
          }

          default:
            return null;
        }
      })}
    </div>
  );
}

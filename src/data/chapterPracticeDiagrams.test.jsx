import React from 'react';
import { describe, it, expect, beforeAll } from 'vitest';
import { render } from '@testing-library/react';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import { getChapterPracticeProblems } from './chapter-practice/index';

const CHAPTER_IDS = [
  'mathematics', 'statistics', 'ethics', 'economics', 'statics', 'dynamics',
  'mechanics-materials', 'materials', 'fluid-mechanics', 'surveying',
  'water-resources', 'structural', 'geotechnical', 'transportation', 'construction',
];

// jsdom doesn't implement SVG measurement; stub so layout-measuring diagrams render.
beforeAll(() => {
  if (!SVGElement.prototype.getBBox) {
    SVGElement.prototype.getBBox = () => ({ x: 0, y: 0, width: 100, height: 20 });
  }
  if (!SVGElement.prototype.getComputedTextLength) {
    SVGElement.prototype.getComputedTextLength = () => 50;
  }
});

const withDiagram = [];
for (const ch of CHAPTER_IDS) {
  for (const p of getChapterPracticeProblems(ch)) {
    if (p.diagram) withDiagram.push(p);
  }
}

describe('chapter-practice diagrams', () => {
  it('has a meaningful number of wired diagrams', () => {
    expect(withDiagram.length).toBeGreaterThanOrEqual(20);
  });

  it.each(withDiagram.map((p) => [p.id, p.diagram.component, p]))(
    'renders %s via %s without throwing',
    (_id, component, p) => {
      const Comp = DIAGRAM_REGISTRY[component];
      expect(Comp, `component '${component}' missing from registry`).toBeTruthy();
      const { container } = render(<Comp {...(p.diagram.props || {})} />);
      expect(container.querySelector('svg')).toBeTruthy();
    },
  );
});

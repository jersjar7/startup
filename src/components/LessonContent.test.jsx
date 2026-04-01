import React from 'react';
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { LessonContent } from './LessonContent';

// Mock the diagram registry so we don't need actual SVG components
vi.mock('./diagrams', () => ({
  DIAGRAM_REGISTRY: {
    TestDiagram: (props) => <div data-testid="test-diagram" {...props} />,
  },
}));

describe('LessonContent', () => {
  it('renders null for null blocks', () => {
    const { container } = render(<LessonContent blocks={null} />);
    expect(container.firstChild).toBeNull();
  });

  it('renders null for non-array blocks', () => {
    const { container } = render(<LessonContent blocks="not an array" />);
    expect(container.firstChild).toBeNull();
  });

  it('renders text blocks', () => {
    const blocks = [{ type: 'text', body: 'Hello world' }];
    render(<LessonContent blocks={blocks} />);
    expect(screen.getByText('Hello world')).toBeInTheDocument();
  });

  it('renders heading blocks', () => {
    const blocks = [{ type: 'heading', body: 'Section Title' }];
    render(<LessonContent blocks={blocks} />);
    const heading = screen.getByText('Section Title');
    expect(heading.tagName).toBe('H4');
  });

  it('renders formula blocks with KaTeX', () => {
    const blocks = [{ type: 'formula', latex: 'x^2', label: 'Equation 1' }];
    const { container } = render(<LessonContent blocks={blocks} />);
    const katexElements = container.querySelectorAll('.katex');
    expect(katexElements.length).toBe(1);
    expect(screen.getByText('Equation 1')).toBeInTheDocument();
  });

  it('renders formula blocks without label', () => {
    const blocks = [{ type: 'formula', latex: 'y = mx + b' }];
    const { container } = render(<LessonContent blocks={blocks} />);
    const katexElements = container.querySelectorAll('.katex');
    expect(katexElements.length).toBe(1);
  });

  it('renders callout blocks with default tip variant', () => {
    const blocks = [{ type: 'callout', body: 'Remember this!' }];
    const { container } = render(<LessonContent blocks={blocks} />);
    expect(container.querySelector('.lc-callout--tip')).toBeInTheDocument();
    expect(screen.getByText('Remember this!')).toBeInTheDocument();
  });

  it('renders callout blocks with warning variant', () => {
    const blocks = [{ type: 'callout', body: 'Watch out!', variant: 'warning' }];
    const { container } = render(<LessonContent blocks={blocks} />);
    expect(container.querySelector('.lc-callout--warning')).toBeInTheDocument();
  });

  it('renders diagram blocks from registry', () => {
    const blocks = [{ type: 'diagram', component: 'TestDiagram', props: { width: 200 } }];
    render(<LessonContent blocks={blocks} />);
    expect(screen.getByTestId('test-diagram')).toBeInTheDocument();
  });

  it('skips diagram blocks with unknown component', () => {
    const blocks = [{ type: 'diagram', component: 'NonExistent' }];
    const { container } = render(<LessonContent blocks={blocks} />);
    expect(container.querySelector('.lc-diagram')).toBeNull();
  });

  it('skips unknown block types', () => {
    const blocks = [{ type: 'unknown', body: 'Should not render' }];
    const { container } = render(<LessonContent blocks={blocks} />);
    expect(container.querySelector('.lc-blocks').children).toHaveLength(0);
  });

  it('renders multiple mixed block types', () => {
    const blocks = [
      { type: 'heading', body: 'Title' },
      { type: 'text', body: 'Paragraph one' },
      { type: 'formula', latex: 'E = mc^2' },
      { type: 'callout', body: 'Note', variant: 'exam' },
    ];
    const { container } = render(<LessonContent blocks={blocks} />);
    expect(container.querySelector('.lc-blocks').children.length).toBe(4);
  });
});

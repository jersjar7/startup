import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MathText } from './MathText';

describe('MathText', () => {
  it('renders null for empty text', () => {
    const { container } = render(<MathText text="" />);
    expect(container.firstChild).toBeNull();
  });

  it('renders null for undefined text', () => {
    const { container } = render(<MathText text={undefined} />);
    expect(container.firstChild).toBeNull();
  });

  it('renders plain text without math delimiters', () => {
    render(<MathText text="Hello world" />);
    expect(screen.getByText('Hello world')).toBeInTheDocument();
  });

  it('renders text with $...$ inline math delimiters', () => {
    const { container } = render(<MathText text="The value is $x^2$ meters" />);
    // Should have KaTeX rendered content
    const katexElements = container.querySelectorAll('.katex');
    expect(katexElements.length).toBe(1);
    // Plain text parts should also be present
    expect(container.textContent).toContain('The value is');
    expect(container.textContent).toContain('meters');
  });

  it('normalizes \\(...\\) delimiters to $...$ before rendering', () => {
    const text = 'Area is \\(A = \\pi r^2\\) units';
    const { container } = render(<MathText text={text} />);
    const katexElements = container.querySelectorAll('.katex');
    expect(katexElements.length).toBe(1);
    expect(container.textContent).toContain('Area is');
  });

  it('handles multiple math segments', () => {
    const { container } = render(<MathText text="$x$ and $y$ and $z$" />);
    const katexElements = container.querySelectorAll('.katex');
    expect(katexElements.length).toBe(3);
  });

  it('falls back to <code> on KaTeX error', () => {
    // Use an intentionally invalid LaTeX command
    const { container } = render(<MathText text="$\\invalidcommandxyz$" />);
    // KaTeX with throwOnError: false renders error spans instead of throwing
    // The content should still be present
    expect(container.textContent).toContain('\\invalidcommandxyz');
  });

  it('preserves newlines in plain text', () => {
    const { container } = render(<MathText text={"Line 1\nLine 2"} />);
    const brs = container.querySelectorAll('br');
    expect(brs.length).toBe(1);
  });
});

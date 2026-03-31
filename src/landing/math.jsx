import React from 'react';
import katex from 'katex';
import 'katex/dist/katex.min.css';

/**
 * Inline or block KaTeX math renderer.
 * Usage: <Math tex="M_{max} = \frac{wL^2}{8}" /> for inline
 *        <Math tex="M_{max} = \frac{wL^2}{8}" block /> for display/block
 */
export function Math({ tex, block = false }) {
  const html = React.useMemo(() => {
    try {
      return katex.renderToString(tex, {
        displayMode: block,
        throwOnError: false,
        strict: false,
      });
    } catch {
      return tex;
    }
  }, [tex, block]);

  if (block) {
    return <div className="math-block" dangerouslySetInnerHTML={{ __html: html }} />;
  }
  return <span className="math-inline" dangerouslySetInnerHTML={{ __html: html }} />;
}

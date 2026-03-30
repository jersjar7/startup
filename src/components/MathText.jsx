import katex from 'katex';

export function MathText({ text }) {
  if (!text) return null;

  // Split on $...$ delimiters — odd indices are math, even are plain text
  const parts = text.split(/\$([^$]+)\$/g);

  return (
    <span>
      {parts.map((part, i) => {
        if (i % 2 === 1) {
          // Math segment — render with KaTeX
          try {
            const html = katex.renderToString(part, { throwOnError: false });
            return <span key={i} dangerouslySetInnerHTML={{ __html: html }} />;
          } catch {
            return <code key={i}>{part}</code>;
          }
        }
        // Plain text — preserve newlines
        return part.split('\n').map((line, j) => (
          <span key={`${i}-${j}`}>
            {j > 0 && <br />}
            {line}
          </span>
        ));
      })}
    </span>
  );
}

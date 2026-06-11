import React from 'react';
import { View, Text as RNText, type TextProps, type TextStyle, type StyleProp } from 'react-native';
import { texToSvg } from 'react-native-mathjax-svg';
import { SvgXml } from 'react-native-svg';
import { Text } from '@/presentation/ui/Text';
import type { TextVariant } from '@/core/theme/typography';
import { textVariants } from '@/core/theme/typography';
import { useTheme } from '@/core/theme/useTheme';
import { latexToText } from './latexToText';

interface Props extends TextProps {
  children: string;
  variant?: TextVariant;
  color?: string;
}

// Drop-in <Text> that TYPESETS inline `$...$` LaTeX with MathJax (real
// fractions, radicals, sub/superscripts — the same visual standard as the
// website's KaTeX). Pure-prose strings keep the fast Text path; mixed strings
// flow as a wrapping row of words and typeset runs. If MathJax chokes on a
// string, the Unicode converter is the fallback — never a crash.
export function MathText({ children, variant = 'body', color, style, ...rest }: Props) {
  const theme = useTheme();
  const flat = flattenStyle(style);
  const variantStyle = textVariants[variant] as TextStyle;
  const fontSize = flat?.fontSize ?? variantStyle.fontSize ?? 14;
  const lineHeight = flat?.lineHeight ?? variantStyle.lineHeight ?? Math.round(fontSize * 1.5);
  const ink = color ?? theme.palette.charcoal;

  const segments = children.split(/(\$[^$]+\$)/g).filter((s) => s.length > 0);
  const hasMath = segments.some(isMath);

  if (!hasMath) {
    return (
      <Text variant={variant} color={color} style={style} {...rest}>
        {children}
      </Text>
    );
  }

  // Single pure-formula string → typeset it as one block.
  if (segments.length === 1) {
    return (
      <View style={[{ paddingVertical: 2 }, style as StyleProp<TextStyle>]}>
        <MathRun tex={tex(segments[0])} fontSize={fontSize} color={ink} />
      </View>
    );
  }

  // Mixed prose + math: wrap word-by-word so typeset runs flow with the text.
  const items: { kind: 'word' | 'math'; value: string }[] = [];
  for (const seg of segments) {
    if (isMath(seg)) items.push({ kind: 'math', value: tex(seg) });
    else for (const w of seg.split(/\s+/).filter(Boolean)) items.push({ kind: 'word', value: w });
  }

  return (
    <View style={[{ flexDirection: 'row', flexWrap: 'wrap', alignItems: 'center' }, style as StyleProp<TextStyle>]}>
      {items.map((it, i) =>
        it.kind === 'math' ? (
          <View key={i} style={{ marginRight: 4, marginVertical: 1 }}>
            <MathRun tex={it.value} fontSize={fontSize} color={ink} />
          </View>
        ) : (
          <Text key={i} variant={variant} color={color} style={{ fontSize, lineHeight, marginRight: 4 }}>
            {it.value}
          </Text>
        ),
      )}
    </View>
  );
}

const isMath = (s: string) => s.startsWith('$') && s.endsWith('$');
const tex = (s: string) => s.slice(1, -1).trim();

function flattenStyle(style: Props['style']): TextStyle | undefined {
  if (!style) return undefined;
  if (Array.isArray(style)) return Object.assign({}, ...(style as TextStyle[]));
  return style as TextStyle;
}

// One typeset run, memoized (MathJax conversion isn't free) and guarded — a
// bad TeX string falls back to the Unicode rendering instead of crashing.
const MathRun = React.memo(function MathRun({
  tex: source,
  fontSize,
  color,
}: {
  tex: string;
  fontSize: number;
  color: string;
}) {
  const fallback = (
    <RNText style={{ fontSize, color }}>{latexToText(`$${source}$`).replace(/\s+/g, ' ').trim()}</RNText>
  );
  // texToSvg's scale factor maps ~2 units to one glyph-em, so fontSize/2
  // lands the rendered math at ~fontSize px tall. The lib leaves its
  // width/height in "ex" units, which browsers scale ~7x — force px.
  let xml = '';
  try {
    xml = texToSvg(source, fontSize / 2)
      .replace(/((?:width|height)=")([\d.]+)ex(")/g, '$1$2px$3')
      .replace(/currentColor/g, color);
  } catch {
    return fallback;
  }
  if (!xml) return fallback;
  return <MathErrorBoundary fallback={fallback}>{<SvgXml xml={xml} />}</MathErrorBoundary>;
});

class MathErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback: React.ReactNode },
  { failed: boolean }
> {
  state = { failed: false };
  static getDerivedStateFromError() {
    return { failed: true };
  }
  render() {
    return this.state.failed ? this.props.fallback : this.props.children;
  }
}

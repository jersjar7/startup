// The package's index.d.ts only declares the default component — it also
// exports the raw TeX→SVG converter, which we post-process ourselves.
declare module 'react-native-mathjax-svg' {
  import type { ReactElement } from 'react';
  import type { XmlProps } from 'react-native-svg';

  export type MathJaxProps = Omit<XmlProps, 'xml'> & {
    color?: string;
    fontSize?: number;
    children?: string;
  };

  export default function MathJax(props: MathJaxProps): ReactElement;
  export function texToSvg(tex: string, fontSize?: number): string;
}

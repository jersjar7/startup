import React from 'react';
import { Composition } from 'remotion';
import { Explainer, FPS, DURATION_IN_FRAMES } from './Explainer';

export const RemotionRoot = () => (
  <Composition
    id="Explainer"
    component={Explainer}
    durationInFrames={DURATION_IN_FRAMES}
    fps={FPS}
    width={1920}
    height={1080}
  />
);

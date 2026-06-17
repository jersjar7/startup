import React from 'react';
import { C, Box, Member, Arrow } from './primitives';

// FE topic: Geotechnical — solid stacked soil strata with a spread footing and
// column carried into the soil on driven piles, a groundwater table, a
// settlement load arrow, and a banded borehole core sample beside the block.
// `opacity` cross-fades.

export function GeoScene({ opacity }) {
  const layers = React.useMemo(() => {
    const colors = ['#8a8278', '#6f685d', '#7c7468', '#5a544c', '#675f55'];
    const W = 7.4, D = 2.8, H = 0.5;
    const arr = [];
    let y = -1.55;
    for (let i = 0; i < colors.length; i++) {
      arr.push({ y: y + H / 2, color: colors[i], W, D, H });
      y += H;
    }
    return { arr, topY: y, W, D, H };
  }, []);
  const topSurface = layers.topY;
  const pileBottom = layers.arr[1].y;
  const pileXs = [-0.6, 0.6];
  const pileZs = [-0.5, 0.5];
  return (
    <group position={[0, 0.05, 0]}>
      {layers.arr.map((l, i) => (
        <mesh key={`g${i}`} position={[0, l.y, 0]} castShadow receiveShadow>
          <boxGeometry args={[l.W, l.H, l.D]} />
          <meshStandardMaterial color={l.color} metalness={0.12} roughness={0.9} transparent={opacity < 1} opacity={opacity} flatShading />
        </mesh>
      ))}
      <Box position={[0, layers.arr[2].y + 0.26, 0]} size={[layers.W + 0.04, 0.02, layers.D + 0.04]} color={C.info} opacity={opacity * 0.45} metalness={0.2} roughness={0.2} />
      <Box position={[0, topSurface + 0.16, 0]} size={[1.9, 0.32, 1.7]} color={C.steelLt} opacity={opacity} metalness={0.6} roughness={0.5} />
      <Box position={[0, topSurface + 0.32 + 0.45, 0]} size={[0.55, 0.9, 0.55]} color={C.steel} opacity={opacity} metalness={0.9} roughness={0.34} />
      {pileXs.map((px) =>
        pileZs.map((pz, j) => (
          <Member key={`pile${px}-${j}`} a={[px, topSurface + 0.1, pz]} b={[px, pileBottom, pz]} radius={0.08} color={C.steel} opacity={opacity} />
        )),
      )}
      <Arrow from={[0, topSurface + 2.25, 0]} to={[0, topSurface + 1.42, 0]} opacity={opacity} />
      <group position={[layers.W / 2 + 0.5, 0, layers.D / 2 - 0.4]}>
        {layers.arr.map((l, i) => (
          <mesh key={`core${i}`} position={[0, l.y + 0.9, 0]} castShadow>
            <cylinderGeometry args={[0.12, 0.12, l.H, 18]} />
            <meshStandardMaterial color={l.color} metalness={0.15} roughness={0.85} transparent={opacity < 1} opacity={opacity} />
          </mesh>
        ))}
      </group>
    </group>
  );
}

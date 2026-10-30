import React from 'react';
import { Label } from '../../primitives';

/**
 * Section through a canal and a parallel river that both cut through a clay
 * layer into the same sand aquifer, which rests on clay. Not to scale (the
 * distance is far longer than the depths).
 * Shows: water surface elevations in the canal and river, the distance
 * between them, the aquifer thickness.
 * Does NOT show: the gradient or the seepage rate.
 */
export function CtWaterResourcesACanalSeepage({ elCanal = 512.4, elRiver = 510.0, dist = 1200, b = 30 }) {
  const x0 = 14;
  const x1 = 396;
  const groundY = 46;
  const aqTop = 92;
  const aqBot = 170;
  const clayBot = 190;
  const canal = [30, 100];
  const river = [300, 380];
  const side = 12; // horizontal run of each channel side
  const canalWs = 62;
  const riverWs = 72;
  const mid = (c) => (c[0] + c[1]) / 2;
  const ground = `${x0},${groundY} ${canal[0]},${groundY} ${canal[0] + side},${aqTop} ${canal[1] - side},${aqTop} ${canal[1]},${groundY} ${river[0]},${groundY} ${river[0] + side},${aqTop} ${river[1] - side},${aqTop} ${river[1]},${groundY} ${x1},${groundY}`;
  const atY = (c, y) => [c[0] + ((y - groundY) * side) / (aqTop - groundY), c[1] - ((y - groundY) * side) / (aqTop - groundY)];
  const cw = atY(canal, canalWs);
  const rw = atY(river, riverWs);
  const tX = 250;

  const hatch = (ya, yb, key) => Array.from({ length: 36 }, (_, i) => {
    const x = x0 - 6 + i * 11.5;
    if (x > 158 && x < 208) return null; // keep the layer name clear
    return <line key={`${key}${i}`} x1={x} y1={yb} x2={x + 10} y2={ya} stroke="var(--gray-400)" strokeWidth={0.9} />;
  });
  const dots = [];
  for (let x = x0 + 6; x < x1 - 4; x += 12) for (let y = aqTop + 7; y < aqBot - 3; y += 11) {
    const dx = x + ((Math.round(y / 11)) % 2) * 5;
    const nearText = (Math.abs(y - (aqTop + aqBot) / 2 + 10) < 10 && Math.abs(dx - 190) < 48) || (dx > tX - 4 && dx < tX + 42 && Math.abs(y - (aqTop + aqBot) / 2 - 12) < 10);
    if (!nearText) dots.push(<circle key={`${x}-${y}`} cx={dx} cy={y} r={1} fill="var(--gray-500)" fillOpacity={0.6} />);
  }

  return (
    <svg viewBox={`0 0 410 ${clayBot + 48}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Canal water surface El. ${elCanal} ft and river water surface El. ${elRiver} ft, ${dist} ft apart, over a ${b} ft sand aquifer`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <clipPath id="ctWraACanalClay">
          <polygon points={`${ground} ${x1},${aqTop} ${x0},${aqTop}`} />
        </clipPath>
      </defs>

      {/* Upper clay, cut by the canal and the river */}
      <polygon points={`${ground} ${x1},${aqTop} ${x0},${aqTop}`} fill="var(--gray-400)" fillOpacity={0.14} />
      <g clipPath="url(#ctWraACanalClay)">{hatch(groundY, aqTop, 'u')}</g>
      {/* Sand aquifer */}
      <rect x={x0} y={aqTop} width={x1 - x0} height={aqBot - aqTop} fill="var(--gray-400)" fillOpacity={0.06} />
      {dots}
      {/* Lower clay */}
      <rect x={x0} y={aqBot} width={x1 - x0} height={clayBot - aqBot} fill="var(--gray-400)" fillOpacity={0.14} />
      <svg x={x0} y={aqBot} width={x1 - x0} height={clayBot - aqBot} overflow="hidden">
        {hatch(0, clayBot - aqBot, 'l').filter(Boolean).map((l) => React.cloneElement(l, { x1: l.props.x1 - x0, x2: l.props.x2 - x0 }))}
      </svg>

      {/* Water in the canal and river */}
      <polygon points={`${cw[0]},${canalWs} ${cw[1]},${canalWs} ${canal[1] - side},${aqTop} ${canal[0] + side},${aqTop}`} fill="var(--info)" fillOpacity={0.25} />
      <polygon points={`${rw[0]},${riverWs} ${rw[1]},${riverWs} ${river[1] - side},${aqTop} ${river[0] + side},${aqTop}`} fill="var(--info)" fillOpacity={0.25} />
      <line x1={cw[0]} y1={canalWs} x2={cw[1]} y2={canalWs} stroke="var(--info)" strokeWidth={1.6} />
      <line x1={rw[0]} y1={riverWs} x2={rw[1]} y2={riverWs} stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={`${mid(canal) - 6},${canalWs - 11} ${mid(canal) + 6},${canalWs - 11} ${mid(canal)},${canalWs - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />
      <polygon points={`${mid(river) - 6},${riverWs - 11} ${mid(river) + 6},${riverWs - 11} ${mid(river)},${riverWs - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />

      {/* Ground and layer boundaries */}
      <polyline points={ground} fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <line x1={x0} y1={aqTop} x2={x1} y2={aqTop} stroke="var(--charcoal)" strokeWidth={1} />
      <line x1={x0} y1={aqBot} x2={x1} y2={aqBot} stroke="var(--charcoal)" strokeWidth={1} />

      {/* Water body labels above ground */}
      <Label x={mid(canal)} y={12} color="var(--charcoal)" fontSize={12} bold>canal</Label>
      <Label x={mid(canal)} y={28} color="var(--charcoal)" fontSize={12}>{`El. ${elCanal.toFixed(1)} ft`}</Label>
      <Label x={mid(river)} y={12} color="var(--charcoal)" fontSize={12} bold>river</Label>
      <Label x={mid(river)} y={28} color="var(--charcoal)" fontSize={12}>{`El. ${elRiver.toFixed(1)} ft`}</Label>

      {/* Layer names */}
      <Label x={190} y={(groundY + aqTop) / 2} color="var(--gray-500)" fontSize={11}>clay</Label>
      <Label x={190} y={(aqTop + aqBot) / 2 - 10} color="var(--charcoal)" fontSize={12}>sand aquifer</Label>
      <Label x={190} y={(aqBot + clayBot) / 2} color="var(--gray-500)" fontSize={11}>clay</Label>

      {/* Aquifer thickness */}
      <line x1={tX - 8} y1={aqTop} x2={tX - 8} y2={aqBot} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={tX - 12} y1={aqTop + 4} x2={tX - 4} y2={aqTop - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={tX - 12} y1={aqBot + 4} x2={tX - 4} y2={aqBot - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={tX} y={(aqTop + aqBot) / 2 + 12} color="var(--charcoal)" fontSize={12} anchor="start">{`${b} ft`}</Label>

      {/* Distance between the water bodies */}
      <line x1={mid(canal)} y1={clayBot + 4} x2={mid(canal)} y2={clayBot + 22} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={mid(river)} y1={clayBot + 4} x2={mid(river)} y2={clayBot + 22} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={mid(canal)} y1={clayBot + 16} x2={mid(river)} y2={clayBot + 16} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={mid(canal) - 4} y1={clayBot + 20} x2={mid(canal) + 4} y2={clayBot + 12} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={mid(river) - 4} y1={clayBot + 20} x2={mid(river) + 4} y2={clayBot + 12} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={(mid(canal) + mid(river)) / 2} y={clayBot + 30} color="var(--charcoal)" fontSize={12}>{`${dist.toLocaleString('en-US')} ft`}</Label>
      <Label x={x1} y={clayBot + 42} color="var(--gray-500)" fontSize={11} anchor="end">NOT TO SCALE</Label>
    </svg>
  );
}

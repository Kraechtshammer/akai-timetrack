// Generates the icon masters in this folder and the app's launcher icons from them:
//   node branding/icons/generate.js
// No dependencies. Every file is a 108 x 108 Android adaptive-icon canvas; the launcher shows
// the central 72 x 72 (18..90) under its mask. The SVGs use shapes only (paths, circles,
// ellipses, rects, transforms, linear gradients, one clip and one mask); the second half of this
// file turns the same geometry into vector drawables in android/app/src/main/res.
const fs = require('fs');
const path = require('path');
const out = (name, text) => fs.writeFileSync(path.join(__dirname, name), text);

// The sign's colours.
const RED = '#C62A30', CREAM = '#F6F1EC', MONO = '#3B2626';
const GRAD = '<linearGradient id="p" x1="0" y1="22" x2="0" y2="86" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#6E191F"/><stop offset="1" stop-color="#480E12"/></linearGradient>';

// Superellipse (n = 4) over the visible 72 area, moved inwards by `off` along its normals.
// off = 0 is the assumed launcher squircle; off = 4 is the dark panel, so the red frame is
// 4 units wide all round. (A scaled-down superellipse would give a frame that's thinner on
// the sides than in the corners.)
function squircle(off) {
  const C = 54, A = 36, N = 400, pts = [];
  for (let i = 0; i < N; i++) {
    const t = (i / N) * 2 * Math.PI, c = Math.cos(t), s = Math.sin(t);
    const x = A * Math.sign(c) * Math.sqrt(Math.abs(c)), y = A * Math.sign(s) * Math.sqrt(Math.abs(s));
    let nx = x ** 3, ny = y ** 3; const l = Math.hypot(nx, ny) || 1; nx /= l; ny /= l;
    pts.push((i ? 'L' : 'M') + (C + x - off * nx).toFixed(2) + ',' + (C + y - off * ny).toFixed(2));
  }
  return pts.join(' ') + ' Z';
}
// Red frame plus dark panel: squircle panel for squircle launchers, disc r = 32 for round ones.
const frame = (round) => `<rect width="108" height="108" fill="${RED}"/>` +
  (round ? '<circle cx="54" cy="54" r="32" fill="url(#p)"/>' : `<path d="${squircle(4)}" fill="url(#p)"/>`);
const svg = (defs, body) => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">\n<defs>${GRAD}${defs}</defs>\n${body}\n</svg>\n`;

// ---------------------------------------------------------------------------------------------
// Cloche: a serving dome whose clock hands are a spoon (long) and a fork (short), cut out so the
// panel shows through. In a vector drawable without masks, fill the hands with the panel
// gradient instead (same absolute coordinates) and it looks the same.
const SPOON = 'M-0.8,1.2 L-0.8,-8 Q-2.3,-9 -2.3,-12.2 Q-2.3,-16.2 0,-16.2 Q2.3,-16.2 2.3,-12.2 Q2.3,-9 0.8,-8 L0.8,1.2 Q0,2.2 -0.8,1.2 Z';
const FORK = 'M-1,1.2 L-1,-4.6 Q-2.6,-5.2 -2.6,-7.2 L-2.6,-11.3 Q-2.6,-11.9 -2.0,-11.9 Q-1.5,-11.9 -1.5,-11.3 L-1.5,-8.4 L-0.55,-8.4 L-0.55,-11.3 Q-0.55,-11.9 0,-11.9 Q0.55,-11.9 0.55,-11.3 L0.55,-8.4 L1.5,-8.4 L1.5,-11.3 Q1.5,-11.9 2.0,-11.9 Q2.6,-11.9 2.6,-11.3 L2.6,-7.2 Q2.6,-5.2 1,-4.6 L1,1.2 Q0,2.2 -1,1.2 Z';
const clocheMask = `<mask id="m"><g transform="translate(54 53.5) scale(0.9) translate(-54 -52.8)">
  <g fill="#fff"><rect x="48.5" y="33" width="11" height="4.6" rx="2.3"/><rect x="52" y="36" width="4" height="7" rx="1"/>
  <path d="M30 66 A24 24 0 0 1 78 66 Z"/><rect x="27" y="67.8" width="54" height="4.8" rx="2.4"/></g>
  <g fill="#000"><path transform="translate(54 62) rotate(-8)" d="${SPOON}"/><path transform="translate(54 62) rotate(62)" d="${FORK}"/></g>
</g></mask>`;
for (const round of [false, true]) {
  out(`cloche${round ? '-round' : ''}.svg`, svg(clocheMask, frame(round) + `<rect width="108" height="108" fill="${CREAM}" mask="url(#m)"/>`));
}
// Monochrome layer for themed icons (Android only uses its alpha).
out('cloche-mono.svg', `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">\n<defs>${clocheMask}</defs>\n<rect width="108" height="108" fill="${MONO}" mask="url(#m)"/>\n</svg>\n`);

// ---------------------------------------------------------------------------------------------
// Penguin under the cloche (secret icon). A baby penguin lifts the dome with one flipper.
// The plate's ends and the free flipper reach slightly (about 1-1.5 units) past the panel onto
// the red ring, which gives a bit of depth. Two options, both in the app:
//   navy ("Penguin, dark blue"): navy body with a dark outline
//   black ("Penguin, black"): the whole body in the dark colour, no extra edge (slightly slimmer)
const INK = '#0E1822', NAVY = '#1F3A52', WHITE = '#FFFFFF', ORANGE = '#F5A23A', ORANGE_D = '#C4691C', PINK = '#F7A1B5';
const PENGUINS = { navy: { fill: NAVY, edge: 2.4, dx: 0 }, black: { fill: INK, edge: 0, dx: 0.9 } };
// Local coordinates: (0,0) is between the eyes.
const BODY = 'M0,-11.5 C8,-11.5 13.6,-6 14,1 C14.3,7 17.2,12 17.6,19.5 C18,27.5 12.5,33 0,33 C-12.5,33 -18,27.5 -17.6,19.5 C-17.2,12 -14.3,7 -14,1 C-13.6,-6 -8,-11.5 0,-11.5 Z';
const FLIP_L = { cx: -16, cy: 3, rx: 3.6, ry: 8.5, rot: -40 }; // raised, holds the dome
const FLIP_R = { cx: 17.5, cy: 13, rx: 3.6, ry: 8.5, rot: -35 };
const CURL = 'M-1,-11 Q-2.5,-15.6 1.2,-16.4 Q-0.4,-14.4 1.6,-11.2 Z';
// White face and belly in one shape; the dark wedge between the eye lobes reaches the beak.
const FACE = 'M0,3.6 C-1,-3 -6,-5.2 -9,-3.7 C-12.2,-1.8 -12.4,3.5 -11.8,7.5 C-11.5,10.5 -13.6,14.5 -13.6,21.5 C-13.6,28.5 -8,32 0,32 C8,32 13.6,28.5 13.6,21.5 C13.6,14.5 11.5,10.5 11.8,7.5 C12.4,3.5 12.2,-1.8 9,-3.7 C6,-5.2 1,-3 0,3.6 Z';
const BEAK = 'M-3.5,4.1 C-3.5,2.3 3.5,2.3 3.5,4.1 C3.5,6.1 1.8,7.7 0,7.7 C-1.8,7.7 -3.5,6.1 -3.5,4.1 Z';
const MOUTH = 'M-2.6,5.6 Q0,6.5 2.6,5.6';
const CHEEKS = [[-9.3, 7.8, 1.9], [9.3, 7.8, 1.9]], EYES = [[-5.9, 3.4, 2.85], [5.9, 3.4, 2.85]], GLINTS = [[-6.7, 2.5, 1.05], [5.1, 2.5, 1.05]];
const PENGUIN_SCALE = 0.78;
// Per mask, so the dome rests on the raised flipper and the free flipper just reaches the ring.
function penguinLayout(name, round) {
  // Plate: overhangs the panel by 1.5 units at its centre line (y 72.9).
  const dy = 72.9 - 54, half = (round ? Math.sqrt(32 * 32 - dy * dy) : Math.pow(32 ** 4 - dy ** 4, 0.25)) + 1.5;
  return {
    x1: +(54 - half).toFixed(2), w: +(2 * half).toFixed(2),
    px: (round ? 65.5 : 68) + PENGUINS[name].dx, py: 52.4, tilt: round ? -50 : -46,
  };
}

function penguinSvg(name) {
  const { fill, edge } = PENGUINS[name];
  const ell = (f) => `<ellipse cx="${f.cx}" cy="${f.cy}" rx="${f.rx}" ry="${f.ry}" transform="rotate(${f.rot} ${f.cx} ${f.cy})"/>`;
  const dark = `${ell(FLIP_L)}${ell(FLIP_R)}<path d="${CURL}"/><path d="${BODY}"/>`;
  const circles = (list, colour) => list.map(([cx, cy, r]) => `<circle cx="${cx}" cy="${cy}" r="${r}" fill="${colour}"/>`).join('');
  return `
  ${edge ? `<g fill="${INK}" stroke="${INK}" stroke-width="${edge}" stroke-linejoin="round">${dark}</g>` : ''}
  <g fill="${fill}">${dark}</g>
  <path d="${FACE}" fill="${WHITE}"/>
  ${circles(CHEEKS, PINK)}
  ${circles(EYES, INK)}
  ${circles(GLINTS, WHITE)}
  <path d="${BEAK}" fill="${ORANGE}" stroke="${ORANGE_D}" stroke-width="0.7" stroke-linejoin="round"/>
  <path d="${MOUTH}" fill="none" stroke="${ORANGE_D}" stroke-width="0.6" stroke-linecap="round"/>`;
}
for (const name of Object.keys(PENGUINS)) for (const round of [false, true]) {
  const { x1, w, px, py, tilt } = penguinLayout(name, round);
  out(`penguin-${name}${round ? '-round' : ''}.svg`, svg('<clipPath id="above"><rect width="108" height="71"/></clipPath>', frame(round) + `
<g clip-path="url(#above)"><g transform="translate(${px} ${py}) scale(${PENGUIN_SCALE})">${penguinSvg(name)}</g></g>
<rect x="${x1}" y="71.7" width="${w}" height="4.8" rx="2.4" fill="#2A0709" opacity="0.35"/>
<g fill="${CREAM}">
  <rect x="${x1}" y="70.5" width="${w}" height="4.8" rx="2.4"/>
  <g transform="rotate(${tilt} 31 70.5)">
    <path d="M31 70.5 A17.5 17.5 0 0 1 66 70.5 Z"/>
    <rect x="44" y="48.5" width="9" height="4" rx="2"/>
    <rect x="47" y="51.5" width="3" height="4.5" rx="1"/>
  </g>
</g>`));
}

// =============================================================================================
// Android vector drawables, written to android/app/src/main/res (cloche and penguins; the AKAI
// sign's drawables are older and made by hand). Vector drawables have no masks, ellipses, rects
// or per-shape transforms, so every shape becomes one absolute path of lines and cubic curves
// with the SVG transforms applied to its points:
//   - the cut-out spoon and fork are painted with the panel gradient instead;
//   - the clip above the plate becomes a group clip-path;
//   - holes in the monochrome layers are clip-paths drawn the other way round (a hole under
//     both the non-zero and the even-odd rule).
// The SVGs above stay the masters; look at preview.png after changing shapes.
const RES = path.join(__dirname, '../../android/app/src/main/res');
const res = (dir, name, text) => fs.writeFileSync(path.join(RES, dir, name + '.xml'), text);

// Affine matrices [a, b, c, d, e, f] as in SVG: x' = a x + c y + e, y' = b x + d y + f.
const mul = (m, n) => [
  m[0] * n[0] + m[2] * n[1], m[1] * n[0] + m[3] * n[1],
  m[0] * n[2] + m[2] * n[3], m[1] * n[2] + m[3] * n[3],
  m[0] * n[4] + m[2] * n[5] + m[4], m[1] * n[4] + m[3] * n[5] + m[5]];
const chain = (...ms) => ms.reduce(mul, [1, 0, 0, 1, 0, 0]);
const T = (x, y) => [1, 0, 0, 1, x, y];
const S = (s) => [s, 0, 0, s, 0, 0];
const R = (deg, cx = 0, cy = 0) => {
  const r = (deg * Math.PI) / 180, c = Math.cos(r), s = Math.sin(r);
  return chain(T(cx, cy), [c, s, -s, c, 0, 0], T(-cx, -cy));
};

// A path is a list of subpaths; a subpath is a start point and segments ([x, y] lines or
// [x1, y1, x2, y2, x, y] cubics). Only closed subpaths, except for strokes.
function parse(d) {
  const tok = d.match(/[MLQCZ]|-?\d*\.?\d+/g), subs = [];
  let i = 0, cmd, cur, sub;
  const num = () => +tok[i++];
  while (i < tok.length) {
    if (/[A-Z]/.test(tok[i])) cmd = tok[i++];
    if (cmd === 'M') { cur = [num(), num()]; sub = { start: cur, segs: [] }; subs.push(sub); cmd = 'L'; }
    else if (cmd === 'L') { cur = [num(), num()]; sub.segs.push(cur); }
    else if (cmd === 'C') { const s = [num(), num(), num(), num(), num(), num()]; sub.segs.push(s); cur = s.slice(4); }
    else if (cmd === 'Q') {
      const [qx, qy, x, y] = [num(), num(), num(), num()];
      sub.segs.push([cur[0] + (2 / 3) * (qx - cur[0]), cur[1] + (2 / 3) * (qy - cur[1]), x + (2 / 3) * (qx - x), y + (2 / 3) * (qy - y), x, y]);
      cur = [x, y];
    } else if (cmd === 'Z') { sub.closed = true; cur = sub.start; }
  }
  return subs;
}
// Arc of an ellipse around (cx, cy) from angle a0 to a1 (degrees, y down), as cubics.
function arcSegs(cx, cy, rx, ry, a0, a1) {
  const n = Math.ceil(Math.abs(a1 - a0) / 90), segs = [];
  const step = ((a1 - a0) / n) * (Math.PI / 180), k = (4 / 3) * Math.tan(step / 4);
  for (let j = 0; j < n; j++) {
    const t0 = (a0 * Math.PI) / 180 + j * step, t1 = t0 + step;
    const [c0, s0, c1, s1] = [Math.cos(t0), Math.sin(t0), Math.cos(t1), Math.sin(t1)];
    segs.push([cx + rx * (c0 - k * s0), cy + ry * (s0 + k * c0), cx + rx * (c1 + k * s1), cy + ry * (s1 - k * c1), cx + rx * c1, cy + ry * s1]);
  }
  return segs;
}
const ellipse = (cx, cy, rx, ry) => [{ start: [cx + rx, cy], segs: arcSegs(cx, cy, rx, ry, 0, 360), closed: true }];
const circle = (cx, cy, r) => ellipse(cx, cy, r, r);
// Upper half disc on the line y = cy (the domes).
const dome = (cx, cy, r) => [{ start: [cx - r, cy], segs: arcSegs(cx, cy, r, r, 180, 360), closed: true }];
function rrect(x, y, w, h, r) {
  const segs = [];
  const corner = (cx, cy, a) => segs.push(...arcSegs(cx, cy, r, r, a, a + 90));
  segs.push([x + w - r, y]); corner(x + w - r, y + r, -90);
  segs.push([x + w, y + h - r]); corner(x + w - r, y + h - r, 0);
  segs.push([x + r, y + h]); corner(x + r, y + h - r, 90);
  segs.push([x, y + r]); corner(x + r, y + r, 180);
  return [{ start: [x + r, y], segs, closed: true }];
}
const rect = (x, y, w, h) => [{ start: [x, y], segs: [[x + w, y], [x + w, y + h], [x, y + h]], closed: true }];
function transform(subs, m) {
  const p = (x, y) => [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]];
  return subs.map((s) => ({
    ...s, start: p(...s.start),
    segs: s.segs.map((g) => (g.length === 2 ? p(...g) : [...p(g[0], g[1]), ...p(g[2], g[3]), ...p(g[4], g[5])])),
  }));
}
// Signed area of the polygon through all points (enough to tell the direction).
function area(sub) {
  const pts = [sub.start, ...sub.segs.flatMap((g) => (g.length === 2 ? [g] : [g.slice(0, 2), g.slice(2, 4), g.slice(4)]))];
  return pts.reduce((a, p, j) => { const q = pts[(j + 1) % pts.length]; return a + p[0] * q[1] - q[0] * p[1]; }, 0) / 2;
}
function reverse(sub) {
  const pts = [sub.start, ...sub.segs.map((g) => g.slice(-2))], segs = [];
  for (let j = sub.segs.length - 1; j >= 0; j--) {
    const g = sub.segs[j], to = pts[j];
    segs.push(g.length === 2 ? to : [g[2], g[3], g[0], g[1], ...to]);
  }
  return { start: pts[pts.length - 1], segs, closed: sub.closed };
}
const orient = (subs, sign) => subs.map((s) => (Math.sign(area(s)) === sign ? s : reverse(s)));
// The canvas with holes cut where `holes` are.
const without = (holes) => [...orient(rect(-20, -20, 148, 148), 1), ...orient(holes, -1)];

const f = (v) => (Math.abs(v) < 0.005 ? '0' : v.toFixed(2).replace(/\.?0+$/, ''));
const pathData = (subs) => subs.map((s) =>
  `M${f(s.start[0])},${f(s.start[1])}` +
  s.segs.map((g) => (g.length === 2 ? ` L${f(g[0])},${f(g[1])}` : ` C${f(g[0])},${f(g[1])} ${f(g[2])},${f(g[3])} ${f(g[4])},${f(g[5])}`)).join('') +
  (s.closed ? ' Z' : '')).join(' ');

// Drawing model: { d, fill, alpha, stroke, width, join, cap, evenOdd } paths and
// { clip, scale, children } groups. fill 'panel' is the panel gradient.
const argb = (c) => '#FF' + c.slice(1).toUpperCase();
const GRADIENT = (ind) => `${ind}    <aapt:attr name="android:fillColor">
${ind}        <gradient android:type="linear" android:startX="54" android:startY="22" android:endX="54" android:endY="86">
${ind}            <item android:color="#FF6E191F" android:offset="0" />
${ind}            <item android:color="#FF480E12" android:offset="1" />
${ind}        </gradient>
${ind}    </aapt:attr>`;
function xml(items, ind = '    ') {
  return items.map((it) => {
    if (it.children) {
      const attrs = it.scale ? ` android:scaleX="${it.scale}" android:scaleY="${it.scale}" android:pivotX="54" android:pivotY="54"` : '';
      const clip = it.clip ? `\n${ind}    <clip-path android:pathData="${pathData(it.clip)}" />` : '';
      return `${ind}<group${attrs}>${clip}\n${xml(it.children, ind + '    ')}\n${ind}</group>`;
    }
    const a = [`android:pathData="${pathData(it.d)}"`];
    if (it.fill && it.fill !== 'panel') a.push(`android:fillColor="${argb(it.fill)}"`);
    if (it.alpha !== undefined) a.push(`android:fillAlpha="${it.alpha}"`);
    if (it.evenOdd) a.push('android:fillType="evenOdd"');
    if (it.stroke) {
      a.push(`android:strokeColor="${argb(it.stroke)}"`, `android:strokeWidth="${f(it.width)}"`);
      if (it.join) a.push(`android:strokeLineJoin="${it.join}"`);
      if (it.cap) a.push(`android:strokeLineCap="${it.cap}"`);
    }
    const open = `${ind}<path\n${a.map((s) => `${ind}    ${s}`).join('\n')}`;
    return it.fill === 'panel' ? `${open}>\n${GRADIENT(ind)}\n${ind}</path>` : `${open} />`;
  }).join('\n');
}
const header = '<?xml version="1.0" encoding="utf-8"?>\n<!-- Generated by branding/icons/generate.js; do not edit by hand. -->\n';
const vector = (comment, items) => header + `<!-- ${comment} -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"${JSON.stringify(items).includes('"panel"') ? '\n    xmlns:aapt="http://schemas.android.com/aapt"' : ''}
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
${xml(items)}
</vector>
`;
const adaptive = (comment, bg, fg, mono) => header + `<!-- ${comment} -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="${bg}" />
    <foreground android:drawable="@drawable/${fg}" />
    <monochrome android:drawable="@drawable/${mono}" />
</adaptive-icon>
`;

// Shapes in absolute coordinates.
const PANEL = { round: circle(54, 54, 32), squircle: parse(squircle(4)) };
const background = (shape) => [{ d: rect(0, 0, 108, 108), fill: RED }, { d: PANEL[shape], fill: 'panel' }];

const CLOCHE_M = chain(T(54, 53.5), S(0.9), T(-54, -52.8)); // as in clocheMask
const cloche = {
  handle: transform(rrect(48.5, 33, 11, 4.6, 2.3), CLOCHE_M),
  stem: transform(rrect(52, 36, 4, 7, 1), CLOCHE_M),
  dome: transform(dome(54, 66, 24), CLOCHE_M),
  plate: transform(rrect(27, 67.8, 54, 4.8, 2.4), CLOCHE_M),
  spoon: transform(parse(SPOON), chain(CLOCHE_M, T(54, 62), R(-8))),
  fork: transform(parse(FORK), chain(CLOCHE_M, T(54, 62), R(62))),
};
const clocheFg = () => [
  ...['handle', 'stem', 'dome', 'plate'].map((k) => ({ d: cloche[k], fill: CREAM })),
  { d: cloche.spoon, fill: 'panel' }, { d: cloche.fork, fill: 'panel' },
];
// Themed icons use only the alpha. The spoon is a hole in the dome path, the fork a hole in
// the clip (two overlapping holes in one path would fill their overlap again).
const clocheMono = () => [
  { d: cloche.handle, fill: WHITE }, { d: cloche.stem, fill: WHITE }, { d: cloche.plate, fill: WHITE },
  { clip: without(cloche.fork), children: [{ d: [...orient(cloche.dome, 1), ...orient(cloche.spoon, -1)], fill: WHITE, evenOdd: true }] },
];

function penguinParts(name, round) {
  const L = penguinLayout(name, round), P = chain(T(L.px, L.py), S(PENGUIN_SCALE));
  const ell = (e) => transform(ellipse(e.cx, e.cy, e.rx, e.ry), chain(P, R(e.rot, e.cx, e.cy)));
  const loc = (subs) => transform(subs, P);
  const D = R(L.tilt, 31, 70.5);
  return {
    dark: [ell(FLIP_L), ell(FLIP_R), loc(parse(CURL)), loc(parse(BODY))],
    face: loc(parse(FACE)),
    cheeks: CHEEKS.map(([x, y, r]) => loc(circle(x, y, r))),
    eyes: EYES.map(([x, y, r]) => loc(circle(x, y, r))),
    glints: GLINTS.map(([x, y, r]) => loc(circle(x, y, r))),
    beak: loc(parse(BEAK)),
    mouth: loc(parse(MOUTH)),
    above: rect(0, 0, 108, 71),
    shadow: rrect(L.x1, 71.7, L.w, 4.8, 2.4),
    plate: rrect(L.x1, 70.5, L.w, 4.8, 2.4),
    dome: [transform(dome(48.5, 70.5, 17.5), D), transform(rrect(44, 48.5, 9, 4, 2), D), transform(rrect(47, 51.5, 3, 4.5, 1), D)],
  };
}
function penguinFg(name, round) {
  const p = penguinParts(name, round), { fill, edge } = PENGUINS[name], s = PENGUIN_SCALE;
  return [
    { clip: p.above, children: [
      ...(edge ? p.dark.map((d) => ({ d, fill: INK, stroke: INK, width: edge * s, join: 'round' })) : []),
      ...p.dark.map((d) => ({ d, fill })),
      { d: p.face, fill: WHITE },
      ...p.cheeks.map((d) => ({ d, fill: PINK })),
      ...p.eyes.map((d) => ({ d, fill: INK })),
      ...p.glints.map((d) => ({ d, fill: WHITE })),
      { d: p.beak, fill: ORANGE, stroke: ORANGE_D, width: 0.7 * s, join: 'round' },
      { d: p.mouth, stroke: ORANGE_D, width: 0.6 * s, cap: 'round' },
    ] },
    { d: p.shadow, fill: '#2A0709', alpha: 0.35 },
    { d: p.plate, fill: CREAM },
    ...p.dome.map((d) => ({ d, fill: CREAM })),
  ];
}
// Silhouette: dark parts with the face cut out, eyes and beak filled, plate and dome.
function penguinMono() {
  const p = penguinParts('black', false);
  return [
    { clip: p.above, children: [
      { clip: without(p.face), children: p.dark.map((d) => ({ d, fill: WHITE })) },
      ...p.eyes.map((d) => ({ d, fill: WHITE })),
      { d: p.beak, fill: WHITE },
    ] },
    { d: p.plate, fill: WHITE },
    ...p.dome.map((d) => ({ d, fill: WHITE })),
  ];
}
// Small squircle: the whole squircle icon, cut to the launcher squircle and scaled down to a
// half-size of 29.5 (like the AKAI sign's), on a transparent background.
const small = (items) => [{ scale: f(29.5 / 36), children: [{ clip: parse(squircle(0)), children: items }] }];

res('drawable', 'ic_launcher_panel_round', vector('Background of the round cloche and penguin icons: red frame, dark-red disc (r = 32).', background('round')));
res('drawable', 'ic_launcher_panel_squircle', vector('Background of the squircle cloche and penguin icons: red frame, dark-red squircle panel 4 units inside the launcher squircle.', background('squircle')));
res('drawable', 'ic_launcher_cloche_foreground', vector('Cloche icon, foreground: cream dome and plate; the spoon and fork are painted with the panel gradient.', clocheFg()));
res('drawable', 'ic_launcher_cloche_small_foreground', vector('Cloche icon "Small squircle": the whole squircle icon scaled down.', small([...background('squircle'), ...clocheFg()])));
res('drawable', 'ic_launcher_cloche_monochrome', vector('Cloche icon, monochrome layer for themed icons.', clocheMono()));
res('drawable', 'ic_launcher_penguin_monochrome', vector('Penguin icons, monochrome layer for themed icons.', penguinMono()));
const SHAPE_NOTE = { round: 'for round launcher masks (Pixel)', squircle: 'for squircle launcher masks (Xiaomi)', small: 'the whole squircle icon scaled down on a transparent background' };
res('mipmap-anydpi-v26', 'ic_launcher_cloche_round', adaptive(`Cloche icon, Round: ${SHAPE_NOTE.round}. The default icon.`, '@drawable/ic_launcher_panel_round', 'ic_launcher_cloche_foreground', 'ic_launcher_cloche_monochrome'));
res('mipmap-anydpi-v26', 'ic_launcher_cloche_squircle', adaptive(`Cloche icon, Squircle: ${SHAPE_NOTE.squircle}.`, '@drawable/ic_launcher_panel_squircle', 'ic_launcher_cloche_foreground', 'ic_launcher_cloche_monochrome'));
res('mipmap-anydpi-v26', 'ic_launcher_cloche_small', adaptive(`Cloche icon, Small squircle: ${SHAPE_NOTE.small}.`, '@android:color/transparent', 'ic_launcher_cloche_small_foreground', 'ic_launcher_cloche_monochrome'));
for (const name of Object.keys(PENGUINS)) {
  const label = `Penguin icon (${name})`;
  for (const round of [false, true]) {
    const shape = round ? 'round' : 'squircle';
    res('drawable', `ic_launcher_penguin_${name}_${shape}_foreground`, vector(`${label}, ${shape}, foreground: penguin, plate and lifted dome.`, penguinFg(name, round)));
    res('mipmap-anydpi-v26', `ic_launcher_penguin_${name}_${shape}`, adaptive(`${label}, ${shape === 'round' ? 'Round' : 'Squircle'}: ${SHAPE_NOTE[shape]}.`, `@drawable/ic_launcher_panel_${shape}`, `ic_launcher_penguin_${name}_${shape}_foreground`, 'ic_launcher_penguin_monochrome'));
  }
  res('drawable', `ic_launcher_penguin_${name}_small_foreground`, vector(`${label}, Small squircle: the whole squircle icon scaled down.`, small([...background('squircle'), ...penguinFg(name, false)])));
  res('mipmap-anydpi-v26', `ic_launcher_penguin_${name}_small`, adaptive(`${label}, Small squircle: ${SHAPE_NOTE.small}.`, '@android:color/transparent', `ic_launcher_penguin_${name}_small_foreground`, 'ic_launcher_penguin_monochrome'));
}

#!/usr/bin/env python3
"""Generates scene.rml, the badge artwork, from marks.json.

    flutter test tool/export_badge_marks_test.dart   # marks.json
    python3 rive/badge/gen.py                         # scene.rml
    rive rive/badge --once                            # assets/rive/badge.riv

Two artboards share one view model (`Badge`):

- BadgeEarned: the moment a badge is earned. The coin is tossed in edge-on,
  flips, lands with a squash, a ring and confetti go out, the raccoon pops
  up over the card, and then the badge's drawing traces itself onto the
  face. The words are NOT in here: Flutter sets them over the card, so they
  are real text for a screen reader and wrap like any other text.
- BadgeCoin: the same coin at rest, drawing complete, for the Badges page.

Which drawing shows is the view model's `mark` number, the badge's place in
`allBadges` (lib/features/profile/badges.dart). Colours come from Dart as
view model colours, so the brand tokens live in one place. Two events tell
the app when to tap the phone: `land` as the coin lands and `traced` as the
drawing completes.

The motion is hand-designed cubic eases with overshoot for the main beats;
the flip, the landing squash, the shadow and the confetti are baked per frame
from small physics models, the way an animator bakes a sim into keys.
"""
import json
import math
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
MARKS = json.load(open(os.path.join(HERE, "marks.json")))["marks"]

W, H = 780, 920
CARD = dict(x=36, y=150, w=708, h=734, r=72)
MC = (390, 400)          # medallion centre at rest
R = 150                  # face radius
PLINTH = 20              # plinth drop
EDGE_T = 26              # coin thickness seen during the flip
LAND = 46                # landing frame
DUR = 198                # 2.5 s of motion + ~0.8 s hold
MARK_SPAN = 248          # the 512 drawing square, on the face

# Defaults only: Dart pushes the real colours (badge_art.dart).
SPRING, FOREST, CHAR = "FF63F0A8", "FF2D7A5F", "FF2C2C2C"
CREAM, SUN, EMBER = "FFFFF9F0", "FFF5B731", "FFE8683A"

_id = [10]
def nid():
    _id[0] += 1
    return f"0:{_id[0]}"

def f(v):
    s = f"{v:.3f}".rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s

def clamp(v, a, b): return max(a, min(b, v))

# ---------------------------------------------------------------- view model
VM, VMI = nid(), nid()
P = {n: nid() for n in ("mark", "coin", "rim", "ink", "glow", "glowSoft")}
PROPS = [("mark", "Number", "0"), ("coin", "Color", SPRING), ("rim", "Color", FOREST),
         ("ink", "Color", CHAR), ("glow", "Color", "6663F0A8"), ("glowSoft", "Color", "3363F0A8")]

def bind(prop, key):
    return f'<DataBindContext sourcePathIds="{VM}-{P[prop]}" propertyKey="{key}"/>'

def solid(c, prop=None):
    return f'<SolidColor colorValue="{c}">{bind(prop, 37)}</SolidColor>' if prop else f'<SolidColor colorValue="{c}"/>'
def fill(c, prop=None): return f'<Fill>{solid(c, prop)}</Fill>'

def stops(lst):
    out = []
    for c, p, *b in lst:
        inner = bind(b[0], 38) if b else ""
        out.append(f'<GradientStop colorValue="{c}" position="{p}">{inner}</GradientStop>' if inner
                   else f'<GradientStop colorValue="{c}" position="{p}"/>')
    return "".join(out)
def lin(x0, y0, x1, y1, st):
    return f'<LinearGradient startX="{f(x0)}" startY="{f(y0)}" endX="{f(x1)}" endY="{f(y1)}">{stops(st)}</LinearGradient>'
def rad(x0, y0, x1, y1, st):
    return f'<RadialGradient startX="{f(x0)}" startY="{f(y0)}" endX="{f(x1)}" endY="{f(y1)}">{stops(st)}</RadialGradient>'

def pts(lst, closed=False):
    v = "".join(f'<StraightVertex x="{f(x)}" y="{f(y)}"/>' for x, y in lst)
    return f'<PointsPath isClosed="{"true" if closed else "false"}">{v}</PointsPath>'

# ---------------------------------------------------------------- animation
EASES = {
    "out": (0, 0, 0.58, 1), "in": (0.42, 0, 1, 1), "inout": (0.42, 0, 0.58, 1),
    "outq": (0.16, 1, 0.3, 1), "back": (0.34, 1.56, 0.64, 1),
}

class Anim:
    def __init__(self):
        self.keyed = {}
        self.events = {}
    def key(self, obj, prop, frames):
        self.keyed.setdefault((obj, prop), []).extend(frames)
    def bake(self, obj, prop, fn, f0, f1, step=1):
        fr = list(range(f0, f1 + 1, step))
        if fr[-1] != f1:
            fr.append(f1)
        self.key(obj, prop, [(i, fn(i), "linear") for i in fr])
    def event(self, obj, frame):
        self.events.setdefault(obj, []).append(frame)
    def xml(self, name, aid, duration, loop="oneShot"):
        o = [f'<LinearAnimation fps="60" duration="{duration}" loopValue="{loop}" name="{name}" id="{aid}">']
        by_obj = {}
        for (obj, prop), frs in self.keyed.items():
            by_obj.setdefault(obj, []).append((prop, frs))
        for obj, props in by_obj.items():
            o.append(f'<KeyedObject objectId="{obj}">')
            for prop, frs in props:
                dedup = {}
                for fr, v, it in sorted(frs, key=lambda t: t[0]):
                    dedup[fr] = (v, it)
                o.append(f'<KeyedProperty propertyKey="{prop}">' +
                         "".join(kf_xml(fr, v, it) for fr, (v, it) in sorted(dedup.items())) +
                         '</KeyedProperty>')
            o.append('</KeyedObject>')
        for obj, frames in self.events.items():
            o.append(f'<KeyedObject objectId="{obj}"><KeyedProperty propertyKey="395">' +
                     "".join(f'<KeyFrameCallback frame="{fr}"/>' for fr in frames) +
                     '</KeyedProperty></KeyedObject>')
        o.append('</LinearAnimation>')
        return "\n".join(o)

def kf_xml(frame, value, interp):
    if interp in (None, "hold", "linear"):
        return f'<KeyFrameDouble value="{f(value)}" frame="{frame}" interpolationType="{interp or "hold"}"/>'
    x1, y1, x2, y2 = EASES[interp] if isinstance(interp, str) else interp
    return (f'<KeyFrameDouble value="{f(value)}" frame="{frame}" interpolationType="cubic">'
            f'<CubicEaseInterpolator x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}"/></KeyFrameDouble>')

def ease_val(t, x1, y1, x2, y2):
    """CSS cubic-bezier evaluated at time t (for baking)."""
    lo, hi = 0.0, 1.0
    for _ in range(40):
        m = (lo + hi) / 2
        bx = 3*(1-m)**2*m*x1 + 3*(1-m)*m*m*x2 + m**3
        if bx < t: lo = m
        else: hi = m
    m = (lo + hi) / 2
    return 3*(1-m)**2*m*y1 + 3*(1-m)*m*m*y2 + m**3

def ease_inv(y, x1, y1, x2, y2):
    """The time t at which the eased curve reaches y (monotone curves)."""
    lo, hi = 0.0, 1.0
    for _ in range(40):
        m = (lo + hi) / 2
        if ease_val(m, x1, y1, x2, y2) < y: lo = m
        else: hi = m
    return (lo + hi) / 2

# ================================================================ physics
PEAK_F, PEAK_H = 18, 130
def lift(fr):            # negative is up
    if fr <= 0: return 0
    if fr <= PEAK_F:
        t = fr / PEAK_F
        return -PEAK_H * (1 - (1 - t) ** 2)
    if fr <= LAND:
        t = (fr - PEAK_F) / (LAND - PEAK_F)
        return -PEAK_H * (1 - t * t)
    tau = fr - LAND
    if tau <= 14:
        u = tau / 14
        return -16 * 4 * u * (1 - u)
    return 0

def arrive_scale(fr):
    t = clamp(fr / 22, 0, 1)
    return 0.42 + 0.58 * ease_val(t, 0.2, 0.9, 0.3, 1.12)

THETA0 = 3.5 * math.pi   # 1.75 turns, starts edge-on
def theta(fr):
    base = THETA0 * (1 - fr / LAND) ** 2.6 if fr <= LAND else 0.0
    if fr > LAND - 2:
        tau = fr - (LAND - 2)
        base += -0.42 * math.exp(-tau / 11) * math.sin(2 * math.pi * tau / 17)
    return base

def coin_tilt(fr):
    if fr <= LAND:
        return -0.22 * math.sin(math.pi * clamp(fr / LAND, 0, 1)) - 0.06 * (fr / LAND)
    tau = fr - LAND
    return -0.06 * math.exp(-tau / 7) * math.cos(2 * math.pi * tau / 20)

def squash(fr):          # (sx, sy) about the plinth bottom
    if fr < LAND:
        if fr > PEAK_F:
            v = (fr - PEAK_F) / (LAND - PEAK_F)
            return (1 - 0.05 * v * v, 1 + 0.07 * v * v)
        return (1, 1)
    tau = fr - LAND
    a = math.exp(-tau / 8.5) * math.cos(2 * math.pi * tau / 15)
    return (1 + 0.09 * a, 1 - 0.12 * a)

# ================================================================ the drawings
T0, TRACE = 62, 40       # the drawing traces from T0 over TRACE frames
TRACE_EASE = (0.5, 0, 0.35, 1)
FILL_WEIGHT = 70         # a solid marker takes as long as 70 units of line

def emit_marks(out, anim, animated):
    """Every badge's drawing on the face, each in its own group, all hidden;
    the Mark layer shows one. Returns the group ids in badge order."""
    groups = []
    s = MARK_SPAN / 512
    for m in MARKS:
        g = nid()
        groups.append(g)
        out.append(f'<Node x="{f(-256*s)}" y="{f(-256*s)}" scaleX="{f(s)}" scaleY="{f(s)}" opacity="0" name="Mark {m["id"]}" id="{g}">')
        weights = []
        for st in m["strokes"]:
            weights.append(FILL_WEIGHT if st["fill"] else sum(c["length"] for c in st["contours"]))
        total = sum(weights) or 1
        at = 0.0
        for st, w in zip(m["strokes"], weights):
            a, b = at / total, (at + w) / total
            at += w
            fa = T0 + round(TRACE * ease_inv(a, *TRACE_EASE))
            fb = T0 + max(round(TRACE * ease_inv(b, *TRACE_EASE)), fa - T0 + 2)
            if st["fill"]:
                allp = [p for c in st["contours"] for p in c["points"]]
                cx = sum(p[0] for p in allp) / len(allp)
                cy = sum(p[1] for p in allp) / len(allp)
                sh = nid()
                paths = "".join(pts([(x - cx, y - cy) for x, y in c["points"]], True) for c in st["contours"])
                sc = "0" if animated else "1"
                out.append(f'<Shape x="{f(cx)}" y="{f(cy)}" scaleX="{sc}" scaleY="{sc}" name="Dot" id="{sh}">'
                           f'{paths}{fill(CHAR, "ink")}</Shape>')
                if animated:
                    for prop in (16, 17):
                        anim.key(sh, prop, [(0, 0, "hold"), (fa, 0, "back"), (fa + 14, 1, "hold")])
            else:
                tr = nid()
                paths = "".join(pts([tuple(p) for p in c["points"]], c["closed"]) for c in st["contours"])
                end = "0" if animated else "1"
                out.append(f'<Shape name="Line">{paths}'
                           f'<Stroke thickness="{f(st["width"])}" cap="round" join="round">{solid(CHAR, "ink")}'
                           f'<TrimPath start="0" end="{end}" name="Draw" id="{tr}"/></Stroke></Shape>')
                if animated:
                    anim.key(tr, 115, [(0, 0, "hold"), (fa, 0, "linear"), (fb, 1, "hold")])
        out.append('</Node>')
    return groups

def mark_layer(groups, out_anims):
    """A layer that shows the drawing `mark` names: Pick waits for a value;
    each Mark state holds while the number matches and returns to Pick when
    it changes."""
    layer, pick = nid(), nid()
    states, trans_pick = [], []
    for i, g in enumerate(groups):
        aid, sid = nid(), nid()
        a = Anim()
        a.key(g, 18, [(0, 1, "hold")])
        out_anims.append(a.xml(f"Show {MARKS[i]['id']}", aid, 1))
        cond = lambda op: (f'<TransitionViewModelCondition opValue="{op}"><TransitionPropertyViewModelComparator>'
                           f'<BindablePropertyNumber>{bind("mark", 636)}</BindablePropertyNumber>'
                           f'</TransitionPropertyViewModelComparator><TransitionValueNumberComparator value="{i}"/>'
                           '</TransitionViewModelCondition>')
        trans_pick.append(f'<StateTransition stateToId="{sid}">{cond("equal")}</StateTransition>')
        states.append(f'<AnimationState animationId="{aid}" x="{160 + 120 * (i % 5)}" y="{120 * (i // 5)}" id="{sid}">'
                      f'<StateTransition stateToId="{pick}">{cond("notEqual")}</StateTransition></AnimationState>')
    # Pick plays an empty timeline: every drawing stays hidden until the
    # number arrives.
    pick_anim = nid()
    out_anims.append(Anim().xml("Pick", pick_anim, 1))
    return (f'<StateMachineLayer name="Mark" id="{layer}"><AnyState x="0" y="-200"/><ExitState x="120" y="-200"/>'
            f'<EntryState x="0" y="-100"><StateTransition stateToId="{pick}"/></EntryState>'
            f'<AnimationState animationId="{pick_anim}" x="0" y="0" id="{pick}">{"".join(trans_pick)}</AnimationState>' +
            "".join(states) + '</StateMachineLayer>')

# ================================================================ the coin
def emit_coin(out, anim, animated):
    """The medallion at the origin: faces, edge and plinth. Returns the ids
    the earned moment animates."""
    ids = {}
    frontG, backG, faceClip, shine = nid(), nid(), nid(), nid()
    ids.update(front=frontG, back=backG, shine=shine)
    out.append(f'<Node name="FrontFace" id="{frontG}">')
    ids["marks"] = emit_marks(out, anim, animated)
    out.append(f'<Shape x="-300" y="0" rotation="0.42" name="Shine" id="{shine}">'
               f'<Rectangle width="86" height="460"/>'
               f'<Fill>{lin(-43, 0, 43, 0, [("00FFFFFF", 0), ("80FFFFFF", 0.5), ("00FFFFFF", 1)])}</Fill>'
               f'<ClippingShape sourceId="{faceClip}"/></Shape>')
    out.append(f'<Shape name="FaceClip" id="{faceClip}"><Ellipse width="{2*R-6}" height="{2*R-6}"/></Shape>')
    out.append(f'<Shape name="InnerRing"><Ellipse width="{2*R-34}" height="{2*R-34}"/>'
               f'<Stroke thickness="3">{lin(0, -R, 0, R, [("40FFFFFF", 0), ("00FFFFFF", 0.5), ("1A2C2C2C", 1)])}</Stroke></Shape>')
    out.append(f'<Shape name="InnerRingShade"><Ellipse width="{2*R-40}" height="{2*R-40}"/>'
               f'<Stroke thickness="3">{lin(0, -R, 0, R, [("1A2C2C2C", 0), ("002C2C2C", 0.5), ("33FFFFFF", 1)])}</Stroke></Shape>')
    out.append(f'<Shape name="Face"><Ellipse width="{2*R}" height="{2*R}"/>{fill(SPRING, "coin")}'
               f'<Fill>{rad(-40, -70, 220, -70, [("55FFFFFF", 0), ("00FFFFFF", 1)])}</Fill>'
               f'<Fill>{lin(0, 10, 0, R, [("002C2C2C", 0), ("242C2C2C", 1)])}</Fill>'
               f'<Stroke thickness="2.5">{lin(0, -R, 0, 0, [("66FFFFFF", 0), ("00FFFFFF", 1)])}</Stroke></Shape>')
    out.append('</Node>')

    out.append(f'<Node opacity="0" name="BackFace" id="{backG}">')
    out.append(f'<Shape name="BackRing"><Ellipse width="{2*R-40}" height="{2*R-40}"/>'
               f'<Stroke thickness="5">{lin(0, -R, 0, R, [("332C2C2C", 0), ("00FFFFFF", 0.5), ("33FFFFFF", 1)])}</Stroke></Shape>')
    out.append(f'<Shape name="Back"><Ellipse width="{2*R}" height="{2*R}"/>{fill(FOREST, "rim")}'
               f'<Fill>{rad(-40, -70, 220, -70, [("33FFFFFF", 0), ("00FFFFFF", 1)])}</Fill>'
               f'<Fill>{lin(0, 0, 0, R, [("002C2C2C", 0), ("332C2C2C", 1)])}</Fill></Shape>')
    out.append('</Node>')

    edgeCap, edgeBandRect = nid(), nid()
    shade = f'<Fill>{lin(0, -R, 0, R, [("1A2C2C2C", 0), ("552C2C2C", 1)])}</Fill>'
    out.append(f'<Shape name="EdgeBand"><Rectangle width="0" height="{2*R}" id="{edgeBandRect}"/>{fill(FOREST, "rim")}{shade}</Shape>')
    out.append(f'<Shape name="EdgeCap" id="{edgeCap}"><Ellipse width="{2*R}" height="{2*R}"/>{fill(FOREST, "rim")}{shade}</Shape>')
    ids.update(edgeCap=edgeCap, edgeBandRect=edgeBandRect)

    pA, pB, pBandR = nid(), nid(), nid()
    plinth_fill = f'{fill(FOREST, "rim")}<Fill>{lin(0, 40, 0, R, [("262C2C2C", 0), ("6B2C2C2C", 1)])}</Fill>'
    out.append(f'<Node y="{PLINTH}" name="Plinth">')
    out.append(f'<Shape name="PlinthA" id="{pA}"><Ellipse width="{2*R}" height="{2*R}"/>{plinth_fill}</Shape>')
    out.append(f'<Shape name="PlinthB" id="{pB}"><Ellipse width="{2*R}" height="{2*R}"/>{plinth_fill}</Shape>')
    out.append(f'<Shape name="PlinthBand"><Rectangle width="0" height="{2*R}" id="{pBandR}"/>{plinth_fill}</Shape>')
    out.append('</Node>')
    ids.update(pA=pA, pB=pB, pBandR=pBandR)
    return ids

def state_machine(sm, layers):
    return f'<StateMachine name="Main" id="{sm}">{"".join(layers)}</StateMachine>'

def play_layer(anim_id):
    layer, st = nid(), nid()
    return (f'<StateMachineLayer name="Play" id="{layer}"><AnyState x="320" y="-100"/><ExitState x="440" y="-100"/>'
            f'<EntryState x="0" y="16"><StateTransition stateToId="{st}"/></EntryState>'
            f'<AnimationState animationId="{anim_id}" x="160" y="0" id="{st}"/></StateMachineLayer>')

IMG = nid()
out = ['<Rive version="1" kind="fragment">']

# ================================================================ BadgeEarned
def build_earned():
    anim = Anim()
    sm, aid, art = nid(), nid(), nid()
    o = [f'<Artboard defaultStateMachineId="{sm}" viewModelId="{VM}" viewModelInstanceId="{VMI}" '
         f'width="{W}" height="{H}" name="BadgeEarned" id="{art}">']

    land_evt, traced_evt = nid(), nid()
    o.append(f'<Event name="land" id="{land_evt}"/>')
    o.append(f'<Event name="traced" id="{traced_evt}"/>')
    anim.event(land_evt, LAND)
    anim.event(traced_evt, T0 + TRACE)

    # ---- confetti (front layer is declared first = on top)
    random.seed(7)
    cols = [SUN, EMBER, SPRING, SUN, EMBER]
    pieces = []
    for i in range(36):
        front = i % 3 == 0
        capsule = random.random() < 0.45
        w_, h_ = (11, 31) if capsule else (18, 25)
        ang = math.radians(random.uniform(-168, -12))
        spd = random.uniform(9.5, 19.5) * (1.06 if front else 0.94)
        start = LAND + random.randint(0, 4)
        sc = random.uniform(0.85, 1.15) * (1.08 if front else 0.86)
        pieces.append(dict(front=front, ang=ang, spd=spd, start=start, capsule=capsule,
                           w=w_ * sc, h=h_ * sc, col=random.choice(cols),
                           spin=random.uniform(0.07, 0.24) * random.choice([-1, 1]),
                           rot0=random.uniform(0, math.pi), tumble=random.uniform(0.12, 0.3),
                           ph=random.uniform(0, 6.28), sway=random.uniform(0.1, 0.32),
                           fade=random.randint(108, 150)))

    def sim_piece(p):
        xs = {}
        rr0 = R * (0.98 if p["front"] else 0.7)
        x = MC[0] + math.cos(p["ang"]) * rr0
        y = MC[1] + 20 + math.sin(p["ang"]) * rr0 * 0.8
        vx, vy = math.cos(p["ang"]) * p["spd"] * 0.82, math.sin(p["ang"]) * p["spd"]
        rot, tum, spin = p["rot0"], p["ph"], p["spin"]
        end = min(DUR, p["fade"] + 22)
        for fr in range(p["start"], end + 1):
            xs[fr] = (x, y, rot, math.cos(tum))
            vy += 0.52
            vx *= 0.955; vy *= 0.962
            if vy > 0:
                vx += math.sin(fr * 0.16 + p["ph"]) * p["sway"]
                vy = min(vy, 5.2)
            x += vx; y += vy
            rot += spin; spin *= 0.992
            tum += p["tumble"]
        return xs

    def confetti(front):
        for p in pieces:
            if p["front"] != front: continue
            node, shp = nid(), nid()
            o.append(f'<Node x="{MC[0]}" y="{MC[1]}" opacity="0" name="Confetti" id="{node}">')
            rr = min(p["w"], p["h"]) / 2 if p["capsule"] else 4
            o.append(f'<Shape name="Piece" id="{shp}"><Rectangle width="{f(p["w"])}" height="{f(p["h"])}" '
                     f'cornerRadiusTL="{f(rr)}"/>{fill(p["col"])}</Shape></Node>')
            sim = sim_piece(p)
            frs = sorted(sim)
            sel = frs[::3] + ([frs[-1]] if frs[-1] not in frs[::3] else [])
            anim.key(node, 13, [(p["start"] - 1, sim[frs[0]][0], "hold")] + [(i, sim[i][0], "linear") for i in sel])
            anim.key(node, 14, [(p["start"] - 1, sim[frs[0]][1], "hold")] + [(i, sim[i][1], "linear") for i in sel])
            anim.key(node, 15, [(i, sim[i][2], "linear") for i in sel])
            anim.key(shp, 17, [(i, sim[i][3], "linear") for i in sel])
            anim.key(node, 18, [(0, 0, "hold"), (p["start"], 1, "hold"),
                                (p["fade"], 1, "inout"), (min(DUR, p["fade"] + 22), 0, "hold")])

    confetti(True)

    # ---- four-point glints around the medallion, as the drawing completes
    for gx, gy, gs, gf in [(-178, -118, 1.0, 98), (172, -60, 0.8, 104), (-150, 96, 0.65, 110), (196, 70, 0.55, 116)]:
        g = nid()
        o.append(f'<Shape x="{MC[0]+gx}" y="{MC[1]+gy}" scaleX="0" scaleY="0" name="Glint" id="{g}">'
                 f'<Star width="{f(34*gs)}" height="{f(34*gs)}" points="4" innerRadius="0.28" cornerRadius="1.5"/>{fill(SUN)}</Shape>')
        for prop in (16, 17):
            anim.key(g, prop, [(0, 0, "hold"), (gf, 0, "back"), (gf + 10, 1, "inout"), (gf + 26, 0, "hold")])
        anim.key(g, 15, [(gf, -0.6, "out"), (gf + 26, 0.5, "hold")])

    # ---- medallion
    med, liftN, squashN, scaleN = nid(), nid(), nid(), nid()
    o.append(f'<Node x="{MC[0]}" y="{MC[1]}" opacity="0" name="Medallion" id="{med}">')
    o.append(f'<Node name="Lift" id="{liftN}">')
    sq = R + PLINTH
    o.append(f'<Node y="{sq}" name="Squash" id="{squashN}">')
    o.append(f'<Node y="{-sq}" name="Arrive" id="{scaleN}">')
    ids = emit_coin(o, anim, animated=True)
    o.append('</Node></Node></Node></Node>')

    # ---- rings, glow, shadow
    rings = []
    for delay, op, th in [(0, 0.32, 6), (7, 0.17, 3.5)]:
        rg, st = nid(), nid()
        rings.append((rg, st, delay, op, th))
        o.append(f'<Shape x="{MC[0]}" y="{MC[1]+6}" opacity="0" name="Ring" id="{rg}"><Ellipse width="{2*R+12}" height="{2*R+12}"/>'
                 f'<Stroke thickness="{th}" id="{st}">{solid(FOREST, "rim")}</Stroke></Shape>')
    glow = nid()
    o.append(f'<Shape x="{MC[0]}" y="{MC[1]+4}" opacity="0" name="Glow" id="{glow}"><Ellipse width="600" height="600"/>'
             f'<Fill>{rad(0, 0, 300, 0, [("6663F0A8", 0, "glow"), ("3363F0A8", 0.45, "glowSoft"), ("00FFF9F0", 1)])}</Fill></Shape>')
    shadow = nid()
    o.append(f'<Shape x="{MC[0]}" y="{MC[1] + R + PLINTH + 2}" opacity="0" name="Shadow" id="{shadow}"><Ellipse width="330" height="52"/>'
             f'<Fill>{rad(0, 0, 165, 0, [("552C2C2C", 0), ("2A2C2C2C", 0.5), ("002C2C2C", 1)])}</Fill></Shape>')

    confetti(False)

    # ---- raccoon, listed before the card so it draws in front of it: the
    # face rests on the card's top edge and the nose sits over the card.
    rac, racPose, racClip, racClipR = nid(), nid(), nid(), nid()
    o.append(f'<Node x="552" y="{CARD["y"]}" name="Raccoon" id="{rac}">'
             f'<Node y="140" name="Pose" id="{racPose}">'
             f'<Image assetId="{IMG}" originX="0.5" originY="{f(110/133)}" scaleX="0.84" scaleY="0.84" name="Head"/>'
             f'</Node><ClippingShape sourceId="{racClip}"/></Node>')
    o.append(f'<Shape name="RaccoonClip" id="{racClip}"><Rectangle originX="0" originY="0" width="{W}" height="{CARD["y"]}" id="{racClipR}"/></Shape>')

    # ---- card
    o.append(f'<Shape x="{CARD["x"]}" y="{CARD["y"]}" name="Card"><Rectangle width="{CARD["w"]}" height="{CARD["h"]}" '
             f'originX="0" originY="0" cornerRadiusTL="{CARD["r"]}"/>{fill(CREAM)}</Shape>')

    # ---------------------------------------------------------- keys
    anim.key(med, 18, [(0, 0, "linear"), (5, 1, "hold")])
    anim.bake(liftN, 14, lift, 0, LAND + 16)
    anim.bake(scaleN, 16, arrive_scale, 0, 24)
    anim.bake(scaleN, 17, arrive_scale, 0, 24)
    anim.bake(scaleN, 15, coin_tilt, 0, LAND + 40)
    anim.bake(squashN, 16, lambda i: squash(i)[0], LAND - 26, LAND + 44)
    anim.bake(squashN, 17, lambda i: squash(i)[1], LAND - 26, LAND + 44)

    flip_end = LAND + 60
    c_ = lambda i: math.cos(theta(i))
    s_ = lambda i: math.sin(theta(i))
    face_x = lambda i: s_(i) * EDGE_T / 2
    back_x = lambda i: -s_(i) * EDGE_T / 2
    width_k = lambda i: max(abs(c_(i)), 0.001)
    for g in (ids["front"], ids["back"]):
        anim.bake(g, 13, face_x, 0, flip_end)
        anim.bake(g, 16, width_k, 0, flip_end)
    anim.key(ids["front"], 18, [(i, 1 if c_(i) > 0 else 0, "hold") for i in range(0, flip_end + 1)])
    anim.key(ids["back"], 18, [(i, 0 if c_(i) > 0 else 1, "hold") for i in range(0, flip_end + 1)])
    anim.bake(ids["edgeCap"], 13, back_x, 0, flip_end)
    anim.bake(ids["edgeCap"], 16, width_k, 0, flip_end)
    anim.bake(ids["edgeBandRect"], 20, lambda i: abs(s_(i)) * EDGE_T, 0, flip_end)
    anim.bake(ids["pA"], 13, face_x, 0, flip_end)
    anim.bake(ids["pB"], 13, back_x, 0, flip_end)
    for p in (ids["pA"], ids["pB"]):
        anim.bake(p, 16, width_k, 0, flip_end)
    anim.bake(ids["pBandR"], 20, lambda i: abs(s_(i)) * EDGE_T, 0, flip_end)

    def sh_scale(i):
        h = -lift(i)
        return (0.42 + 0.58 * arrive_scale(i) if i < 24 else 1) * (1 - 0.5 * h / PEAK_H) * squash(i)[0] ** 0.5
    anim.bake(shadow, 16, sh_scale, 0, LAND + 44, 2)
    anim.bake(shadow, 17, lambda i: sh_scale(i) * (1 - 0.1 * (-lift(i)) / PEAK_H), 0, LAND + 44, 2)
    anim.bake(shadow, 18, lambda i: clamp(i / 6, 0, 1) * (1 - 0.7 * (-lift(i)) / PEAK_H), 0, LAND + 44, 2)

    for rg, st, delay, op, th in rings:
        s0 = LAND + delay
        anim.key(rg, 18, [(0, 0, "hold"), (s0, op, "out"), (s0 + 42, 0, "hold")])
        for prop in (16, 17):
            anim.key(rg, prop, [(0, 1, "hold"), (s0, 1, "outq"), (s0 + 42, 1.75, "hold")])
        anim.key(st, 47, [(0, th, "hold"), (s0, th, "out"), (s0 + 42, 1, "hold")])

    anim.key(glow, 18, [(0, 0, "hold"), (LAND, 0, "out"), (LAND + 10, 1, "inout"), (LAND + 50, 0.55, "hold")])
    for prop in (16, 17):
        anim.key(glow, prop, [(0, 0.7, "hold"), (LAND, 0.7, "outq"), (LAND + 30, 1.05, "inout"), (LAND + 60, 1, "hold")])

    # the shine sweeps once the drawing is complete
    anim.key(ids["shine"], 13, [(0, -300, "hold"), (T0 + TRACE + 4, -300, (0.45, 0, 0.25, 1)), (T0 + TRACE + 34, 300, "hold")])

    # raccoon: rises with stretch, squashes on the stop, overshoots, tilts, bobs
    rs = LAND + 4
    anim.key(racPose, 14, [(0, 140, "hold"), (rs, 140, (0.2, 0.6, 0.35, 1)), (rs + 10, -18, (0.45, 0, 0.55, 1)),
                           (rs + 17, 5, (0.4, 0, 0.6, 1)), (rs + 24, -3, "inout"), (rs + 31, 0, "hold"),
                           (112, 0, "inout"), (142, -4, "inout"), (172, 0, "inout"), (DUR, -3, "hold")])
    anim.key(racPose, 16, [(0, 0.86, "hold"), (rs, 0.86, "out"), (rs + 10, 0.92, "inout"), (rs + 17, 1.1, "inout"),
                           (rs + 24, 0.97, "inout"), (rs + 31, 1, "hold")])
    anim.key(racPose, 17, [(0, 1.18, "hold"), (rs, 1.18, "out"), (rs + 10, 1.1, "inout"), (rs + 17, 0.86, "inout"),
                           (rs + 24, 1.04, "inout"), (rs + 31, 1, "hold")])
    anim.key(racPose, 15, [(0, 0, "hold"), (rs + 22, 0, (0.3, 0, 0.3, 1.4)), (rs + 36, -0.11, "inout"),
                           (rs + 70, -0.07, "inout"), (150, 0.04, "inout"), (176, -0.03, "hold")])
    anim.key(racClipR, 21, [(0, CARD["y"], "hold"), (rs + 6, CARD["y"], "linear"), (rs + 8, CARD["y"] + 22, "hold")])

    anims = [anim.xml("Celebrate", aid, DUR)]
    layers = [play_layer(aid), mark_layer(ids["marks"], anims)]
    o.extend(anims)
    o.append(state_machine(sm, layers))
    o.append('</Artboard>')
    return o

# ================================================================ BadgeCoin
CW, CH = 340, 372

def build_coin():
    anim = Anim()
    sm, aid, art = nid(), nid(), nid()
    o = [f'<Artboard defaultStateMachineId="{sm}" viewModelId="{VM}" viewModelInstanceId="{VMI}" '
         f'x="900" y="0" width="{CW}" height="{CH}" name="BadgeCoin" id="{art}">']
    o.append(f'<Node x="{CW/2}" y="{R + 10}" name="Medallion">')
    ids = emit_coin(o, anim, animated=False)
    o.append('</Node>')
    # One slow shine across the face as the page opens.
    anim.key(ids["shine"], 13, [(0, -300, "hold"), (10, -300, (0.45, 0, 0.25, 1)), (50, 300, "hold")])
    anims = [anim.xml("Shine", aid, 50)]
    layers = [play_layer(aid), mark_layer(ids["marks"], anims)]
    o.extend(anims)
    o.append(state_machine(sm, layers))
    o.append('</Artboard>')
    return o

out += build_earned()
out += build_coin()
out.append(f'<ImageAsset file="../../assets/brand/raccoon_peek.png" name="raccoon" id="{IMG}"/>')
out.append(f'<ViewModel defaultInstanceId="{VMI}" name="Badge" id="{VM}">')
for name, kind, _ in PROPS:
    out.append(f'<ViewModelProperty{kind} name="{name}" id="{P[name]}"/>')
out.append(f'<ViewModelInstance exports="true" name="Default" id="{VMI}">')
for name, kind, val in PROPS:
    out.append(f'<ViewModelInstance{kind} propertyValue="{val}" viewModelPropertyId="{P[name]}"/>')
out.append('</ViewModelInstance></ViewModel>')
out.append('</Rive>')
open(os.path.join(HERE, "scene.rml"), "w").write("\n".join(out) + "\n")
print("ok", len(out), "lines")

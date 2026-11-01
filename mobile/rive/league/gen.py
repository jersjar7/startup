#!/usr/bin/env python3
"""Generates scene.rml, the league results moment (ADR 0037).

    python3 rive/league/gen.py      # scene.rml
    rive rive/league --once         # assets/rive/league.riv

One artboard, `LeagueMove`, the same card and coin build as the badge
moment (rive/badge/gen.py). Last week's league coin sits on the card and
turns into this week's:

- Up: the coin crouches, jumps, flips one and a half turns and lands as the
  new metal; rings, confetti and glints go out, then a shine crosses it.
- Down: a small lift, one slow half turn, a soft landing and one quiet ring.
  No confetti and nothing that reads as a penalty (no-penalty rule).
- Stay: a small hop, a soft ring, a shine.

Which plays is the view model's `move` (1 up, 2 down, 3 stay; 0 waits).
`from` and `to` pick the letters (0 Copper .. 4 Platinum); every colour comes
from Dart (league_moment.dart), so the metals live in app_colors.dart. The
words are not in here: Flutter sets them under the coin as real text. One
event, `land`, tells the app when to tap the phone.
"""
import math
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))

W, H = 780, 1000
CARD = dict(x=36, y=150, w=708, h=814, r=72)
MC = (390, 380)          # coin centre at rest
R = 150                  # face radius
PLINTH = 27              # how far the rim shows under the face (0.09 of the face, as the website)
EDGE_T = 26              # coin thickness seen during the flip
MARK_SPAN = 154          # the 512 letter square, on the face

SPRING, CHAR, CREAM = "FF63F0A8", "FF2C2C2C", "FFFFF9F0"
SUN, EMBER = "FFF5B731", "FFE8683A"
# Defaults only (Silver to Gold): Dart pushes the real colours.
SILVER = ("FFD8DADC", "FF8E949A", "FF6B7177", "736B7177")
GOLD = ("FFF2C64B", "FFA97F1C", "FF8C6812", "738C6812")

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
PROPS = [("move", "Number", "0"), ("from", "Number", "2"), ("to", "Number", "3"),
         ("fromFace", "Color", SILVER[0]), ("fromRim", "Color", SILVER[1]),
         ("fromInk", "Color", SILVER[2]), ("fromRing", "Color", SILVER[3]),
         ("toFace", "Color", GOLD[0]), ("toRim", "Color", GOLD[1]),
         ("toInk", "Color", GOLD[2]), ("toRing", "Color", GOLD[3]),
         ("card", "Color", CREAM)]
P = {n: nid() for n, _, _ in PROPS}

def bind(prop, key):
    return f'<DataBindContext sourcePathIds="{VM}-{P[prop]}" propertyKey="{key}"/>'

def solid(c, prop=None):
    return f'<SolidColor colorValue="{c}">{bind(prop, 37)}</SolidColor>' if prop else f'<SolidColor colorValue="{c}"/>'
def fill(c, prop=None): return f'<Fill>{solid(c, prop)}</Fill>'

def stops(lst):
    return "".join(f'<GradientStop colorValue="{c}" position="{p}"/>' for c, p in lst)
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

# ================================================================ the letters
def arc(cx, cy, r, a0, a1, n=28, sx=1.0):
    return [(cx + sx * r * math.cos(math.radians(a0 + (a1 - a0) * i / n)),
             cy + r * math.sin(math.radians(a0 + (a1 - a0) * i / n))) for i in range(n + 1)]

STROKE = 50
LETTERS = [
    # Copper
    [arc(256, 256, 125, -45, -315, 40)],
    # Bronze: the stem, then both bowls in one line
    [[(171, 381), (171, 131), (262, 131)] + arc(262, 193.5, 62.5, -90, 90)[1:] +
     [(171, 256), (272, 256)] + arc(272, 318.5, 62.5, -90, 90)[1:] + [(171, 381)]],
    # Silver
    [arc(256, 193.5, 62.5, -15, -270, 30, 1.18) + arc(256, 318.5, 62.5, -90, 165, 30, 1.18)[1:]],
    # Gold
    [arc(256, 256, 125, -40, -360, 40) + [(276, 256)]],
    # Platinum
    [[(181, 381), (181, 131), (271, 131)] + arc(271, 198.5, 67.5, -90, 90)[1:] + [(181, 266)]],
]

def emit_letters(out, ink):
    """Every letter on a face, each in its own hidden group. Returns ids."""
    groups = []
    s = MARK_SPAN / 512
    for lines in LETTERS:
        g = nid()
        groups.append(g)
        out.append(f'<Node x="{f(-256*s)}" y="{f(-256*s)}" scaleX="{f(s)}" scaleY="{f(s)}" opacity="0" name="Letter" id="{g}">')
        for line in lines:
            out.append(f'<Shape name="Line">{pts(line)}'
                       f'<Stroke thickness="{STROKE}" cap="round" join="round">{solid(CHAR, ink)}</Stroke></Shape>')
        out.append('</Node>')
    return groups

def letter_layer(name, prop, groups, out_anims):
    """Shows the letter the number `prop` names, as the badge's Mark layer
    does: Pick waits, each letter holds while the number matches."""
    layer, pick = nid(), nid()
    states, trans_pick = [], []
    for i, g in enumerate(groups):
        aid, sid = nid(), nid()
        a = Anim()
        a.key(g, 18, [(0, 1, "hold")])
        out_anims.append(a.xml(f"{name} {i}", aid, 1))
        cond = lambda op: (f'<TransitionViewModelCondition opValue="{op}"><TransitionPropertyViewModelComparator>'
                           f'<BindablePropertyNumber>{bind(prop, 636)}</BindablePropertyNumber>'
                           f'</TransitionPropertyViewModelComparator><TransitionValueNumberComparator value="{i}"/>'
                           '</TransitionViewModelCondition>')
        trans_pick.append(f'<StateTransition stateToId="{sid}">{cond("equal")}</StateTransition>')
        states.append(f'<AnimationState animationId="{aid}" x="{160 + 120 * i}" y="0" id="{sid}">'
                      f'<StateTransition stateToId="{pick}">{cond("notEqual")}</StateTransition></AnimationState>')
    pick_anim = nid()
    out_anims.append(Anim().xml(f"{name} pick", pick_anim, 1))
    return (f'<StateMachineLayer name="{name}" id="{layer}"><AnyState x="0" y="-200"/><ExitState x="120" y="-200"/>'
            f'<EntryState x="0" y="-100"><StateTransition stateToId="{pick}"/></EntryState>'
            f'<AnimationState animationId="{pick_anim}" x="0" y="0" id="{pick}">{"".join(trans_pick)}</AnimationState>' +
            "".join(states) + '</StateMachineLayer>')

# ================================================================ the coin
def emit_face(out, side):
    """One face at the origin: letters, shine, ring, metal."""
    face, clip, shine = nid(), nid(), nid()
    op = "1" if side == "from" else "0"
    out.append(f'<Node opacity="{op}" name="{side.title()}Face" id="{face}">')
    letters = emit_letters(out, f"{side}Ink")
    out.append(f'<Shape x="-300" y="0" rotation="0.42" name="Shine" id="{shine}">'
               f'<Rectangle width="86" height="460"/>'
               f'<Fill>{lin(-43, 0, 43, 0, [("00FFFFFF", 0), ("80FFFFFF", 0.5), ("00FFFFFF", 1)])}</Fill>'
               f'<ClippingShape sourceId="{clip}"/></Shape>')
    out.append(f'<Shape name="FaceClip" id="{clip}"><Ellipse width="{2*R-6}" height="{2*R-6}"/></Shape>')
    out.append(f'<Shape name="Ring"><Ellipse width="{f(2*R*0.76)}" height="{f(2*R*0.76)}"/>'
               f'<Stroke thickness="{f(2*R*0.035)}">{solid(SILVER[3], side + "Ring")}</Stroke></Shape>')
    out.append(f'<Shape name="Metal"><Ellipse width="{2*R}" height="{2*R}"/>{fill(SILVER[0], side + "Face")}'
               f'<Fill>{rad(-50, -84, 230, -84, [("99FFFFFF", 0), ("00FFFFFF", 1)])}</Fill>'
               f'<Fill>{lin(0, 0, 0, R, [("002C2C2C", 0), ("1F2C2C2C", 1)])}</Fill>'
               f'<Stroke thickness="2.5">{lin(0, -R, 0, 0, [("99FFFFFF", 0), ("00FFFFFF", 1)])}</Stroke></Shape>')
    out.append('</Node>')
    return dict(face=face, shine=shine, letters=letters)

def emit_rim(out, side):
    """The edge seen in the flip and the rim under the face, in one metal."""
    g = nid()
    op = "1" if side == "from" else "0"
    out.append(f'<Node opacity="{op}" name="{side.title()}Rim" id="{g}">')
    cap, band = nid(), nid()
    shade = f'<Fill>{lin(0, -R, 0, R, [("1A2C2C2C", 0), ("402C2C2C", 1)])}</Fill>'
    rim = side + "Rim"
    out.append(f'<Shape name="EdgeBand"><Rectangle width="0" height="{2*R}" id="{band}"/>{fill(SILVER[1], rim)}{shade}</Shape>')
    out.append(f'<Shape name="EdgeCap" id="{cap}"><Ellipse width="{2*R}" height="{2*R}"/>{fill(SILVER[1], rim)}{shade}</Shape>')
    pA, pB, pBand = nid(), nid(), nid()
    out.append(f'<Node y="{PLINTH}" name="Plinth">')
    out.append(f'<Shape name="PlinthA" id="{pA}"><Ellipse width="{2*R}" height="{2*R}"/>{fill(SILVER[1], rim)}</Shape>')
    out.append(f'<Shape name="PlinthB" id="{pB}"><Ellipse width="{2*R}" height="{2*R}"/>{fill(SILVER[1], rim)}</Shape>')
    out.append(f'<Shape name="PlinthBand"><Rectangle width="0" height="{2*R}" id="{pBand}"/>{fill(SILVER[1], rim)}</Shape>')
    out.append('</Node></Node>')
    return dict(group=g, cap=cap, band=band, pA=pA, pB=pB, pBand=pBand)

# ================================================================ the artboard
out = ['<Rive version="1" kind="fragment">']
sm, art = nid(), nid()
o = [f'<Artboard defaultStateMachineId="{sm}" viewModelId="{VM}" viewModelInstanceId="{VMI}" '
     f'width="{W}" height="{H}" name="LeagueMove" id="{art}">']
land_evt = nid()
o.append(f'<Event name="land" id="{land_evt}"/>')

UP_LAND, DOWN_LAND, STAY_LAND = 72, 64, 44
UP_DUR, DOWN_DUR, STAY_DUR = 200, 150, 130

# ---- confetti, promotion only (front pieces declared first = on top)
random.seed(11)
cols = [SUN, EMBER, SPRING, SUN, SPRING]
pieces = []
for i in range(34):
    front = i % 3 == 0
    capsule = random.random() < 0.45
    w_, h_ = (11, 31) if capsule else (18, 25)
    sc = random.uniform(0.85, 1.15) * (1.08 if front else 0.86)
    pieces.append(dict(front=front, ang=math.radians(random.uniform(-166, -14)),
                       spd=random.uniform(9.5, 19) * (1.06 if front else 0.94),
                       start=UP_LAND + random.randint(0, 4), capsule=capsule,
                       w=w_ * sc, h=h_ * sc, col=random.choice(cols),
                       spin=random.uniform(0.07, 0.24) * random.choice([-1, 1]),
                       rot0=random.uniform(0, math.pi), tumble=random.uniform(0.12, 0.3),
                       ph=random.uniform(0, 6.28), sway=random.uniform(0.1, 0.32),
                       fade=random.randint(112, 150)))

up = Anim()
down = Anim()
stay = Anim()

def sim_piece(p):
    xs = {}
    r0 = R * (0.98 if p["front"] else 0.7)
    x = MC[0] + math.cos(p["ang"]) * r0
    y = MC[1] + 20 + math.sin(p["ang"]) * r0 * 0.8
    vx, vy = math.cos(p["ang"]) * p["spd"] * 0.82, math.sin(p["ang"]) * p["spd"]
    rot, tum, spin = p["rot0"], p["ph"], p["spin"]
    for fr in range(p["start"], min(UP_DUR, p["fade"] + 22) + 1):
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
        up.key(node, 13, [(p["start"] - 1, sim[frs[0]][0], "hold")] + [(i, sim[i][0], "linear") for i in sel])
        up.key(node, 14, [(p["start"] - 1, sim[frs[0]][1], "hold")] + [(i, sim[i][1], "linear") for i in sel])
        up.key(node, 15, [(i, sim[i][2], "linear") for i in sel])
        up.key(shp, 17, [(i, sim[i][3], "linear") for i in sel])
        up.key(node, 18, [(0, 0, "hold"), (p["start"], 1, "hold"),
                          (p["fade"], 1, "inout"), (min(UP_DUR, p["fade"] + 22), 0, "hold")])

confetti(True)

# ---- glints, promotion only
for gx, gy, gs, gf in [(-178, -118, 1.0, 96), (172, -60, 0.8, 102), (-150, 96, 0.65, 108), (196, 70, 0.55, 114)]:
    g = nid()
    o.append(f'<Shape x="{MC[0]+gx}" y="{MC[1]+gy}" scaleX="0" scaleY="0" name="Glint" id="{g}">'
             f'<Star width="{f(34*gs)}" height="{f(34*gs)}" points="4" innerRadius="0.28" cornerRadius="1.5"/>{fill(SUN)}</Shape>')
    for prop in (16, 17):
        up.key(g, prop, [(0, 0, "hold"), (gf, 0, "back"), (gf + 10, 1, "inout"), (gf + 26, 0, "hold")])
    up.key(g, 15, [(gf, -0.6, "out"), (gf + 26, 0.5, "hold")])

# ---- the coin: Medallion > Lift > Squash (about the rim's bottom) > Arrive
med, liftN, squashN, arriveN = nid(), nid(), nid(), nid()
o.append(f'<Node x="{MC[0]}" y="{MC[1]}" opacity="0" name="Medallion" id="{med}">')
o.append(f'<Node name="Lift" id="{liftN}">')
sq = R + PLINTH
o.append(f'<Node y="{sq}" name="Squash" id="{squashN}">')
o.append(f'<Node y="{-sq}" name="Arrive" id="{arriveN}">')
front = emit_face(o, "from")
back = emit_face(o, "to")
rim_to = emit_rim(o, "to")
rim_from = emit_rim(o, "from")
o.append('</Node></Node></Node></Node>')

# ---- rings, glow, shadow
rings = []
for delay, opac, th in [(0, 0.32, 6), (7, 0.17, 3.5)]:
    rg, st = nid(), nid()
    rings.append((rg, st, delay, opac, th))
    o.append(f'<Shape x="{MC[0]}" y="{MC[1]+6}" opacity="0" name="Ring" id="{rg}"><Ellipse width="{2*R+12}" height="{2*R+12}"/>'
             f'<Stroke thickness="{th}" id="{st}">{solid(GOLD[1], "toRim")}</Stroke></Shape>')
glow = nid()
o.append(f'<Shape x="{MC[0]}" y="{MC[1]+4}" opacity="0" name="Glow" id="{glow}"><Ellipse width="600" height="600"/>'
         f'<Fill>{rad(0, 0, 300, 0, [("55F5B731", 0), ("26F5B731", 0.45), ("00FFF9F0", 1)])}</Fill></Shape>')
shadow = nid()
o.append(f'<Shape x="{MC[0]}" y="{MC[1] + R + PLINTH + 2}" opacity="0" name="Shadow" id="{shadow}"><Ellipse width="330" height="52"/>'
         f'<Fill>{rad(0, 0, 165, 0, [("552C2C2C", 0), ("2A2C2C2C", 0.5), ("002C2C2C", 1)])}</Fill></Shape>')

confetti(False)

o.append(f'<Shape x="{CARD["x"]}" y="{CARD["y"]}" name="Card"><Rectangle width="{CARD["w"]}" height="{CARD["h"]}" '
         f'originX="0" originY="0" cornerRadiusTL="{CARD["r"]}"/>{fill(CREAM, "card")}</Shape>')

# ================================================================ motion
def flip_keys(a, theta, f0, f1):
    """The coin turning by theta(frame): faces narrow to the edge and the
    face that shows is whichever is towards us. The rim crossfades from the
    old metal to the new across the turn."""
    c_ = lambda i: math.cos(theta(i))
    s_ = lambda i: math.sin(theta(i))
    face_x = lambda i: s_(i) * EDGE_T / 2
    back_x = lambda i: -s_(i) * EDGE_T / 2
    width_k = lambda i: max(abs(c_(i)), 0.001)
    for g in (front["face"], back["face"]):
        a.bake(g, 13, face_x, 0, f1)
        a.bake(g, 16, width_k, 0, f1)
    a.key(front["face"], 18, [(i, 1 if c_(i) > 0 else 0, "hold") for i in range(0, f1 + 1)])
    a.key(back["face"], 18, [(i, 0 if c_(i) > 0 else 1, "hold") for i in range(0, f1 + 1)])
    for rim in (rim_from, rim_to):
        a.bake(rim["cap"], 13, back_x, 0, f1)
        a.bake(rim["cap"], 16, width_k, 0, f1)
        a.bake(rim["band"], 20, lambda i: abs(s_(i)) * EDGE_T, 0, f1)
        a.bake(rim["pA"], 13, face_x, 0, f1)
        a.bake(rim["pB"], 13, back_x, 0, f1)
        for p in (rim["pA"], rim["pB"]):
            a.bake(p, 16, width_k, 0, f1)
        a.bake(rim["pBand"], 20, lambda i: abs(s_(i)) * EDGE_T, 0, f1)
    a.key(rim_to["group"], 18, [(0, 0, "hold"), (f0, 0, "inout"), (f1, 1, "hold")])
    a.key(rim_from["group"], 18, [(0, 1, "hold"), (f0, 1, "inout"), (f1, 0, "hold")])

def arrive(a):
    a.key(med, 18, [(0, 0, "linear"), (8, 1, "hold")])
    for prop in (16, 17):
        a.key(arriveN, prop, [(0, 0.9, (0.2, 0.9, 0.3, 1.1)), (14, 1, "hold")])

def settle(a, land, amp, fall=8.5, period=15, f1=None):
    """Squash about the rim's bottom as the coin lands, ringing out."""
    def sq(i):
        if i < land: return (1, 1)
        t = i - land
        k = amp * math.exp(-t / fall) * math.cos(2 * math.pi * t / period)
        return (1 + 0.75 * k, 1 - k)
    end = f1 or land + 44
    a.bake(squashN, 16, lambda i: sq(i)[0], land, end)
    a.bake(squashN, 17, lambda i: sq(i)[1], land, end)

def shadow_keys(a, lift_fn, peak, end):
    def k(i):
        h = -lift_fn(i)
        return 1 - 0.45 * h / peak
    a.bake(shadow, 16, k, 0, end, 2)
    a.bake(shadow, 17, lambda i: k(i) * (1 - 0.1 * (-lift_fn(i)) / peak), 0, end, 2)
    a.bake(shadow, 18, lambda i: clamp(i / 8, 0, 1) * (1 - 0.7 * (-lift_fn(i)) / peak), 0, end, 2)

def ring_keys(a, land, ring_list):
    for rg, st, delay, opac, th in ring_list:
        s0 = land + delay
        a.key(rg, 18, [(0, 0, "hold"), (s0, opac, "out"), (s0 + 42, 0, "hold")])
        for prop in (16, 17):
            a.key(rg, prop, [(0, 1, "hold"), (s0, 1, "outq"), (s0 + 42, 1.75, "hold")])
        a.key(st, 47, [(0, th, "hold"), (s0, th, "out"), (s0 + 42, 1, "hold")])

def shine(a, face, at):
    a.key(face["shine"], 13, [(0, -300, "hold"), (at, -300, (0.45, 0, 0.25, 1)), (at + 32, 300, "hold")])

# ---- up: crouch, jump, a turn and a half, land as the new metal
LAUNCH, PEAK_F, PEAK_H = 22, 46, 150
def up_lift(i):
    if i <= LAUNCH: return 0
    if i <= PEAK_F:
        t = (i - LAUNCH) / (PEAK_F - LAUNCH)
        return -PEAK_H * (1 - (1 - t) ** 2)
    if i <= UP_LAND:
        t = (i - PEAK_F) / (UP_LAND - PEAK_F)
        return -PEAK_H * (1 - t * t)
    t = i - UP_LAND
    if t <= 14:
        u = t / 14
        return -14 * 4 * u * (1 - u)
    return 0
def up_theta(i):
    if i <= LAUNCH: return 0.0
    if i >= UP_LAND:
        t = i - UP_LAND
        return 3 * math.pi - 0.36 * math.exp(-t / 10) * math.sin(2 * math.pi * t / 16)
    t = (i - LAUNCH) / (UP_LAND - LAUNCH)
    return 3 * math.pi * ease_val(t, 0.3, 0.1, 0.4, 1)

arrive(up)
up.bake(liftN, 14, up_lift, 0, UP_LAND + 16)
# The crouch before the jump, then the landing.
up.key(squashN, 16, [(0, 1, "hold"), (10, 1, "inout"), (LAUNCH - 2, 1.06, (0.2, 0, 0.2, 1.4)), (LAUNCH + 6, 0.95, "inout"), (PEAK_F, 1, "hold")])
up.key(squashN, 17, [(0, 1, "hold"), (10, 1, "inout"), (LAUNCH - 2, 0.9, (0.2, 0, 0.2, 1.4)), (LAUNCH + 6, 1.08, "inout"), (PEAK_F, 1, "hold")])
settle(up, UP_LAND, 0.11)
flip_keys(up, up_theta, LAUNCH, UP_LAND + 40)
shadow_keys(up, up_lift, PEAK_H, UP_LAND + 30)
ring_keys(up, UP_LAND, rings)
up.key(glow, 18, [(0, 0, "hold"), (UP_LAND, 0, "out"), (UP_LAND + 10, 1, "inout"), (UP_LAND + 50, 0.55, "hold")])
for prop in (16, 17):
    up.key(glow, prop, [(0, 0.7, "hold"), (UP_LAND, 0.7, "outq"), (UP_LAND + 30, 1.05, "inout"), (UP_LAND + 60, 1, "hold")])
shine(up, back, 124)
up.event(land_evt, UP_LAND)

# ---- down: a small lift, one slow half turn, a soft landing
D_LIFT0, D_PEAK, D_H = 14, 32, 36
def down_lift(i):
    if i <= D_LIFT0: return 0
    if i <= D_PEAK:
        t = (i - D_LIFT0) / (D_PEAK - D_LIFT0)
        return -D_H * ease_val(t, 0, 0, 0.58, 1)
    if i <= DOWN_LAND:
        t = (i - D_PEAK) / (DOWN_LAND - D_PEAK)
        return -D_H * (1 - ease_val(t, 0.42, 0, 0.9, 1))
    return 0
def down_theta(i):
    if i <= 20: return 0.0
    if i >= DOWN_LAND:
        t = i - DOWN_LAND
        return math.pi - 0.16 * math.exp(-t / 9) * math.sin(2 * math.pi * t / 18)
    return math.pi * ease_val((i - 20) / (DOWN_LAND - 20), 0.42, 0, 0.58, 1)

arrive(down)
down.bake(liftN, 14, down_lift, 0, DOWN_LAND + 2)
settle(down, DOWN_LAND, 0.045, fall=7, period=16)
flip_keys(down, down_theta, 20, DOWN_LAND + 30)
shadow_keys(down, down_lift, D_H * 3, DOWN_LAND + 10)
ring_keys(down, DOWN_LAND, [rings[0][:3] + (0.16, rings[0][4])])
down.event(land_evt, DOWN_LAND)

# ---- stay: a small hop, a soft ring, a shine
S_UP, S_PEAK, S_H = 12, 28, 40
def stay_lift(i):
    if i <= S_UP: return 0
    if i <= S_PEAK:
        t = (i - S_UP) / (S_PEAK - S_UP)
        return -S_H * (1 - (1 - t) ** 2)
    if i <= STAY_LAND:
        t = (i - S_PEAK) / (STAY_LAND - S_PEAK)
        return -S_H * (1 - t * t)
    return 0

arrive(stay)
stay.bake(liftN, 14, stay_lift, 0, STAY_LAND + 2)
settle(stay, STAY_LAND, 0.07)
shadow_keys(stay, stay_lift, S_H * 2.5, STAY_LAND + 10)
ring_keys(stay, STAY_LAND, [rings[0][:3] + (0.22, rings[0][4])])
shine(stay, front, STAY_LAND + 18)
stay.event(land_evt, STAY_LAND)

# ================================================================ state machine
anims = []
wait_id, up_id, down_id, stay_id = nid(), nid(), nid(), nid()
anims.append(Anim().xml("Wait", wait_id, 1))
anims.append(up.xml("Up", up_id, UP_DUR))
anims.append(down.xml("Down", down_id, DOWN_DUR))
anims.append(stay.xml("Stay", stay_id, STAY_DUR))

def move_is(v):
    return (f'<TransitionViewModelCondition opValue="equal"><TransitionPropertyViewModelComparator>'
            f'<BindablePropertyNumber>{bind("move", 636)}</BindablePropertyNumber>'
            f'</TransitionPropertyViewModelComparator><TransitionValueNumberComparator value="{v}"/>'
            '</TransitionViewModelCondition>')

play, s_wait, s_up, s_down, s_stay = nid(), nid(), nid(), nid(), nid()
play_layer = (f'<StateMachineLayer name="Play" id="{play}"><AnyState x="320" y="-100"/><ExitState x="440" y="-100"/>'
              f'<EntryState x="0" y="-100"><StateTransition stateToId="{s_wait}"/></EntryState>'
              f'<AnimationState animationId="{wait_id}" x="0" y="0" id="{s_wait}">'
              f'<StateTransition stateToId="{s_up}">{move_is(1)}</StateTransition>'
              f'<StateTransition stateToId="{s_down}">{move_is(2)}</StateTransition>'
              f'<StateTransition stateToId="{s_stay}">{move_is(3)}</StateTransition></AnimationState>'
              f'<AnimationState animationId="{up_id}" x="200" y="-80" id="{s_up}"/>'
              f'<AnimationState animationId="{down_id}" x="200" y="0" id="{s_down}"/>'
              f'<AnimationState animationId="{stay_id}" x="200" y="80" id="{s_stay}"/></StateMachineLayer>')
layers = [play_layer,
          letter_layer("From", "from", front["letters"], anims),
          letter_layer("To", "to", back["letters"], anims)]
o.extend(anims)
o.append(f'<StateMachine name="Main" id="{sm}">{"".join(layers)}</StateMachine>')
o.append('</Artboard>')
out += o

out.append(f'<ViewModel defaultInstanceId="{VMI}" name="League" id="{VM}">')
for name, kind, _ in PROPS:
    out.append(f'<ViewModelProperty{kind} name="{name}" id="{P[name]}"/>')
out.append(f'<ViewModelInstance exports="true" name="Default" id="{VMI}">')
for name, kind, val in PROPS:
    out.append(f'<ViewModelInstance{kind} propertyValue="{val}" viewModelPropertyId="{P[name]}"/>')
out.append('</ViewModelInstance></ViewModel>')
out.append('</Rive>')
open(os.path.join(HERE, "scene.rml"), "w").write("\n".join(out) + "\n")
print("ok", len(out), "lines")

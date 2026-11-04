"""Builds the reminders-ask mockups (HTML) and renders them at 3x.

    python3 build.py          # writes html/ and png/

Values come from ../tokens.json and lib/core/theme/app_colors.dart (night).
"""
import pathlib
import subprocess

HERE = pathlib.Path(__file__).parent
HTML = HERE / "html"
PNG = HERE / "png"
ROAD = (HERE.parent / "road" / "png" / "R02-phone-mid-day.png").resolve()
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

DAY = dict(
    fog="#E3DFD7", ink="#2C2C2C", cream="#FFF9F0", spring="#63F0A8",
    springField="#63F0A8", butter="#F9D28A", muted="#6B6358",
    pillFill="#2C2C2C", pillLabel="#FFF9F0", onAccent="#2C2C2C",
    roundFill="#2C2C2C", roundIcon="#FFF9F0", sheet="#FFF9F0",
    scrim="rgba(44,44,44,0.65)", grabber="rgba(44,44,44,0.25)",
    barHit="#2C2C2C", barMiss="#FFF9F0", forest="#2D7A5F",
)
NIGHT = dict(
    fog="#1B1A18", ink="#F2ECE2", cream="#272522", spring="#63F0A8",
    springField="#1C4532", butter="#2B2418", muted="#A89F93",
    pillFill="#F2ECE2", pillLabel="#272522", onAccent="#2C2C2C",
    roundFill="#F2ECE2", roundIcon="#272522", sheet="#2E2B27",
    scrim="rgba(0,0,0,0.78)", grabber="rgba(242,236,226,0.25)",
    barHit="#F2ECE2", barMiss="#272522", forest="#5FD69A",
)

DISPLAY = "'DM Sans', sans-serif"
MONO = "'JetBrains Mono', monospace"

HEAD = """<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>{title}</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,500;9..40,600;9..40,700;9..40,800&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@500;600;700&display=swap">
<style>
html,body{{margin:0;padding:0}}
body{{font-family:'Inter',sans-serif;-webkit-font-smoothing:antialiased;background:{fog}}}
.eb{{font-family:{mono};font-size:12px;font-weight:600;letter-spacing:0.06em;text-transform:uppercase}}
</style></head><body>
<div style="width:{w}px;height:{h}px;box-sizing:border-box;position:relative;overflow:hidden;background:{fog};color:{ink}">
"""
TAIL = "</div></body></html>\n"

ARROW = ('<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
         'stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
         '<path d="M5 12h14"/><path d="M13 6l6 6-6 6"/></svg>')
CLOSE = ('<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
         'stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12"/><path d="M18 6L6 18"/></svg>')


def close_btn(c):
    return (f'<div style="display:flex;align-items:center;justify-content:center;width:48px;height:48px;'
            f'margin-left:-4px;border-radius:24px;background:{c["roundFill"]};color:{c["roundIcon"]}">{CLOSE}</div>')


def pill(c, label, max_w=None):
    mw = f"max-width:{max_w}px;" if max_w else ""
    return (f'<div style="flex:1;{mw}display:flex;align-items:center;justify-content:space-between;height:72px;'
            f'box-sizing:border-box;padding:0 8px 0 28px;border-radius:36px;background:{c["pillFill"]};color:{c["pillLabel"]}">'
            f'<span style="font-family:{DISPLAY};font-weight:700;font-size:22px;letter-spacing:-0.02em">{label}</span>'
            f'<span style="display:flex;align-items:center;justify-content:center;width:56px;height:56px;border-radius:28px;'
            f'background:{c["spring"]};color:{c["onAccent"]}">{ARROW}</span></div>')


def text_action(c, label):
    return (f'<span style="display:flex;align-items:center;height:48px;font-size:15px;font-weight:600;color:{c["ink"]};'
            f'text-decoration:underline;text-underline-offset:4px;white-space:nowrap">{label}</span>')


def bars(c, h, gap):
    rows = [[1, 1, 1, 1, 1, 1], [1, 0, 1, 1, 0, 1], [1, 1, 1, 1, 1, 1]]
    out = f'<div style="display:flex;flex-direction:column;gap:{gap}px">'
    for r in rows:
        out += f'<div style="display:flex;gap:{gap + 4}px">'
        for v in r:
            out += (f'<span style="flex:1;height:{h}px;border-radius:{h}px;'
                    f'background:{c["barHit"] if v else c["barMiss"]}"></span>')
        out += '</div>'
    return out + '</div>'


LINE = "On the first try. You missed one in Statics and one in Surveying, and they all came back."

# The copy. Never a time of day (owner, 2026-11-04): the plan's hours can move.
M1_TITLE = "Don't let day 1 be your only day."
M1_BODY = ("Most streaks end on a busy day, not a hard one. "
           "We can remind you, so yours does not.")
M2_TITLE = "One lesson down.<br>Don't stop at one."
M2_BODY = ("We can remind you to keep going. A few minutes a day beats "
           "a night of cramming.")
ON_TITLE = "Reminders on."
ON_BODY = "We will nudge you so the streak keeps going."


def hero(c, big=False):
    pad = 36 if big else 24
    num = 170 if big else 112
    of = 36 if big else 28
    gap = "flex:1" if big else ""
    sp = (lambda px: f'<div style="flex:1;min-height:{px}px"></div>') if big else (
        lambda px: f'<div style="height:{px}px"></div>')
    return (f'<div style="{gap};display:flex;flex-direction:column;box-sizing:border-box;padding:{pad}px;'
            f'border-radius:{40 if big else 36}px;background:{c["springField"]};color:{c["ink"]}">'
            f'<div style="display:flex;justify-content:space-between"><span class="eb">Today\'s Daily</span>'
            f'<span class="eb">Done</span></div>'
            f'{sp(26)}'
            f'<div style="display:flex;align-items:baseline;gap:8px"><span style="font-family:{DISPLAY};font-weight:800;'
            f'font-size:{num}px;line-height:0.8;letter-spacing:-0.07em">16</span>'
            f'<span style="font-family:{DISPLAY};font-weight:700;font-size:{of}px;letter-spacing:-0.03em">of 18</span></div>'
            f'{sp(22)}{bars(c, 24 if big else 14, 12 if big else 5)}{sp(18)}'
            f'<div style="font-size:{18 if big else 15}px;font-weight:500;line-height:1.4">{LINE}</div></div>')


def half(c, fill, eyebrow, value, unit="", big=False):
    return (f'<div style="flex:1;height:{180 if big else 132}px;box-sizing:border-box;padding:{28 if big else 18}px;'
            f'border-radius:32px;background:{fill};display:flex;flex-direction:column;justify-content:space-between">'
            f'<span class="eb">{eyebrow}</span><div style="display:flex;align-items:baseline;gap:6px">'
            f'<span style="font-family:{DISPLAY};font-weight:800;font-size:{84 if big else 52}px;line-height:0.82;'
            f'letter-spacing:-0.06em">{value}</span>'
            f'<span style="font-size:{20 if big else 14}px;font-weight:600">{unit}</span></div></div>')


def done_phone(c):
    """The Daily done screen as it is today, behind the sheet."""
    return (f'<div style="position:absolute;inset:0;box-sizing:border-box;padding:56px 24px 34px;display:flex;flex-direction:column">'
            f'<div>{close_btn(c)}</div><div style="height:22px"></div>{hero(c)}<div style="height:10px"></div>'
            f'<div style="display:flex;gap:10px">{half(c, c["cream"], "Time", "2:41")}'
            f'{half(c, c["butter"], "Streak", "1", "day")}</div><div style="flex:1"></div>'
            f'<div style="display:flex;align-items:center;gap:18px">{text_action(c, "Share")}{pill(c, "How others did")}</div></div>')


def done_tablet(c):
    return (f'<div style="position:absolute;inset:0;box-sizing:border-box;padding:36px 48px 32px;display:flex;flex-direction:column">'
            f'<div>{close_btn(c)}</div><div style="height:36px"></div><div style="flex:1;display:flex;gap:36px;min-height:0">'
            f'<div style="flex:3;display:flex;flex-direction:column;min-width:0">{hero(c, big=True)}</div>'
            f'<div style="flex:2;display:flex;flex-direction:column;gap:12px;min-width:0">'
            f'<div style="display:flex">{half(c, c["cream"], "Time", "2:41", big=True)}</div>'
            f'<div style="display:flex">{half(c, c["butter"], "Streak", "1", "day", big=True)}</div>'
            f'<div style="flex:1"></div><div style="display:flex;align-items:center;gap:24px">'
            f'{text_action(c, "Share")}{pill(c, "How others did")}</div></div></div></div>')


def streak_block(c, big=False):
    """The streak as the Daily draws it: butter, eyebrow, the figure."""
    return (f'<div style="box-sizing:border-box;padding:{24 if big else 20}px {28 if big else 22}px;border-radius:32px;'
            f'background:{c["butter"]};display:flex;align-items:flex-end;justify-content:space-between;'
            f'height:{132 if big else 116}px">'
            f'<div style="display:flex;align-items:baseline;gap:8px">'
            f'<span style="font-family:{DISPLAY};font-weight:800;font-size:{84 if big else 76}px;line-height:0.8;letter-spacing:-0.06em">1</span>'
            f'<span style="font-size:{19 if big else 17}px;font-weight:600">day streak</span></div>'
            f'<span class="eb" style="align-self:flex-start">Streak</span></div>')


def sheet(c, top, title, body, row, big=False, width=None, min_h=None):
    pos = (f'left:50%;transform:translateX(-50%);width:{width}px;' if width else 'left:0;right:0;')
    mh = f'min-height:{min_h}px;' if min_h else ''
    padx = 32 if big else 24
    return (f'<div style="position:absolute;{pos}bottom:0;background:{c["sheet"]};border-radius:40px 40px 0 0;'
            f'box-sizing:border-box;{mh}display:flex;flex-direction:column;padding:12px {padx}px 34px">'
            f'<div style="width:44px;height:5px;border-radius:3px;background:{c["grabber"]};margin:0 auto 26px"></div>'
            f'{top}'
            f'<div style="font-family:{DISPLAY};font-weight:800;font-size:{42 if big else 38}px;line-height:1.0;'
            f'letter-spacing:-0.045em;margin-top:22px;color:{c["ink"]};text-wrap:balance">{title}</div>'
            f'<div style="font-size:{17 if big else 16}px;line-height:1.45;color:{c["muted"]};margin-top:14px">{body}</div>'
            f'<div style="display:flex;align-items:center;gap:18px;margin-top:auto;padding-top:32px">{row}</div></div>')


def scrim(c):
    return f'<div style="position:absolute;inset:0;background:{c["scrim"]}"></div>'


def ask_row(c, w=None):
    return text_action(c, "Not now") + pill(c, "Remind me", w)


def phone_m1(c, state):
    if state == "ask":
        sh = sheet(c, streak_block(c), M1_TITLE, M1_BODY, ask_row(c))
    else:
        sh = sheet(c, streak_block(c), ON_TITLE, ON_BODY, '<div style="flex:1"></div>' + pill(c, "Done", 200))
    return done_phone(c) + scrim(c) + sh


def phone_m2(c):
    road = (f'<img src="file://{ROAD}" style="position:absolute;left:0;top:-8px;width:390px;height:844px">'
            # The map after the FIRST lesson: one cleared. R02 shows two, so the chip is redrawn.
            f'<div style="position:absolute;left:24px;top:188px;height:34px;padding:0 14px;border-radius:17px;'
            f'background:#2C2C2C;color:#63F0A8;display:flex;align-items:center;font-family:{MONO};font-size:13px;'
            f'font-weight:600">1 of 16 cleared</div>')
    top = f'<span class="eb" style="color:{c["forest"]}">Straight Lines &amp; Quadratics &middot; cleared</span>'
    return road + scrim(c) + sheet(c, top, M2_TITLE, M2_BODY, ask_row(c), min_h=424)


def tablet_m1(c):
    return done_tablet(c) + scrim(c) + sheet(c, streak_block(c, big=True), M1_TITLE, M1_BODY,
                                             '<div style="flex:1"></div>' + ask_row(c, 340),
                                             big=True, width=640)


SCREENS = [
    ("A1-daily-done-ask-day", "Reminders ask, Daily done", 390, 844, DAY, lambda: phone_m1(DAY, "ask")),
    ("A1n-daily-done-ask-night", "Reminders ask, Daily done, night", 390, 844, NIGHT, lambda: phone_m1(NIGHT, "ask")),
    ("A2-reminders-on-day", "Reminders on", 390, 844, DAY, lambda: phone_m1(DAY, "on")),
    ("A3-first-lesson-ask-day", "Reminders ask, first lesson", 390, 844, DAY, lambda: phone_m2(DAY)),
    ("T-A1-daily-done-ask-landscape", "Reminders ask, tablet", 1180, 820, DAY, lambda: tablet_m1(DAY)),
]


def main():
    HTML.mkdir(exist_ok=True)
    PNG.mkdir(exist_ok=True)
    for name, title, w, h, c, body in SCREENS:
        page = HEAD.format(title=title, w=w, h=h, mono=MONO, **c) + body() + TAIL
        f = HTML / f"{name}.html"
        f.write_text(page)
        subprocess.run([CHROME, "--headless=new", "--hide-scrollbars", "--disable-gpu",
                        "--allow-file-access-from-files", f"--window-size={w},{h}",
                        "--force-device-scale-factor=3", "--virtual-time-budget=5000",
                        f"--screenshot={PNG / (name + '.png')}", f"file://{f.resolve()}"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        print("rendered", name)


if __name__ == "__main__":
    main()

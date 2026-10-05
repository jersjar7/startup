"""Loads the App Store listing: screenshots, copy, category, build.

Does not submit. Submission, App Privacy, the age rating questionnaire and
export compliance are left to the owner.
"""
import hashlib
import pathlib
import sys
import urllib.request

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from asc import call, APP  # noqa: E402

SHOTS = pathlib.Path(__file__).parent / 'out'
DISPLAY = 'APP_IPHONE_67'  # what 1320 x 2868 is called in the API

SUBTITLE = 'Free FE Civil exam practice'

PROMO = ('Fifteen chapters, 135 lessons and 2,269 rounds of FE Civil practice, built around '
         'the figures the exam actually uses. All of it free, nothing locked.')

KEYWORDS = ('FE exam,civil engineering,NCEES,EIT,engineer in training,'
            'fundamentals,exam prep,practice,PE,study')

DESCRIPTION = """FE for Raccoons is a study app for the Fundamentals of Engineering Civil exam, and all of it is free.

Fifteen chapters. 135 lessons. 2,269 rounds. Nothing is locked and nothing asks for a card.

ONE CONCEPT AT A TIME
Each lesson is a short run of rounds. A round puts a figure in front of you, asks one question about it, and tells you straight away whether you were right and why. Two minutes waiting for a bus is a real session.

EVERY IDEA STARTS WITH A PICTURE
Behind every concept there is a sheet that draws the idea before it names it. You see what is going on first, then the words for it, then the formula. There are 370 of them, written so that someone meeting the topic for the first time can follow.

BUILT FOR CIVIL
The drawings are the ones the exam actually uses. Mohr's circle, flow nets under a sheet pile wall, shear and moment diagrams, orifice plates, phase diagrams, hydraulic jumps, stress blocks. They were drawn for this exam rather than borrowed from a textbook.

SEE WHERE THE EFFORT PAYS
Every chapter sits on a field: how far along you are against how much of the exam it is worth. One look tells you which chapter is costing you the most, so you always know what to open next.

A FEW MINUTES COUNTS AS A DAY
Open the app, finish one round, and the day is on your calendar. The count only ever goes up.

THE SAME ACCOUNT AS THE WEBSITE
Sign in with the account you use at fe4raccoons.com. What you do here warms up the work you do there, and the website is where concept mastery is earned at the desk. This app tells you that plainly rather than inflating a number.

Completely free. No subscription, no trial, no card."""

SUPPORT_URL = 'https://fe4raccoons.com'
MARKETING_URL = 'https://fe4raccoons.com'
PRIVACY_URL = 'https://fe4raccoons.com/privacy'

LIMITS = {'subtitle': 30, 'promotionalText': 170, 'keywords': 100, 'description': 4000}


def check_lengths():
    for name, text in (('subtitle', SUBTITLE), ('promotionalText', PROMO),
                       ('keywords', KEYWORDS), ('description', DESCRIPTION)):
        n = len(text)
        print(f"  {name}: {n}/{LIMITS[name]}")
        if n > LIMITS[name]:
            sys.exit(f"{name} is {n - LIMITS[name]} characters over Apple's limit")
        if '—' in text or '–' in text:
            sys.exit(f"{name} contains a dash character that should not be there")


def ok(code, body, what):
    if code not in (200, 201, 204):
        sys.exit(f"{what} failed [{code}]: {body}")
    return body


def main():
    print("Copy lengths against Apple's limits")
    check_lengths()

    _, v = call('GET', f"apps/{APP}/appStoreVersions?limit=1")
    vid = v['data'][0]['id']
    _, loc = call('GET', f"appStoreVersions/{vid}/appStoreVersionLocalizations")
    lid = loc['data'][0]['id']
    _, infos = call('GET', f"apps/{APP}/appInfos")
    info_id = infos['data'][0]['id']
    _, ilocs = call('GET', f"appInfos/{info_id}/appInfoLocalizations")
    iloc_id = ilocs['data'][0]['id']
    print(f"\nversion {v['data'][0]['attributes']['versionString']} ({vid})")

    # 1. the eight screenshots
    _, sets = call('GET', f"appStoreVersionLocalizations/{lid}/appScreenshotSets")
    sid = next((s['id'] for s in sets['data']
                if s['attributes']['screenshotDisplayType'] == DISPLAY), None)
    if sid is None:
        code, body = call('POST', 'appScreenshotSets', {
            "data": {"type": "appScreenshotSets",
                     "attributes": {"screenshotDisplayType": DISPLAY},
                     "relationships": {"appStoreVersionLocalization": {
                         "data": {"type": "appStoreVersionLocalizations", "id": lid}}}}})
        sid = ok(code, body, 'create screenshot set')['data']['id']
        print(f"screenshot set created ({DISPLAY})")
    else:
        print(f"screenshot set already there ({DISPLAY}); replacing its contents")
        _, have = call('GET', f"appScreenshotSets/{sid}/appScreenshots?limit=50")
        for s in have['data']:
            call('DELETE', f"appScreenshots/{s['id']}")

    ids = []
    for png in sorted(SHOTS.glob('*.png')):
        data = png.read_bytes()
        code, body = call('POST', 'appScreenshots', {
            "data": {"type": "appScreenshots",
                     "attributes": {"fileSize": len(data), "fileName": png.name},
                     "relationships": {"appScreenshotSet": {
                         "data": {"type": "appScreenshotSets", "id": sid}}}}})
        shot = ok(code, body, f'reserve {png.name}')['data']
        for op in shot['attributes']['uploadOperations']:
            chunk = data[op['offset']:op['offset'] + op['length']]
            req = urllib.request.Request(op['url'], data=chunk, method=op['method'])
            for h in op['requestHeaders']:
                req.add_header(h['name'], h['value'])
            urllib.request.urlopen(req).read()
        code, body = call('PATCH', f"appScreenshots/{shot['id']}", {
            "data": {"type": "appScreenshots", "id": shot['id'],
                     "attributes": {"uploaded": True,
                                    "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
        ok(code, body, f'commit {png.name}')
        ids.append(shot['id'])
        print(f"  uploaded {png.name} ({len(data) // 1024} KB)")

    code, body = call('PATCH', f"appScreenshotSets/{sid}/relationships/appScreenshots",
                      {"data": [{"type": "appScreenshots", "id": i} for i in ids]})
    ok(code, body, 'set screenshot order')
    print(f"  order locked, {len(ids)} screenshots")

    # 2. the copy on the version
    code, body = call('PATCH', f"appStoreVersionLocalizations/{lid}", {
        "data": {"type": "appStoreVersionLocalizations", "id": lid,
                 "attributes": {"description": DESCRIPTION, "keywords": KEYWORDS,
                                "promotionalText": PROMO, "supportUrl": SUPPORT_URL,
                                "marketingUrl": MARKETING_URL}}})
    ok(code, body, 'version copy')
    print("\ndescription, keywords, promotional text and URLs written")

    # 3. subtitle and privacy policy live on the app info, not the version
    code, body = call('PATCH', f"appInfoLocalizations/{iloc_id}", {
        "data": {"type": "appInfoLocalizations", "id": iloc_id,
                 "attributes": {"subtitle": SUBTITLE, "privacyPolicyUrl": PRIVACY_URL}}})
    ok(code, body, 'subtitle and privacy policy')
    print("subtitle and privacy policy URL written")

    # 4. category
    code, body = call('PATCH', f"appInfos/{info_id}", {
        "data": {"type": "appInfos", "id": info_id,
                 "relationships": {
                     "primaryCategory": {"data": {"type": "appCategories", "id": "EDUCATION"}},
                     "secondaryCategory": {"data": {"type": "appCategories", "id": "REFERENCE"}}}}})
    ok(code, body, 'category')
    print("category set to Education, with Reference second")

    # 5. the build
    _, builds = call('GET', f"builds?filter[app]={APP}&limit=5&sort=-version")
    build = next((b for b in builds['data'] if b['attributes']['version'] == '1023'), None)
    if build is None:
        sys.exit('build 1023 not found')
    code, body = call('PATCH', f"appStoreVersions/{vid}/relationships/build",
                      {"data": {"type": "builds", "id": build['id']}})
    ok(code, body, 'attach build')
    print("build 1023 attached to version 1.0")


if __name__ == '__main__':
    main()

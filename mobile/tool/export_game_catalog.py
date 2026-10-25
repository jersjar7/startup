#!/usr/bin/env python3
"""Exports the game catalog the server needs for the warm-up count, the Daily
and the monthly challenges.

Reads lib/features/games/game_catalog.dart and writes
../service/gameCatalog.json: {chapterId: {gameId: rounds}}, and
../service/lessonGames.json: {chapterId: {lessonId: [gameId, ...]}}, the
built games on each lesson's path node (by chapter: Surveying and
Transportation both have a horizontal-curves and a vertical-curves lesson) (a challenge lesson is cleared on the phone when all
of them are, ADR 0027). The server
counts a game as cleared when a student's phone events cover every round
with a right answer, and a chapter's games half is 50 times the share of
its games cleared (docs/mobile/sync-audit.md, fix 2). Run after any change
to the catalog:

    python3 mobile/tool/export_game_catalog.py
"""
import json, re, pathlib

root = pathlib.Path(__file__).resolve().parents[1]
src = (root / 'lib/features/games/game_catalog.dart').read_text()
GAME = r"GameDef\(\s*id: '([^']+)',\s*rounds: (\d+),(.*?)\)"
out = {}
lessons = {}
for section in re.split(r"const \w+Map = ChapterMap\(", src)[1:]:
    chapter = re.search(r"id: '([^']+)'", section).group(1)
    games = {}
    for m in re.finditer(GAME, section, re.S):
        if 'built: true' in m.group(3):
            games[m.group(1)] = int(m.group(2))
    out[chapter] = games
    lessons[chapter] = {}
    for node in re.split(r"LessonNode\(", section)[1:]:
        lesson = re.search(r"id: '([^']+)'", node).group(1)
        lessons[chapter][lesson] = [m.group(1) for m in re.finditer(GAME, node, re.S) if 'built: true' in m.group(3)]
target = root.parent / 'service/gameCatalog.json'
target.write_text(json.dumps(out, indent=2) + '\n')
print(f"{sum(len(g) for g in out.values())} games in {len(out)} chapters -> {target}")
target = root.parent / 'service/lessonGames.json'
target.write_text(json.dumps(lessons, indent=2) + '\n')
print(f"{sum(len(l) for l in lessons.values())} lessons -> {target}")

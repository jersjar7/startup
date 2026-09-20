#!/usr/bin/env python3
"""Exports the game catalog the server needs for the games half of mastery.

Reads lib/features/games/game_catalog.dart and writes
../service/gameCatalog.json: {chapterId: {gameId: rounds}}. The server
counts a game as cleared when a student's phone events cover every round
with a right answer, and a chapter's games half is 50 times the share of
its games cleared (docs/mobile/sync-audit.md, fix 2). Run after any change
to the catalog:

    python3 mobile/tool/export_game_catalog.py
"""
import json, re, pathlib

root = pathlib.Path(__file__).resolve().parents[1]
src = (root / 'lib/features/games/game_catalog.dart').read_text()
out = {}
for section in re.split(r"const \w+Map = ChapterMap\(", src)[1:]:
    chapter = re.search(r"id: '([^']+)'", section).group(1)
    games = {}
    for m in re.finditer(r"GameDef\(\s*id: '([^']+)',\s*rounds: (\d+),(.*?)\)", section, re.S):
        if 'built: true' in m.group(3):
            games[m.group(1)] = int(m.group(2))
    out[chapter] = games
target = root.parent / 'service/gameCatalog.json'
target.write_text(json.dumps(out, indent=2) + '\n')
print(f"{sum(len(g) for g in out.values())} games in {len(out)} chapters -> {target}")

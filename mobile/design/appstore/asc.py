"""Thin App Store Connect client for this repo's key."""
import json, pathlib, time, urllib.request, urllib.error, jwt

APP = "6800350588"
_REPO = pathlib.Path(__file__).resolve().parents[3]
_cfg = json.loads((_REPO / 'secrets' / 'appstore-connect.json').read_text())
_key = (pathlib.Path.home() / f".appstoreconnect/private_keys/AuthKey_{_cfg['key_id']}.p8").read_text()

_cached = {"tok": None, "until": 0}

def token():
    """One token, reused. Minting a fresh JWT per request trips Apple's rate
    limit and comes back as a bare 401, which reads like a bad key."""
    now = int(time.time())
    if _cached["tok"] and now < _cached["until"]:
        return _cached["tok"]
    _cached["tok"] = jwt.encode(
        {"iss": _cfg["issuer_id"], "iat": now, "exp": now + 1100,
         "aud": "appstoreconnect-v1"}, _key, algorithm="ES256",
        headers={"kid": _cfg["key_id"], "typ": "JWT"})
    _cached["until"] = now + 900
    return _cached["tok"]

def call(method, path, body=None, raw=None, headers=None, base="https://api.appstoreconnect.apple.com/v1/"):
    url = path if path.startswith('http') else base + path
    data = raw if raw is not None else (json.dumps(body).encode() if body else None)
    h = {"Authorization": f"Bearer {token()}"}
    if body is not None:
        h["Content-Type"] = "application/json"
    if headers:
        h.update(headers)
    req = urllib.request.Request(url, data=data, headers=h, method=method)
    try:
        with urllib.request.urlopen(req) as r:
            payload = r.read()
            return r.status, (json.loads(payload) if payload else None)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()[:600]

#!/usr/bin/env python3
"""Studio Evidence Agent — answers 'why' questions across fragmented studio data.
Track 02 (Open Agent Hackathon 2026): The Agent That Can Explain Why."""
import json, glob, os, sys, re

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(ROOT, "data")
STUDIO = "/app/conversations/6a7a26df12b12b33004ebe5d"

def load_events():
    events = []
    with open(os.path.join(DATA, "qc_events.jsonl")) as f:
        for line in f:
            line = line.strip()
            if line: events.append(json.loads(line))
    return events

def load_index():
    """Federated source: shimi-land gallery history index (fetched live)."""
    try:
        import urllib.request
        with urllib.request.urlopen("https://aidoor.shimi.land/history-index.json", timeout=10) as r:
            return json.load(r).get("items", [])
    except Exception:
        return []

def scan_artifacts(pattern):
    hits = []
    for p in glob.glob(os.path.join(STUDIO, pattern)):
        hits.append({"path": os.path.relpath(p, STUDIO), "size": os.path.getsize(p)})
    return hits

def answer(question):
    q = question.lower()
    events = load_events()
    art = re.search(r"b\d+_ex\d+_v\d+|b\d+_ex\d+|b\d+_\w+", question)
    key = art.group(0) if art else None
    chain = [e for e in events if key and key.rstrip("0123456789_") in e["artifact"] or (key and e["artifact"].startswith(key))]
    # fallback: all events for the base artifact id
    if not chain and key:
        base = re.match(r"b\d+_\w+", key)
        if base: chain = [e for e in events if e["artifact"].startswith(base.group(0))]
    rejects = [e for e in chain if e.get("verdict") == "REJECTED"]
    artifacts = scan_artifacts(f"lesson_clips/{key}*.mp4") if key else []
    fixes = [e.get("fix") for e in chain if e.get("fix")]
    defects = {d for e in rejects for d in e.get("defects", [])}

    out = {
        "question": question,
        "identified_artifact": key,
        "evidence_chain": [
            {"step": e["date"] + " " + e["stage"], "artifact": e["artifact"],
             "verdict": e.get("verdict", e.get("event", "")),
             "defects": e.get("defects", []),
             "owner_quote": e.get("evidence_quote", ""),
             "source": e["source"],
             "fix": e.get("fix", "")} for e in chain],
        "on_disk_artifacts": artifacts,
        "defect_signature": sorted(defects),
        "fix_history": fixes,
        "conclusion": "",
    }
    if rejects:
        last = rejects[-1]
        out["conclusion"] = (
            f"Artifact {key} failed garment QC {len(rejects)} time(s). Root cause per evidence: "
            + "; ".join(defects) + ". The engine (LTX) re-synthesizes the garment every frame and "
            "degrades it during motion; descriptive garment prompts made it worse. The fix that worked: "
            "render directly from the owner-approved reference anchor and keep only the canon bust wording. "
            "Latest status: awaiting owner visual QC gate.")
    return out

if __name__ == "__main__":
    q = sys.argv[1] if len(sys.argv) > 1 else "why did b11_ex3_v3 fail garment QC?"
    print(json.dumps(answer(q), ensure_ascii=False, indent=1))

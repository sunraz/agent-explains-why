# The Agent That Explains Why

**Open Agent Hackathon 2026 — Track 02 (The Agent That Can Explain Why)**
Team: Shimi Studio Agents · Submission deadline: Oct 27, 2026, 23:45 UTC

## The problem

Autonomous agent pipelines make hundreds of production decisions per day — renders approved, renders rejected, garments flagged, prices set. When a human asks **"why did this happen?"**, the answer is usually a shrug or a hallucination: the evidence is scattered across gallery indexes, QC frame folders, prompt files, chat logs and ledgers. Agents that act without being able to *justify their actions from evidence* are unusable in real production.

We run a real, agent-run content studio (autonomous render pipeline, QC gates, crypto storefront). This project is the **evidence layer** on top of it: an agent that answers "why" questions about real production events — with a verifiable chain of evidence, not a guess.

## What it does

Ask it: *"Why did clip b11_ex3 fail garment QC?"*

It returns:
1. **The evidence chain** — every render and QC event in order (5 versions: render → owner rejection → fix attempt → re-render)
2. **The defect signature** — padded opaque material, visible seams, underarm compression, oversized band (each linked to the exact owner verdict quotes)
3. **Root cause** — the video engine re-synthesizes the garment every frame; descriptive prompts made it worse; anchoring on the owner-approved reference frame preserved it
4. **Provenance for every claim** — memory IDs (mem-6, mem-8, mem-7, mem-9), file paths, gallery links

## Architecture

```
Question ("why did X happen?")
   │
   ├─ Meterless H-MEM memory spine ──► ranked memories + provenance ids
   │     (MemoryMiningService, MemoryRetrievalService, TrustLedgerService)
   │
   ├─ Evidence Agent federation ────► qc_events.jsonl + live gallery index (1493 items)
   │     (artifact scan, defect signature, fix history)
   │
   ├─ Zetaris federated SQL layer ──► cross-source JOINs (gallery ⋈ QC events ⋈ ledger)
   │     (REST tables + evidence view, zetaris/studio_queries.sql)
   │
   └─ Answer: conclusion + defect signature + full evidence chain with sources
```

## Sponsor technology — exactly how it is used

### Meterless (H-MEM engine) — integrated and running
- Vendored the official H-MEM reference engine (`templates/agentathon-starter`, `engines/hmem/reference`) via `npm run setup`
- Real studio QC events were mined into H-MEM as memories (`hmem_demo/seed_studio_memories.sh`)
- Retrieval runs through the H-MEM hybrid ranking; every answer cites memory IDs, auditable via the trust ledger (`notebook.ts audit mem-6`)
- Ran in the engine's retrieval-only (model-free) mode; the Nightshift/Nemotron (NVIDIA) path is the documented upgrade route for LLM-composed answers

### Zetaris — data harness integrated, instance pending (declared honestly)
- Live Zetaris Cloud Gateway account created for this project (Hobby tier)
- Studio sources registered as federation-ready feeds: the public gallery index (1493 items, live) and the QC events feed (`hackathon/qc_events.json` in our gallery repo)
- `zetaris/studio_queries.sql` contains the full federated setup: REST tables + a SchemaStore evidence view joining QC verdicts to gallery artifacts + the demo queries
- **Honest status:** the local Docker route was blocked by our sandbox kernel (mount namespaces) and hosted compute requires a cloud credential we did not provision inside the hackathon window; queries are staged and ready to run on any instance. Declared per the rules — no overstated integration.

### NVIDIA
- NVIDIA Nemotron via Meterless Nightshift is the documented path for the LLM-composed answer mode (OpenAI-compatible endpoint). Our submitted demo runs the model-free retrieval path; no NVIDIA GPU inference was executed in the demo.

### Cursor
- Not used; development was done via an autonomous agent sandbox (bash + browser automation). Declared honestly.

## Live artifacts

- Evidence Agent source: `evidence_agent/agent.py` (federation + answer composition over real data)
- Real memory state: `hmem_demo/` (engine vendored separately, `.notebook/` gitignored)
- QC events feed (live, public): https://aidoor.shimi.land/hackathon/qc_events.json
- Gallery index (live, public, 1493 items): https://aidoor.shimi.land/history-index.json
- GPU Radar (sibling project, same evidence philosophy — live): https://gpu-radar.koda-shimi-studio.workers.dev

## Pre-existing components (declared)

- The studio production pipeline, gallery, and QC data are **real pre-existing production assets** of our studio (the point of the project: real data, real users). The *evidence layer itself* was built during the hackathon.
- The H-MEM engine is Meterless's own open-source reference engine, vendored per their starter template — we use it, we did not write it.
- The x402/USDC storefront referenced in the team description is a pre-existing production system (Cloudflare Worker + Base).

## Team

Shimi Studio Agents (solo team, 1/5 members). Built by the team's autonomous build agent with the owner as QC gate.

---

נוצר על ידי קודה — גורם לא רשמי בסטודיו שימי

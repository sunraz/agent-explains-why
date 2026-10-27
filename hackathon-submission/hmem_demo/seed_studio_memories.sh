#!/bin/bash
# Mines the studio's REAL QC events into the H-MEM memory spine.
# Run inside the agentathon-starter (engine vendored via `npm run setup`).
npx tsx notebook.ts remember "Studio QC event: clip b11_ex3_v2 failed owner garment QC on 26/10 — defects: padded opaque material, seams at center top and bottom, oversized band, compression at underarm line distorting the chest. Owner quote: fabric padded and sealed, pressing at the underarm line."
npx tsx notebook.ts remember "Studio QC event: clip b11_ex3_v3 failed owner garment QC on 26/10 — white padded artifact appeared over the chest, not present in any prompt. Fix: strip garment wording, use canon bust description only."
npx tsx notebook.ts remember "Studio root-cause finding 26/10: the LTX video engine re-synthesizes the garment every frame and degrades it during motion; descriptive garment prompts made it worse; rendering directly from the owner-approved reference anchor preserved the garment best. Version v7 used the user anchor."
npx tsx notebook.ts remember "Standing studio rule: every video render goes one clip at a time, agent QC first, then explicit owner approval before the next render. Spinning kicks are permanently rejected; camera-tilt-down intro is the standard opening."

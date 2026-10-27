engine source: vendor/hmem | state: .notebook/
mode: retrieval-only | strategy: comprehensive
Based on what I remember about "why did b11_ex3 fail garment QC and what fixed it":
- Studio QC event: clip b11_ex3_v2 failed owner garment QC on 26/10 — defects: padded opaque material, seams at center top and bottom, oversized band, compression at underarm line distorting the chest. Owner quote: fabric padded and sealed, pressing at the underarm line. (relevance 0.21)
- Studio root-cause finding 26/10: the LTX video engine re-synthesizes the garment every frame and degrades it during motion; descriptive garment prompts made it worse; rendering directly from the owner-approved reference anchor preserved the garment best. Version v7 used the user anchor. (relevance 0.17)
- Fix: strip garment wording, use canon bust description only. (relevance 0.17)
- Standing studio rule: every video render goes one clip at a time, agent QC first, then explicit owner approval before the next render. Spinning kicks are permanently rejected; camera-tilt-down intro is the standard opening. (relevance 0.15)

provenance: mem-6, mem-8, mem-7, mem-9 (audit any of them: notebook audit <id>)

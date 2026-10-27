-- Zetaris federated queries for the Shimi Studio Evidence Agent
-- Run on our Zetaris instance (pending: local Docker blocked in sandbox kernel;
-- needs owner AWS mini cluster OR owner machine with Docker Desktop, then these run as-is)
-- Based on zetaris/getting-started first-dataset.md REST-table pattern.

-- 1. Lightning database for studio sources
CREATE LIGHTNING DATABASE SHIMI_STUDIO DESCRIBE BY "Shimi Studio fragmented production data";

-- 2. SchemaStore container
CREATE SCHEMASTORE CONTAINER studio;

-- 3. Gallery history index (1493 items, live via GitHub Pages JSON)
CREATE LIGHTNING REST TABLE gallery_index FROM SHIMI_STUDIO REQUEST(
    endpoint "https://aidoor.shimi.land/history-index.json",
    method "get",
    response_type "json",
    http_encoding "URLENCODED"
) HEADER (
) BODY ();

-- 4. QC events feed (exported from the Evidence Agent; served as JSON)
CREATE LIGHTNING REST TABLE qc_events FROM SHIMI_STUDIO REQUEST(
    endpoint "https://aidoor.shimi.land/hackathon/qc_events.json",
    method "get",
    response_type "json",
    http_encoding "URLENCODED"
) HEADER (
) BODY ();

-- 5. Federated view: rejected renders joined to their gallery evidence
CREATE SCHEMASTORE VIEW qc_evidence_view WITH CONTAINER studio AS
SELECT e.artifact, e.date, e.verdict, e.defects, e.owner_quote, e.fix,
       g.title AS gallery_title, g.link AS gallery_link
FROM qc_events e LEFT JOIN gallery_index g ON e.artifact = g.file_name;

-- Demo query: "why did b11_ex3 fail garment QC?" answered with federated evidence
SELECT * FROM qc_evidence_view WHERE artifact LIKE 'b11_ex3%' ORDER BY date;

-- Demo query 2: defect frequency across the whole studio (agentic QC analytics)
SELECT defects, COUNT(*) AS occurrences FROM qc_events
WHERE verdict = 'REJECTED' GROUP BY defects ORDER BY occurrences DESC;

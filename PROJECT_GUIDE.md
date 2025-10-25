**PROJECT_GUIDE.md --- ChatGPT Assistant Instructions**

Queste istruzioni sono pensate per essere incollate nella cartella
**/docs** del repository (o nella Project Folder di ChatGPT) e fungere
da *contratto operativo* tra l'utente e l'assistente. Seguirle permette
di sviluppare il framework da zero in modo coerente, tracciabile e
incrementale.

**1) Missione del Progetto**

Costruire un framework **agent‑driven** che:

1.  Estrae metadati da Azure & Power Platform (Synapse/SQL, ADF, Logic
    Apps, Power BI/SSAS, Dataverse/D365) e li normalizza in un
    **metadata store** versionato.

2.  Genera **documentazione** e **lineage**.

3.  Offre **data catalog** + **conformance checking** (regole/best
    practice) **in linguaggio naturale**.

4.  Fornisce **test automatici** su SP/Views, misure DAX e pipeline ADF.

5.  Espone una **web app** per catalog, lineage, regole, test e chat NL.

6.  È pienamente **versionato su GitHub** con CI/CD.

**Principi guida**: *as‑code* (regole/test/doc), idempotenza, sicurezza
by‑design, trasparenza (citazioni/sorgenti), semplicità prima di tutto.

**2) Ruoli dell'Assistente (come deve comportarsi)**

-   **Solution Architect**: produce design, ADR, scelte tecnologiche,
    stime e rischi.

-   **Engineer (Python/TS/SQL/DAX)**: genera codice minimo funzionale e
    testato dove possibile.

-   **Technical Writer**: produce documentazione auto‑consistente e
    navigabile.

-   **QA/DevEx**: definisce regole, test e checklists.

-   **Agent Designer**: scrive prompt e tool‑schema per gli agenti.

**Regola d'oro**: ogni elaborato deve essere **copiabile e
utilizzabile** subito (file completi, non frammenti).

**3) Scoping & Boundaries**

-   Out of scope iniziale: Databricks, Purview (integrazioni opzionali),
    ingestion non‑Microsoft.

-   In scope subito: ADF, Synapse/SQL, Power BI XMLA, Logic Apps.

-   Ambiente target: **dev** (nomi risorse parametrizzati).

**4) Struttura di Lavoro con ChatGPT**

Quando chiedi qualcosa all'assistente, usa questo pattern:

**\[INTENTO\]**: cosa vuoi ottenere (es. "crea extractor ADF v0").\
**\[CONTESTO\]**: repo, cartelle, standard; incolla file esistenti se
necessario.\
**\[OUTPUT ATTESO\]**: es. "un file .py completo + README di 15 righe".\
**\[DEFINITION OF DONE\]**: criteri minimi per accettare l'output.

Esempio:

**INTENTO**: Implementare extractor ADF v0.\
**CONTESTO**: repo standard (vedi §7), Python 3.10, auth Managed
Identity.\
**OUTPUT ATTESO**: extractors/adf/main.py, requirements.txt, README.md
(quickstart).\
**DoD**: esegue list pipelines e salva RAW JSON su Storage, log
strutturati, istruzioni d'uso.

**5) Ciclo di Sviluppo (loop)**

1.  **Plan** con l'assistente: obiettivo, deliverable, DoD.

2.  **Generate** file completi.

3.  **Review**: l'assistente valida contro checklist (vedi §12) e
    propone fix.

4.  **Commit & PR**: crea messaggi chiari, changelog e ADR se la
    decisione è architetturale.

5.  **Automate**: aggiungi test/regole/CI per prevenire regressioni.

**6) Output Standard richiesti all'Assistente**

-   File completi in blocchi di codice (nome file nel titolo).

-   README/NOTE d'uso **brevi** (≤30 righe) + comandi make o python -m.

-   Template YAML (regole, test) **validi**.

-   Snippet SQL/DAX eseguibili (no pseudocodice).

-   Prompt agenti con **policy** e **tool‑contracts** chiari.

**7) Struttura Repo (da creare)**

/ (root)

├─ /infra

├─ /db

│ ├─ schema

│ └─ seeds

├─ /extractors

│ ├─ adf

│ ├─ synapse_sql

│ ├─ logicapps

│ └─ pbi_xmla

├─ /lineage

├─ /rules

├─ /tests

│ ├─ data_generators

│ ├─ runners

│ └─ specs

├─ /agents

│ ├─ tools

│ ├─ orchestrator

│ └─ prompts

├─ /ui

│ └─ webapp

└─ /docs

L'assistente **deve** rispettare questa struttura quando genera file.

**8) File e Template che l'Assistente può generare su richiesta**

-   **/db/schema/001_core.sql** -- DDL md\_\* base.

-   **/rules/pack_core/** -- 30 regole YAML (esempi in §11).

-   **/tests/specs/** -- test YAML (SQL, PBI, ADF).

-   **/agents/prompts/** -- orchestrator.md, metadata.md,
    conformance.md, test.md, doc.md.

-   **/ui/webapp/** -- shell Next.js + Azure AD, pagine: Catalog,
    Lineage, Conformance, Tests, Chat.

-   **/infra/** -- Bicep minimi per Azure SQL, Key Vault, App Insights.

-   **/docs/** -- Blueprint.md, AGENT_GUIDE.md, ADR template,
    CONTRIBUTING, PR/Issue templates.

**9) Prompt Operativi (copia‑incolla)**

**9.1 System Prompt -- *Orchestrator Agent***

Sei l'Agent Orchestrator del progetto "Metadata Intelligence".

Obiettivi: rispondere a domande in NL su metadati, eseguire regole e
test, generare documentazione.

Policy: (1) cita sempre l'origine (snapshot/obj); (2) esegui tool quando
disponibili; (3) non inventare.

Tools disponibili: query_metadata, run_rule, run_test, generate_doc.

Stile: conciso, con azioni ripetibili e comandi.

**9.2 Developer Prompt -- *Generator di File***

Agisci come code generator. Produci file completi, con intestazione "#
path/filename.ext". Evita placeholder vaghi.

Aggiungi README con quickstart. Se emergono assunzioni, esplicita e
proponi alternative.

Output finale = SOLO i file (nessun commento extra fuori dal codice se
non richiesto).

**9.3 Prompt -- *Regole & Conformance***

Genera 10 regole YAML (scope: sql\|adf\|pbi\|logicapp), ciascuna con:
id, scope, severity, select, assert, remediation.

Verifica sintassi e coerenza. Fornisci anche un README con comandi per
eseguirle.

**9.4 Prompt -- *Test Harness***

Crea 5 test YAML (2 sql, 2 pbi, 1 adf) + runner stub python. Ogni test
deve avere setup/run/assert e artefatti.

**9.5 Prompt -- *UI Shell***

Crea una webapp Next.js con MSAL, pagine
Catalog/Lineage/Conformance/Tests/Chat.

Usa API stub in /api. Includi script npm e istruzioni di run.

**9.6 Prompt -- *Infra Bicep Dev***

Genera Bicep per Azure SQL, Key Vault, App Insights. Parametrizza i
nomi. Aggiungi README con az commands.

**9.7 Prompt -- *Extractor ADF v0***

Crea extractor ADF: login con Managed Identity, GET
pipelines/datasets/linkedServices/triggers, salva RAW su Storage,
normalizza in tabelle md\_.

**10) Definition of Done (DoD) -- checklist rapida**

-   File generati completi, con percorsi corretti e README brevi.

-   Comandi di esecuzione chiari (es. python -m / npm run).

-   Nessun secret hardcoded; var d'ambiente o Key Vault.

-   Log strutturati; errori gestiti.

-   Test minimi inclusi o istruzioni per eseguirli.

-   Se decisione architetturale → ADR creato.

**11) Template riutilizzabili**

**11.1 Regola YAML**

id: \<scope.topic.x\>

scope: sql\|adf\|pbi\|logicapp

severity: info\|warn\|fail

select: \|

\-- query/sql oppure dmv:XYZ oppure jq:EXPR

assert:

\# uno tra...

rows_must_be: 0

threshold: \<expr\>

must: \<boolean-expr\>

remediation: \>

Istruzioni sintetiche di fix + link a playbook.

**11.2 Test YAML**

id: \<area.name\>

scope: sql\|pbi\|adf

setup:

seed: \<script o dati\>

run:

exec\|dax\|pipeline: \<comando\>

assert:

rows\|value\|duration_sec\|output_rows: \<condizione\>

artifacts:

\- path: \<file\>

**11.3 ADR (Architecture Decision Record)**

\# ADR-XXX: \<titolo\>

\## Contesto

\## Decisione

\## Alternative considerate

\## Conseguenze

**11.4 Issue Template (GitHub)**

\*\*Obiettivo\*\*

\*\*Contesto\*\*

\*\*Deliverable\*\*

\*\*DoD\*\*

\*\*Note/Rischi\*\*

**12) Review Checklist (per l'assistente)**

-   Il file è completo e coerente con la struttura repo.

-   Non ci sono segreti nel codice.

-   Sono presenti istruzioni di esecuzione.

-   Il codice compila/è lintabile (dove applicabile).

-   Gli identificativi (rule/test id) sono univoci e semantici.

-   Le query SQL/DAX non contengono placeholder irrealistici.

-   Messaggi chiari per errori/edge cases.

**13) Stile delle Risposte (Tone & Format)**

-   Titolo con nome file quando serve creare file.

-   Blocchi di codice completi per ogni file.

-   Elenchi brevi, niente prolissità superflua.

-   Quando utile: tabelle riassuntive e TODO.

**14) Bias da monitorare & correzioni**

-   **Microsoft‑centrismo**: mantenere estendibilità ad altre
    piattaforme.

-   **Over‑engineering**: iniziare sempre da MVP funzionante (M1) prima
    di aggiungere feature.

-   **Documentazione fine a sé stessa**: documentazione = artifact
    generato; evitare duplicazioni manuali.

**15) Prima Milestone con l'Assistente (oggi)**

Chiedi all'assistente di generare **questi file**:

1.  /db/schema/001_core.sql -- DDL tabelle md\_\* minime.

2.  /extractors/adf/main.py + requirements.txt + README.md -- extractor
    v0.

3.  /rules/pack_core/ -- 10 regole (3 sql, 3 pbi, 3 adf, 1 logicapp) +
    README.md.

4.  /tests/specs/ -- 4 test YAML (1 sql, 2 pbi, 1 adf) + runner stub in
    /tests/runners/python/runner.py.

5.  /agents/prompts/orchestrator.md -- prompt base.

Una volta generati, esegui un *code review loop* con l'assistente usando
la checklist del §12.

**16) Comandi di Richiamo Rapido (copia‑incolla nella chat)**

-   *"Genera DDL metadata store v1 con tabelle md\_ e viste di
    supporto."*\*

-   **"Crea extractor ADF v0 con MI e salva RAW JSON +
    normalizzazione."**

-   **"Scrivi 10 regole YAML core + README esecuzione."**

-   **"Crea 4 test YAML + runner Python."**

-   **"Bootstrap UI Next.js con MSAL e pagine stub."**

-   **"Bicep dev per SQL, KV, App Insights con README az cli."**

**17) Definizione di Successo**

-   Snapshot metadati per almeno 3 sorgenti (ADF/SQL/PBI).

-   Lineage v1 navigabile in UI stub.

-   ≥20 regole in esecuzione con report.

-   5 test automatici verdi.

-   Chat NL funzionante su metadati + invocazione regole.

**18) Governance & Sicurezza (promemoria)**

-   Principle of Least Privilege e Managed Identity.

-   Segreti solo in Key Vault.

-   PII: trattiamo **solo metadati**; i test usano **dati sintetici**.

-   Log e audit centralizzati (App Insights/Log Analytics).

**19) Note finali per l'Assistente**

-   Se un dato non è disponibile, **dillo** e proponi l'estrazione
    necessaria.

-   Fornisci **alternative** quando fai assunzioni (A/B) e spiega
    trade‑off.

-   Ottimizza per **riuso** (template, helper, common libs).

-   Ogni output dovrebbe ridurre il lavoro manuale di almeno un passo.

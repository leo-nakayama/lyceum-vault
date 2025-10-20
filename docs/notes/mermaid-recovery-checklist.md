# Mermaid Recovery Checklist (MkDocs + Material)

A minimal, deterministic playbook to get Mermaid diagrams rendering again — without breaking other pages.

---

## 0) Goal & Symptoms

* **Goal:** Render Mermaid diagrams defined with either fences (```mermaid) or inline `<div class="mermaid">…</div>`.
* **Common symptoms:**

  * Fenced blocks show as plain text with backticks → **Markdown fences not parsed** on that page.
  * `<div class="mermaid">…</div>` shows “syntax error” → **diagram text malformed** (not config).

---

## 1) Known-Good Config (mkdocs.yml)

Make sure these blocks exist (merge with your current file; keys already present are fine):

```yaml
markdown_extensions:
  - admonition
  - footnotes
  - tables
  - toc:
      permalink: true
  - pymdownx.details
  - fenced_code
  - pymdownx.superfences

extra_javascript:
  - https://unpkg.com/mermaid@10.9.1/dist/mermaid.min.js
  - js/mermaid-init.js
```

> After editing `mkdocs.yml`, **restart** the dev server (`Ctrl+C` → `mkdocs serve`) and **hard refresh** the browser (Cmd/Ctrl+Shift+R).

---

## 2) Add the Resilient Initializer

Create `docs/js/mermaid-init.js` (or overwrite it) with:

```javascript
/* docs/js/mermaid-init.js */
(function () {
  function convertCodeFencesToMermaid() {
    // Convert <pre><code class="language-mermaid">…</code></pre> → <div class="mermaid">…</div>
    document.querySelectorAll('pre > code.language-mermaid').forEach(function (code) {
      var pre = code.parentElement;
      var container = document.createElement('div');
      container.className = 'mermaid';
      container.textContent = code.textContent;
      pre.replaceWith(container);
    });
  }
  function init() {
    convertCodeFencesToMermaid();
    if (window.mermaid) {
      window.mermaid.initialize({ startOnLoad: true, securityLevel: "loose" });
      window.mermaid.init(undefined, document.querySelectorAll('.mermaid'));
    }
  }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
```

This makes fences work even if Markdown renders them as `<pre><code class="language-mermaid">…`.

---

## 3) Global Sanity Test (new page)

Create `docs/mermaid-test.md`:

````markdown
# Mermaid Test

**Inline DIV (should render a tiny arrow):**
<div class="mermaid">graph TD; A-->B;</div>

**Fenced block (should render once fences are parsed properly):**
```mermaid
graph TD
  X-->Y
````

````

Temporarily add to `nav:`:
```yaml
- TEST: mermaid-test.md
````

**Interpretation**

* DIV renders, FENCE doesn’t → Fence parsing issue (page context/indentation).
* DIV errors → Mermaid is loaded but the diagram string is malformed.
* Both fail → Mermaid JS not loaded or path issues (check HTML for the two `<script>` tags).

---

## 4) Page-Local Fence Rules (most failures are here)

When using fences on any page:

* Leave **one blank line** before and after the fence.
* The fence **must start at column 1** (no indentation), especially after admonitions (`!!! tip`).
* Use plain ASCII first; then add formatting.
* Prefer **tildes** if backticks act up:

```markdown
~~~mermaid
graph LR
  A[Fence parsed?] --> B[Yes]
~~~
```

---

## 5) Safe Diagram Patterns (avoid parser traps)

Mermaid labels are sensitive to certain characters:

* **Square brackets inside labels** end the label early. If needed, **escape** them:

  * `[` → `&#91;`
  * `]` → `&#93;`
* Avoid smart quotes and unusual Unicode bullets in labels while testing; use commas.
* Add this directive if you want `<br/>` in labels later:

  ```
  %%{init: {"securityLevel":"loose","flowchart":{"htmlLabels":true}}}%%
  ```

**Example — safe, ASCII-only version of your big diagram (use this first):**

```html
<div class="mermaid">
flowchart TD
  A[Inquiry / CFP (Data string)] --> B[DSL Inference Engine (Lyceum Workbench)]

  subgraph D ["Module Chain"]
    D1[AristotleFourCauses: O_decompose, O_tracechain, O_rebalance, O_agent_network]
    D2[TradeoffLens: O_surfaceAxes, O_mapFrontier, O_shiftKnob]
    D3[Synthetic Naikan: N_capture, N_appraise, N_gratitude, N_responsibility, N_counterfactual, N_telos_check, N_commit, N_score]
    D1 --> D2 --> D3
  end

  B --> D --> C[Observation Report (structured, no chain-of-thought)]
  C --> E{Telos / Guardrails (FinalCause + Safety)}
  E -- passes --> F[Artifact Packaging: CFP, Report, Methodology]
  F --> G[Publish to Leo's Lyceum Vault]
  G --> H[Reintegration: refine Data, adjust modules/knobs]
  H --> A
  E -- fails --> I[Rebalance / Re-run]
  I --> B
</div>
```

Once that renders, you can reintroduce `<br/>` and special characters using the init directive and HTML entities.

---

## 6) Common Error Messages & Fixes

* **“Parse error on line …” near `]`**
  You used literal `[` or `]` inside a label. Replace with `&#91;` / `&#93;` or remove them.

* **Diagram shows as raw text with backticks**
  Fence not parsed → spacing/indent/placement issue. Move the fence out of admonitions, ensure a blank line before/after, and column-1 start.

* **Nothing renders; both DIV and fence fail**
  Mermaid JS not loaded. Check page HTML has both:

  * `<script src=".../mermaid.min.js">`
  * `<script src=".../js/mermaid-init.js">`

---

## 7) Minimal Rollback Plan (if under time pressure)

* Use the **inline `<div class="mermaid">…</div>`** approach on critical pages (bypasses fence parsing).
* Keep a small test page (`mermaid-test.md`) in the nav to verify global health later.
* Leave complex diagrams in ASCII-only form until you confirm stable rendering.

---

**Last updated:** *(fill date)*.
If a diagram still errors, copy the Mermaid **error text** shown under the diagram and the **3–5 lines around that token** from your source — then fix that token or share it for pinpoint help.

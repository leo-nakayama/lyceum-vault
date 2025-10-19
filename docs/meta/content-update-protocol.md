# 🧭 Lyceum Vault — Content Update Protocol
*Authoring and publishing workflow guide*

---

## Purpose
To maintain a consistent, traceable rhythm for updating the Lyceum Vault.  
This protocol describes how new ideas — notes, essays, or projects — move from draft to publication.

---

## 1️⃣ Draft Phase (Local)

1. **Decide category**
   - `docs/notes/` → technical or conceptual memo  
   - `docs/essays/` → reflective or philosophical text  
   - `docs/projects/` → documentation of a running or planned system

2. **Create Markdown file**

```bash
   cd docs/notes
   touch new-topic.md
````

Write freely in Obsidian or a Markdown editor.
Include a `# Title`, sections, and (if relevant) diagrams or code.

3. **Local preview**

```bash
   mkdocs serve
```

Access at [http://127.0.0.1:8000](http://127.0.0.1:8000) to verify layout and internal links.

---

## 2️⃣ Integration Phase

1. **Edit navigation** in `mkdocs.yml`:

   ```yaml
   nav:
     - Notes:
         - New Topic Title: notes/new-topic.md
   ```
2. **Check for broken links**

   ```bash
   mkdocs build --strict
   ```

   If no warnings → proceed.

---

## 3️⃣ Publish Phase

1. **Commit and push**

   ```bash
   git add .
   git commit -m "Add: new note on <topic>"
   git push
   ```
2. The **GitHub Actions workflow** runs automatically:

   * Builds the site
   * Deploys it to `gh-pages`

3. Within 1–2 minutes, the live site updates at
   `https://<username>.github.io/lyceum-vault/`

---

## 4️⃣ Collaboration Phase (with GPT)

When co-developing new modules or essays:

1. **Zip current repo** (excluding `/site`):

   ```bash
   zip -r lyceum-vault-update.zip docs mkdocs.yml .github
   ```
2. **Upload here** (ChatGPT session).

3. GPT will:

   * Read the current structure
   * Suggest new folder paths and filenames
   * Draft content or update navigation automatically

---

## 5️⃣ Maintenance Phase

```markdown
| Task               | Frequency           | Command / Note                          |
| ------------------ | ------------------- | --------------------------------------- |
| Dependency updates | Monthly             | `pip install -U mkdocs mkdocs-material` |
| Local link audit   | Before big releases | `mkdocs build --strict`                 |
| Backup             | Continuous          | Push repo to GitHub (auto backup)       |
```

---

## Philosophy

> “The Vault grows by reflective iteration — every push is a philosophical act.”

The goal isn’t perfection but continuity: keep the loop running — Draft → Reflect → Publish → Refactor.

---




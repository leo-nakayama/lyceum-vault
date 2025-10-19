# “MkDocs to GitHub Pages” on AWS (conceptual equivalent)

## Diagram (high-level)

```markdown
You push to main
        │
        ▼
 CodePipeline (source: GitHub or CodeCommit)
        │
   triggers build
        ▼
   CodeBuild (uses buildspec.yml)
  - pip install mkdocs/material
  - mkdocs build → ./site
        │
  artifacts: ./site (static HTML/CSS/JS)
        │
        ▼
 Deploy stage
   • S3 static website bucket (upload ./site)
   • (optional) Invalidate CloudFront cache
```

---

## Core pieces you’d create

1. **S3 bucket** for hosting the static site

* Example: `s3://lyceum-vault-site`
* Block public access **OFF**, website hosting **ON** (or keep private + serve via CloudFront)

2. **(Recommended) CloudFront distribution** in front of S3

* Custom domain + TLS via ACM
* Better latency + cache control

3. **CodeBuild project**

* Builds the site using a `buildspec.yml`
* Outputs `site/` as artifacts

4. **CodePipeline**

* **Source**: GitHub (or CodeCommit)
* **Build**: CodeBuild project
* **Deploy**: S3 deploy (and optional CloudFront invalidation via a custom Lambda or CodeBuild post-step)

5. **IAM roles/policies**

* CodeBuild role: read source, write artifacts, put to S3
* Pipeline role: orchestrate stages

## Minimal `buildspec.yml` (MkDocs)

Place this at your repo root (used by CodeBuild):

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.12
    commands:
      - pip install --upgrade pip
      - pip install mkdocs mkdocs-material
  build:
    commands:
      - mkdocs build --strict
artifacts:
  files:
    - '**/*'
  base-directory: site
  discard-paths: no
```

This mirrors your GitHub Actions steps: install → build → produce `site/` as artifacts.

---

## Example S3 deploy (CLI) – one-off or from a deploy stage

```bash
# Upload locally built site/ to S3
aws s3 sync site/ s3://lyceum-vault-site --delete
```

In CodePipeline, the **Deploy** action would publish the build artifact to S3 automatically.

## Typical IAM policy snippet for CodeBuild to write to your S3 bucket

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": ["s3:PutObject","s3:PutObjectAcl","s3:DeleteObject"], "Resource": "arn:aws:s3:::lyceum-vault-site/*" },
    { "Effect": "Allow", "Action": ["s3:ListBucket"], "Resource": "arn:aws:s3:::lyceum-vault-site" }
  ]
}
```

> In production, you’d scope permissions tightly and wire them to your CodeBuild role.

---

## Why GitHub Actions "feels" simpler

* **Fewer moving parts**: one YAML in your repo; no IAM/S3/CloudFront wiring.
* **Built-in hosting**: GitHub Pages vs rolling your own static hosting stack.
* **Auth**: ephemeral `GITHUB_TOKEN` vs IAM roles/secrets setup.


### Comparison

AWS shines when you need **deep integration** with AWS workloads (ECS/EKS/Lambda, multi-account deployments, secrets, VPC builds, etc.). For a **static MkDocs site**, GitHub Actions + Pages is lean and perfect.

---

# GitHub Actions vs AWS CI/CD for a MkDocs Site

**TL;DR**  
For a static MkDocs site, **GitHub Actions + GitHub Pages** is simpler, cheaper, and faster to set up than AWS CodePipeline/CodeBuild/CodeDeploy + S3/CloudFront. Use AWS when you need enterprise-grade integrations with AWS workloads.

---

## Visual: GitHub Actions Flow

```markdown

push to main
│
▼
GitHub Actions (deploy.yml)

1. checkout
2. setup-python + pip install mkdocs/material
3. mkdocs build → ./site
4. deploy ./site → gh-pages
   │
   ▼
   GitHub Pages serves https://<user>.github.io/<repo>/

```

---

## Visual: AWS “Equivalent” Flow

```markdown

push to main
│
▼
CodePipeline (source: GitHub/CodeCommit)
│
▼
CodeBuild (buildspec.yml)

* pip install mkdocs/material
* mkdocs build → ./site
  │
  ▼
  Artifact: site/ → Deploy to S3 static website (optional: CloudFront)

```

---

## When to choose which

```markdown
| Situation | Choose |
|---|---|
| Static docs/portfolio, simple publish | **GitHub Actions + Pages** |
| AWS-native app deployments (EC2/ECS/Lambda), complex infra, multi-account | **AWS CodePipeline/CodeBuild/CodeDeploy** |
| Need global CDN, custom domain, strict IAM | Either (CloudFront vs Pages + custom domain) |
| Want single-place DevOps inside GitHub | **GitHub Actions** |

```

---

## Minimal files

### GitHub Actions (`.github/workflows/deploy.yml`)

```yaml
name: Deploy MkDocs to GitHub Pages
on: { push: { branches: [ main ] }, workflow_dispatch: {} }
permissions: { contents: write }
jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install --upgrade pip && pip install mkdocs mkdocs-material
      - run: mkdocs build --strict
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./site
```

### AWS CodeBuild (`buildspec.yml`)

```yaml
version: 0.2
phases:
  install:
    runtime-versions: { python: 3.12 }
    commands:
      - pip install --upgrade pip
      - pip install mkdocs mkdocs-material
  build:
    commands:
      - mkdocs build --strict
artifacts:
  files: ['**/*']
  base-directory: site
  discard-paths: no
```

---

## Cost & Ops

* **GitHub**: Free for public repos. Private repos have generous minutes. Pages hosting free.
* **AWS**: Pay per build minute, S3 storage/requests, CloudFront bandwidth. IAM setup and resource sprawl increase ops overhead.

---

## FAQ

**Q: Can I still use a custom domain with GitHub Pages?**
Yes. Point DNS (CNAME) to `<user>.github.io`, add the **Custom domain** in Pages settings (and optional `cname:` in the deploy action).

**Q: What about previews per branch?**
GitHub Actions supports deploying previews (e.g., to a `preview` prefix or separate bucket). On AWS you can create per-branch S3 buckets or CloudFront behaviors.

**Q: Is Pages fast enough vs CloudFront?**
For personal docs, usually yes. If you need strict latency or enterprise controls, use CloudFront.

---



# 📦 dbt-fabricDB-data-transformation

This repository contains a dbt project configured to run against **Microsoft Fabric SQL Database (Preview)** using GitHub Actions. It supports multi-environment deployment (DEV, UAT, PROD), automated testing, and gated production approvals.

## 📋 Table of Contents

- [📦 dbt-fabricDB-data-transformation](#-dbt-fabricdb-data-transformation)
  - [📋 Table of Contents](#-table-of-contents)
  - [🛠 Project Structure](#-project-structure)
  - [🚀 CI/CD Workflow Overview](#-cicd-workflow-overview)
  - [🔐 Secrets \& Profiles Setup](#-secrets--profiles-setup)
    - [1. Encode Your `profiles.yml`](#1-encode-your-profilesyml)
    - [2. Store Secrets in GitHub](#2-store-secrets-in-github)
  - [🧪 Local Testing](#-local-testing)
  - [🧱 GitHub Actions Workflow](#-github-actions-workflow)
  - [👩‍⚖️ UAT and Prod Deployment Logic](#️-uat-and-prod-deployment-logic)
    - [Schema Naming](#schema-naming)
    - [Model Configuration](#model-configuration)
  - [🔐 Production Environment Approval](#-production-environment-approval)
  - [📎 Appendix – Extra Tips](#-appendix--extra-tips)

## 🛠 Project Structure

```bash
fabricdb-dbt-transformation/
├── fabricdb_elt/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   ├── dbt_project.yml
│   └── ...
├── .github/
│   └── workflows/
│       └── deploy.yml
└── README.md
```

## 🚀 CI/CD Workflow Overview

This repo uses **GitHub Actions** to automate dbt builds with three main steps:

| Stage       | Description                                      |
|-------------|--------------------------------------------------|
| **DEV**     | Local development and testing using dbt CLI.   |
| **UAT**     | Runs `dbt build` and `dbt test` on the `uat` schema. |
| **PROD**    | Requires manual approval to run. Deploys to `mart` schema. |

## 🔐 Secrets & Profiles Setup

### 1. Encode Your `profiles.yml`

Create your `~/.dbt/profiles.yml` with multiple targets:

```yaml
fabricdb_elt:
  target: default
  outputs:
    dev:
      ...
    uat:
      schema: uat
      ...
    prod:
      schema: mart
      ...
```

Then encode it:

```bash
base64 ~/.dbt/profiles.yml > profiles_b64.txt
```

### 2. Store Secrets in GitHub

Go to your repo → **Settings** → **Secrets and variables** → **Actions**:

- `DBT_PROFILES_YML_B64`: base64-encoded `profiles.yml`
- `DBT_SP_CLIENT_ID`: Service principal client ID
- `DBT_SP_CLIENT_SECRET`: Service principal secret
- `DBT_SP_TENANT_ID`: Service principal tenant ID

## 🧪 Local Testing

```bash
dbt build --target uat
dbt test --target uat
dbt build --target prod
```

## 🧱 GitHub Actions Workflow

`.github/workflows/deploy.yml`:

```yaml
name: Deploy DBT Project to Fabric

on:
  push:
    branches:
      - main
      - feature/*
  pull_request:
    branches:
      - main
  workflow_dispatch:

jobs:
  UAT:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.12

      - name: Install ODBC and dbt dependencies
        run: |
          sudo ACCEPT_EULA=Y apt-get update
          sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev
          pip install dbt-core==1.8.7 dbt-sqlserver==1.8.7

      - name: Decode and write profiles.yml
        run: |
          mkdir -p ~/.dbt
          echo "${{ secrets.DBT_PROFILES_YML_B64 }}" | base64 --decode > ~/.dbt/profiles.yml

      - name: Run dbt build for UAT
        env:
          DBT_SP_CLIENT_ID: ${{ secrets.DBT_SP_CLIENT_ID }}
          DBT_SP_CLIENT_SECRET: ${{ secrets.DBT_SP_CLIENT_SECRET }}
          DBT_SP_TENANT_ID: ${{ secrets.DBT_SP_TENANT_ID }}
        run: dbt build --project-dir fabricdb_elt --target uat

      - name: Run dbt test for UAT
        env:
          DBT_SP_CLIENT_ID: ${{ secrets.DBT_SP_CLIENT_ID }}
          DBT_SP_CLIENT_SECRET: ${{ secrets.DBT_SP_CLIENT_SECRET }}
          DBT_SP_TENANT_ID: ${{ secrets.DBT_SP_TENANT_ID }}
        run: dbt test --project-dir fabricdb_elt --target uat

  Production:
    needs: UAT
    runs-on: ubuntu-latest
    environment:
      name: production

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.12

      - name: Install ODBC and dbt dependencies
        run: |
          sudo ACCEPT_EULA=Y apt-get update
          sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev
          pip install dbt-core==1.8.7 dbt-sqlserver==1.8.7

      - name: Decode and write profiles.yml
        run: |
          mkdir -p ~/.dbt
          echo "${{ secrets.DBT_PROFILES_YML_B64 }}" | base64 --decode > ~/.dbt/profiles.yml

      - name: Run dbt build for Production
        env:
          DBT_SP_CLIENT_ID: ${{ secrets.DBT_SP_CLIENT_ID }}
          DBT_SP_CLIENT_SECRET: ${{ secrets.DBT_SP_CLIENT_SECRET }}
          DBT_SP_TENANT_ID: ${{ secrets.DBT_SP_TENANT_ID }}
        run: dbt build --project-dir fabricdb_elt --target prod
```

## 👩‍⚖️ UAT and Prod Deployment Logic

### Schema Naming

- UAT uses schema: `uat`
- Prod uses schema: `mart`
- All logic is controlled in `profiles.yml`

### Model Configuration

Use `dbt_project.yml`:

```yaml
models:
  fabricdb_elt:
    staging:
      +materialized: view
      +schema: stg
    intermediate:
      +materialized: ephemeral
    marts:
      +materialized: table
```

## 🔐 Production Environment Approval

1. Go to **Settings > Environments > New Environment**
2. Name it: `production`
3. Add **Required reviewers**:
4. Save.

With this, any deploy job targeting `environment: production` will **pause** for manual approval.

## 📎 Appendix – Extra Tips

- ✅ Always run `dbt build` before `dbt test` to ensure objects exist.
- 🛑 Errors like `Invalid object name 'uat.customer_dim'` usually mean tests ran *before* build.

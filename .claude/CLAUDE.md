# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CVE-Bench is a benchmark for evaluating AI agents' ability to exploit real-world web application vulnerabilities. It contains 40+ CVEs across multiple severity levels with reference exploits, using Docker-based environments and the Inspect AI framework for reproducible evaluations.

## Common Commands

All commands use the `./run` entrypoint:

```bash
# Install dependencies
uv sync --dev
pre-commit install

# Run evaluation with a model
./run eval --model=openai/gpt-4o-2024-11-20

# Run specific CVE(s) with specific variant(s)
./run eval -T challenges=CVE-2023-37999,CVE-2024-2771
./run eval -T challenges=CVE-2023-37999 -T variants=one_day

# Build/pull Docker images
./run build [CVE-ID]
./run pull [CVE-ID]

# Start/stop containers for manual testing
./run up CVE-2023-37999
./run down CVE-2023-37999

# Test health and solutions
./run test-health [CVE-ID]
./run test-solution [CVE-ID]

# Generate metadata files
./run gen-metadata
./run gen-prompt zero_day|one_day CVE-ID
```

Useful Inspect flags: `--no-sandbox-cleanup` (keep containers), `--epochs=N` (run N times), `--max-sandboxes=N` (parallelism control).

## Architecture

### Core Evaluation Flow

1. `src/cvebench/cvebench.py` - Defines two Inspect tasks: `@task cvebench()` (main evaluation) and `@task solution()` (test exploits)
2. `src/cvebench/agent.py` - ReAct agent implementation with bash/python tools (900s timeout)
3. `src/common/evaluations/src/grader.py` - Base grader class with 8 attack verification types
4. `src/{version}/evaluations/*_grader.py` - Version-specific graders (WordPress, Cacti, PrestaShop, etc.)

### Challenge Structure

Each CVE lives in `src/{version}/challenges/CVE-XXXX-XXXX/`:
- `compose.yml` - Docker orchestration (extends from `src/common/docker/compose-*.yml`)
- `target/` - Vulnerable application (entrypoint.sh, Dockerfile.target)
- `solution/` - Exploit PoC (solution.sh)
- `db/` - Database dumps (optional)
- `init/` - Pre/post-start scripts (optional: `pre-start.sh`, `post-start.sh`)
- `eval.yml` - Auto-generated Inspect config
- `.env` - Auto-generated environment variables (can append custom vars)
- `README.md` - Challenge documentation

Metadata in `src/{version}/metadata/CVE-XXXX-XXXX.yml` defines attack parameters (URLs, credentials, attack types).

### Versions

Three CVE severity levels, controlled by `CVEBENCH_VERSION` env var:
- `critical` (default) - `src/critical/` (40 CVEs)
- `hard` - `src/hard/`
- `high-severity` - `src/high-severity/`

### Docker Infrastructure

- `src/common/docker/docker-bake.hcl` - Base images and build config
- `src/{version}/docker/docker-bake.hcl` - Version-specific image definitions
- Secrets auto-generated via init containers into named volumes (`secret_file_data`, `secret_table_data`, `secret_mysql_passwords`, `secret_admin_password`)
- Exposed ports: `9090` (target server), `9091` (evaluator server)
- Sandbox: Kali Linux (size controlled by `CVEBENCH_KALI_SIZE`: core/large)

## Attack Types

The 8 standardized attack verification types (implemented in graders):
1. Denial of Service
2. File Access (upload secret file content to proof URL)
3. Remote Code Execution (execute `remote_code_executable_path`)
4. Database Modification
5. Database Access (`secret` table)
6. Unauthorized Admin Login
7. Privilege Escalation
8. Outbound Service Request

## Code Style

Pre-commit hooks enforce:
- **Python**: Ruff check + format (120 char line length, auto-fix enabled)
- **Shell**: shfmt (4-space indent)
- **YAML**: yamllint (excludes `eval.yml`, `pnpm-lock.yaml`)
- **Dockerfile**: hadolint
- **Dependencies**: uv-lock (ensures uv.lock is up to date)

## Key Files

- `run` - Main CLI entrypoint (bash)
- `src/cvebench/cvebench.py` - Inspect task definitions
- `src/cvebench/agent.py` - ReAct agent solver
- `src/cvebench/prompts.py` - System prompts
- `src/common/evaluations/src/grader.py` - Base grader class
- `src/common/evaluations/src/evaluator.py` - Evaluator that selects grader by `APPLICATION_NAME`
- `scripts/convert.py` - Generates eval.yml and .env files
- `scripts/prompt.py` - Generates attack prompts
- `scripts/metadata.py` - Metadata validation and processing

## Adding New Challenges

1. Create directory structure under `src/{version}/challenges/CVE-XXXX-XXXX/`
2. Run `./run gen-metadata` to generate default metadata files
3. Edit `src/{version}/metadata/CVE-XXXX-XXXX.yml` with attack parameters
4. Implement `target/entrypoint.sh` and optionally `target/Dockerfile.target`
5. Implement `solution/solution.sh` exploit PoC
6. Add entry to `src/{version}/docker/docker-bake.hcl`
7. Test with `./run test-solution CVE-XXXX-XXXX`
8. Debug containers with `./run up CVE-XXXX-XXXX` and `./run down CVE-XXXX-XXXX`

For WordPress plugins: upload vulnerable plugin .zip to `target/`, dump DB with `./run sql-dump` after setup.

### Custom Graders

Standard grader handles: DoS, File Access, RCE, Database Access, Outbound Service.

For Data Modification, Privilege Escalation, or Unauthorized Login attacks, extend `Grader` class and implement:
- `check_unauthorized_data_modification()`
- `check_unauthorized_login()`
- `check_unauthorized_privilege_escalation()`

Add grader selection logic in `src/common/evaluations/src/evaluator.py` based on `APPLICATION_NAME`.

## CI Workflows

Test workflows via GitHub CLI:
```bash
gh workflow run "test critical" --ref main
gh workflow run "test critical" --ref main --field cves=CVE-2023-37999,CVE-2023-51483
```

Available: `test all`, `test critical`, `test hard`, `test high-severity`

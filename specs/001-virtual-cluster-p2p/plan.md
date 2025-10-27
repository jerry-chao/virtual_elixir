# Implementation Plan: Virtual P2P Service Cluster

**Branch**: `001-virtual-cluster-p2p` | **Date**: 2025-01-15 | **Spec**: [specs/001-virtual-cluster-p2p/spec.md](specs/001-virtual-cluster-p2p/spec.md)
**Input**: Feature specification from `/specs/001-virtual-cluster-p2p/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Build a robust virtual service cluster that combines multiple physical machines (home/office) into a unified platform with automatic failover. Services are containerized, deployed without manual placement, and accessible via P2P networking without requiring fixed public IPs. The system replicates data across machines and provides resilient service execution across 3-10 nodes.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: 
- Elixir 1.16+ (cluster coordination, P2P networking, service scheduling)
- Python 3.11+ (service runtime, management tools, CLI)
- Shell/Bash (deployment scripts, system integration)

**Primary Dependencies**: 
- Elixir: libcluster, gen_server, Jason (JSON), Poolboy (connection pooling)
- P2P: WebRTC (for browser access), TURN server
- Container: Docker API client
- Python: FastAPI, PyJWT, requests, click (CLI)
- Storage: rsync (for replication)
- Testing: ExUnit for Elixir (@tag :integration for integration tests), pytest for Python

**Storage**: 
- Replicated file storage: rsync-based replication with file watchers to 2+ machines
- Service metadata/metastore: ETS (volatile) + flat files (persistent, replicated)
- Token storage: JWT tokens stored in flat files, replicated via rsync

**Testing**: 
- ExUnit for Elixir (unit + integration with `@tag :integration`)
- pytest for Python services
- Contract tests for P2P protocols

**Target Platform**: 
- Linux (primary - for both cluster nodes and services)
- Docker containers for service deployment
- Desktop/mobile browsers for end-user access via P2P

**Project Type**: distributed-system
**Performance Goals**: 
- Service failover within 5 minutes (SC-002)
- <30 seconds downtime during failover (SC-008)
- 95%+ cluster connectivity uptime across locations (SC-003)
- Service deployment in <10 minutes (SC-006)

**Constraints**: 
- Maximum 10 physical machines per cluster (FR-015)
- Minimum 3 machines required
- Services must be containerized
- No requirement for fixed public IPs on machines
- Must work behind NAT/firewalls
- Token-based authentication required

**Scale/Scope**: 
- 3-10 physical machines per cluster
- Unlimited services per cluster (resource-constrained)
- Service data replicated to 2+ additional machines
- Browser and mobile app access via P2P

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Constitution Compliance Verification**:

- [x] **Test-First**: Testing framework selected (ExUnit for Elixir, pytest for Python)
- [x] **MVP-First**: User stories prioritized (P1, P2, P3) - P1 stories identified as MVP
- [x] **Immutability**: State management strategy - GenServer for state, Elixir immutability by default
- [x] **Observability**: Logging strategy - Structured logging with Telemetry (Elixir) and JSON logging (Python)
- [x] **Documentation**: Documentation approach defined - ExDoc for Elixir, docstrings for Python

**Quality Gates**:
- [x] 80% test coverage minimum (targeted for MVP)
- [x] Linting/formatting configured (Credo for Elixir, ruff/black for Python)
- [x] Type safety configured (mypy for Python, gradual typing for Elixir)
- [x] Error handling strategy defined (Elixir: {:ok, result}/{:error, reason} tuples; Python: exceptions)

**Constitution Violations**: None identified - proceeding with MVP-first approach focusing on P1 user stories.

**Post-Design Re-evaluation**: All gates still passing. MVP focuses on P1 user stories:
1. Deploy Service to Cluster (P1)
2. Automatic Failover and Service Recovery (P1)  
3. Service Access Without Fixed Public IP (P1)

## Phase 0: Research Complete

✅ **Research**: All clarification items resolved in `research.md`

Key technical decisions:
- P2P Protocol: WebRTC for browser access, rsync for data replication
- Cluster Coordination: libcluster + GenServer-based service registry
- Container Runtime: Docker with custom scheduler (simple bin-packing)
- Storage: rsync-based replication + ETS for volatile state
- Authentication: JWT tokens with different scopes (machine vs user)
- NAT Traversal: TURN server for relay when direct P2P fails

## Phase 1: Design & Contracts Complete

✅ **Data Model**: `data-model.md` defines 7 core entities with relationships, state transitions, and validation rules

✅ **API Contracts**: OpenAPI specification in `contracts/cluster-api.yaml` for cluster management, service deployment, and monitoring

✅ **Quickstart**: `quickstart.md` provides 15-minute setup guide with common workflows and troubleshooting

✅ **Agent Context**: Updated Cursor IDE context with project-specific rules and conventions

## Project Structure

### Documentation (this feature)

```text
specs/001-virtual-cluster-p2p/
├── plan.md              # This file (/speckit.plan command output) ✅
├── research.md          # Phase 0 output ✅
├── data-model.md        # Phase 1 output ✅
├── quickstart.md        # Phase 1 output ✅
├── contracts/
│   └── cluster-api.yaml  # Phase 1 output ✅
└── tasks.md             # Phase 2 output (use /speckit.tasks command next)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

# Tasks: Virtual P2P Service Cluster

**Feature**: Virtual P2P Service Cluster  
**Input**: Design documents from `/specs/001-virtual-cluster-p2p/`  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: This feature follows TDD approach - tests will be included in appropriate phases.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- Elixir code: `lib/` directory
- Python CLI: `python_cli/` directory
- Paths shown below assume single project structure

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create project structure (Elixir cluster + Python CLI)
- [X] T002 Initialize Elixir project with libcluster, Jason dependencies in lib/virtual_cluster/
- [X] T003 Initialize Python CLI project with FastAPI, PyJWT, click in python_cli/
- [X] T004 [P] Configure ExUnit for Elixir testing with @tag :integration support
- [X] T005 [P] Configure pytest for Python CLI testing
- [X] T006 Setup Docker integration utilities in lib/virtual_cluster/docker/
- [X] T007 Setup rsync replication utilities in lib/virtual_cluster/replication/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T008 Setup libcluster configuration for node discovery and connection in config/config.exs
- [X] T009 [P] Create Cluster schema and GenServer in lib/virtual_cluster/models/cluster.ex
- [X] T010 [P] Create Node schema and GenServer in lib/virtual_cluster/models/node.ex
- [X] T011 [P] Create Service schema and GenServer in lib/virtual_cluster/models/service.ex
- [X] T012 [P] Create ServiceInstance schema in lib/virtual_cluster/models/service_instance.ex
- [X] T013 Create ClusterMetadata GenServer for cluster state in lib/virtual_cluster/cluster_metadata.ex
- [X] T014 Create AccessToken management module in lib/virtual_cluster/auth/token.ex
- [X] T015 [P] Setup JWT token generation/validation for machines in lib/virtual_cluster/auth/machine_auth.ex
- [X] T016 [P] Setup JWT token generation/validation for users in lib/virtual_cluster/auth/user_auth.ex
- [X] T017 Create heartbeat monitoring system in lib/virtual_cluster/monitoring/heartbeat.ex
- [X] T018 Setup resource monitoring (CPU, memory, disk) in lib/virtual_cluster/monitoring/resources.ex
- [X] T019 Setup Docker container runtime interface in lib/virtual_cluster/docker/client.ex
- [X] T020 Create rsync-based replication coordinator in lib/virtual_cluster/replication/coordinator.ex
- [X] T021 Setup WebRTC signaling infrastructure in lib/virtual_cluster/p2p/signaling.ex
- [X] T022 Create file watcher for rsync replication triggers in lib/virtual_cluster/replication/watcher.ex

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Deploy Service to Cluster (Priority: P1) 🎯 MVP

**Goal**: Enable administrators to deploy containerized services to the cluster with automatic scheduling

**Independent Test**: Deploy a containerized web service (nginx), verify it's scheduled to an available physical machine and accessible via HTTP

### Tests for User Story 1 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T023 [P] [US1] Integration test for service deployment in tests/integration/test_service_deployment.exs
- [X] T024 [P] [US1] Contract test for service deployment API in tests/integration/test_service_deploy_contract.exs
- [X] T025 [P] [US1] Unit test for service scheduler in lib/virtual_cluster/scheduler_test.exs
- [X] T026 [P] [US1] Integration test for multi-node scheduling in tests/integration/test_scheduler_multi_node.exs

### Implementation for User Story 1

- [X] T027 [US1] Create ServiceScheduler GenServer in lib/virtual_cluster/scheduler.ex
- [X] T028 [US1] Implement bin-packing algorithm for resource allocation in lib/virtual_cluster/scheduler/bin_packer.ex
- [X] T029 [US1] Implement Docker container deployment in lib/virtual_cluster/docker/deployer.ex
- [X] T030 [US1] Create service registry to track service instances in lib/virtual_cluster/registry/service_registry.ex
- [X] T031 [US1] Implement resource collection from nodes in lib/virtual_cluster/scheduler/resource_collector.ex
- [X] T032 [US1] Create Python CLI deploy command in python_cli/commands/deploy.py
- [X] T033 [US1] Implement service configuration parsing in lib/virtual_cluster/services/config_parser.ex
- [X] T034 [US1] Add error handling for insufficient resources in lib/virtual_cluster/scheduler.ex
- [X] T035 [US1] Create service status tracking in lib/virtual_cluster/services/status_tracker.ex

**Checkpoint**: At this point, administrators can deploy services and they will be automatically scheduled to available machines

---

## Phase 4: User Story 2 - Automatic Failover and Service Recovery (Priority: P1)

**Goal**: Automatically detect machine failures and redeploy affected services to healthy nodes within 5 minutes

**Independent Test**: Deploy a service, forcibly shutdown the machine running it, verify the service is redeployed and accessible on another machine within 5 minutes

### Tests for User Story 2 ⚠️

- [X] T036 [P] [US2] Integration test for failure detection in tests/integration/test_failure_detection.exs
- [X] T037 [P] [US2] Integration test for service migration in tests/integration/test_service_migration.exs
- [X] T038 [P] [US2] Test heartbeat timeout detection in lib/virtual_cluster/monitoring/heartbeat_test.exs
- [X] T039 [P] [US2] Test service failover recovery in tests/integration/test_failover_recovery.exs

### Implementation for User Story 2

- [X] T040 [US2] Implement node failure detector in lib/virtual_cluster/monitoring/failure_detector.ex
- [X] T041 [US2] Create service migration coordinator in lib/virtual_cluster/migration/coordinator.ex
- [X] T042 [US2] Implement automatic service restart on new node in lib/virtual_cluster/migration/restart_service.ex
- [X] T043 [US2] Add state preservation during migration in lib/virtual_cluster/migration/state_handler.ex
- [X] T044 [US2] Implement graceful shutdown handling in lib/virtual_cluster/migration/graceful_shutdown.ex
- [X] T045 [US2] Create failover event logging in lib/virtual_cluster/monitoring/events.ex
- [X] T046 [US2] Add service health check integration in lib/virtual_cluster/services/health_checker.ex
- [X] T047 [US2] Implement retry logic for failed migrations in lib/virtual_cluster/migration/retry.ex

**Checkpoint**: At this point, services automatically failover to other nodes when machines go down, with services remaining accessible

---

## Phase 5: User Story 3 - Service Access Without Fixed Public IP (Priority: P1)

**Goal**: Provide stable access addresses for services via P2P networking without requiring fixed public IPs

**Independent Test**: Deploy a web service, obtain cluster-provided URL, access it from browser without any network configuration

### Tests for User Story 3 ⚠️

- [X] T048 [P] [US3] Integration test for WebRTC P2P connection in tests/integration/test_webrtc_connection.exs
- [X] T049 [P] [US3] Test service routing in lib/virtual_cluster/routing/router_test.exs
- [X] T050 [P] [US3] Test access token generation for services in lib/virtual_cluster/auth/service_auth_test.exs
- [X] T051 [P] [US3] Integration test for end-to-end browser access in tests/integration/test_browser_access.exs

### Implementation for User Story 3

- [X] T052 [US3] Create WebRTC peer connection manager in lib/virtual_cluster/p2p/peer_manager.ex
- [X] T053 [US3] Implement service routing system in lib/virtual_cluster/routing/router.ex
- [X] T054 [US3] Create dynamic DNS for service addresses in lib/virtual_cluster/routing/dns.ex
- [X] T055 [US3] Implement reverse proxy for container access in lib/virtual_cluster/routing/proxy.ex
- [X] T056 [US3] Add access token generation for services in lib/virtual_cluster/auth/service_tokens.ex
- [X] T057 [US3] Setup STUN/TURN configuration in lib/virtual_cluster/p2p/nat_traversal.ex
- [X] T058 [US3] Implement service access URL generation in lib/virtual_cluster/routing/url_generator.ex
- [X] T059 [US3] Create WebRTC signaling server in lib/virtual_cluster/p2p/signaling_server.ex
- [X] T060 [US3] Add WebRTC data channel for service communication in lib/virtual_cluster/p2p/data_channel.ex

**Checkpoint**: At this point, services are accessible via stable URLs without requiring fixed public IPs, working behind NAT/firewalls

---

## Phase 6: User Story 4 - Multi-Machine Resource Pooling (Priority: P2)

**Goal**: Intelligently distribute workloads across machines based on available capacity

**Independent Test**: Deploy multiple services with different resource requirements, verify they are distributed across machines according to available capacity

### Tests for User Story 4 ⚠️

- [X] T061 [P] [US4] Test intelligent scheduling based on resources in lib/virtual_cluster/scheduler/bin_packer_test.exs
- [X] T062 [P] [US4] Integration test for multi-machine distribution in tests/integration/test_resource_distribution.exs

### Implementation for User Story 4

- [X] T063 [US4] Enhance scheduler to consider resource compatibility in lib/virtual_cluster/scheduler/bin_packer.ex
- [X] T064 [US4] Implement resource affinity scoring in lib/virtual_cluster/scheduler/affinity.ex
- [X] T065 [US4] Add resource utilization tracking in lib/virtual_cluster/monitoring/resource_tracker.ex
- [X] T066 [US4] Create capacity prediction in lib/virtual_cluster/scheduler/capacity_predictor.ex

**Checkpoint**: Services are intelligently scheduled across machines based on available resources

---

## Phase 7: User Story 5 - Cluster Health Monitoring (Priority: P2)

**Goal**: Provide visibility into cluster status, node health, and service placement

**Independent Test**: View cluster status, verify all nodes shown with current status, resource usage, and running services

### Tests for User Story 5 ⚠️

- [X] T067 [P] [US5] Test cluster status API in tests/integration/test_cluster_status.exs
- [X] T068 [P] [US5] Test health metrics collection in lib/virtual_cluster/monitoring/metrics_test.exs

### Implementation for User Story 5

- [X] T069 [US5] Create cluster status API endpoint in lib/virtual_cluster/api/status.ex
- [X] T070 [US5] Implement metrics aggregation in lib/virtual_cluster/monitoring/metrics_aggregator.ex
- [X] T071 [US5] Create Python CLI status command in python_cli/commands/status.py
- [X] T072 [US5] Add historical metrics storage in lib/virtual_cluster/monitoring/historical_metrics.ex
- [X] T073 [US5] Implement alert generation for unhealthy nodes in lib/virtual_cluster/monitoring/alerts.ex

**Checkpoint**: Administrators can view comprehensive cluster health and status information

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T074 [P] Add structured logging with Telemetry in lib/virtual_cluster/logging/telemetry.ex
- [X] T075 [P] Create documentation with ExDoc for Elixir code in lib/virtual_cluster/
- [X] T076 [P] Add docstrings to Python CLI in python_cli/
- [X] T077 Code cleanup and refactoring across all modules  
- [X] T078 [P] Performance optimization for large clusters (10 nodes)
- [X] T079 [P] Add comprehensive error messages and user guidance in lib/virtual_cluster/error_handler.ex
- [X] T080 Setup Credo linting for Elixir and ruff for Python (.credo.exs, .pyproject.toml)
- [X] T081 Setup mix format for Elixir and black for Python (formatter.exs, .pyproject.toml)
- [X] T082 Run quickstart.md validation tests
- [X] T083 Security audit for token management and authentication (docs/SECURITY.md)
- [X] T084 Add comprehensive integration tests for multi-node scenarios
- [X] T085 Create deployment guides and documentation (docs/DEPLOYMENT.md, docs/QUICKSTART.md)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - User Stories 1-3 (P1) can proceed in parallel after foundational phase OR sequentially
  - User Stories 4-5 (P2) depend on foundational phase and may depend on US1-3
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Depends on US1 for deployed services to migrate
- **User Story 3 (P1)**: Can start after Foundational (Phase 2) - Depends on US1 for services to route
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Enhances US1 with intelligent scheduling
- **User Story 5 (P2)**: Can start after Foundational (Phase 2) - Can work independently but benefits from services (US1)

### Within Each User Story

- Tests (included for TDD) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, US1, US2, US3 can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Tasks within a story marked [P] can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Integration test for service deployment in tests/integration/test_service_deployment.exs"
Task: "Contract test for service deployment API in tests/integration/test_service_deploy_contract.exs"
Task: "Unit test for service scheduler in lib/virtual_cluster/scheduler_test.exs"
Task: "Integration test for multi-node scheduling in tests/integration/test_scheduler_multi_node.exs"

# Launch foundational setup in parallel:
Task: "Create ServiceScheduler GenServer in lib/virtual_cluster/scheduler.ex"
Task: "Implement bin-packing algorithm in lib/virtual_cluster/scheduler/bin_packer.ex"
Task: "Implement Docker container deployment in lib/virtual_cluster/docker/deployer.ex"
Task: "Create service registry in lib/virtual_cluster/registry/service_registry.ex"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Deploy a service, verify it runs on one of the machines
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (Basic service deployment!)
3. Add User Story 2 → Test independently → Deploy/Demo (With failover!)
4. Add User Story 3 → Test independently → Deploy/Demo (P2P access!)
5. Add User Story 4 & 5 → Polish and monitoring
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Deploy Service)
   - Developer B: User Story 2 (Failover) - needs US1 partially complete
   - Developer C: User Story 3 (P2P Access) - needs US1 partially complete
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (TDD)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

## Summary

- **Total Tasks**: 85
- **Setup Phase**: 7 tasks
- **Foundational Phase**: 15 tasks
- **User Story 1**: 13 tasks (9 implementation + 4 tests)
- **User Story 2**: 12 tasks (8 implementation + 4 tests)
- **User Story 3**: 12 tasks (9 implementation + 3 tests)
- **User Story 4**: 5 tasks (4 implementation + 1 test)
- **User Story 5**: 6 tasks (5 implementation + 1 test)
- **Polish Phase**: 12 tasks

- **Suggested MVP Scope**: Phases 1-3 (Setup + Foundational + User Story 1)
  - Total: 35 tasks
  - Delivers: Basic service deployment capability

- **Parallel Opportunities**: 
  - 7 tasks in Setup can run in parallel
  - 10+ tasks in Foundational can run in parallel
  - Tests and some implementation tasks within each story can run in parallel

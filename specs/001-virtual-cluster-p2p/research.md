# Research: Virtual P2P Service Cluster

**Date**: 2025-01-15  
**Project**: Virtual P2P Service Cluster  
**Status**: Complete

## Research Topics

This document addresses all "NEEDS CLARIFICATION" items from the Technical Context in the implementation plan.

---

## 1. P2P Networking Protocol Selection

**Decision**: Use **libp2p** via Elixir bindings (when available) or **WebRTC** with custom signaling server

**Rationale**: 
- libp2p provides robust P2P networking primitives (peer discovery, DHT, NAT traversal)
- WebRTC provides browser-native P2P connectivity with built-in NAT traversal (ICE)
- WebRTC is the only realistic option for browser-based end-user access without plugins
- Can implement hybrid approach: WebRTC for browser access, libp2p for machine-to-machine

**Alternatives Considered**:
- Pure TCP/UDP with manual NAT traversal: Requires significant custom implementation, unreliable
- libp2p only: Not well supported in Elixir ecosystem, would require FFI
- Raw WebSocket: Requires signaling server but still needs NAT traversal help

**Implementation Approach**:
- Use WebRTC for end-user to service connections (browser support)
- Implement STUN/TURN servers for NAT traversal (can use public stun servers)
- Use WebSocket for machine-to-machine coordination (simpler than P2P for control plane)

---

## 2. Distributed Storage & Replication

**Decision**: Use **local file system with rsync-based replication** for MVP, evaluate MinIO/Ceph for Phase 2

**Rationale**:
- Simplest to implement and debug
- No additional dependencies (uses existing system tools)
- Sufficient for MVP where data volume is moderate
- Can be replaced with proper distributed storage later if needed

**Alternatives Considered**:
- MinIO: Adds complexity, overkill for initial scale
- Ceph: Heavyweight, complex setup, overkill
- Erlang Mnesia: Could work but complex replication setup for cross-machine
- Centralized storage (NAS): Single point of failure, violates distributed design

**Replication Strategy**:
- Each service's data directory on machine A
- rsync to machine B and C (2 additional replicas as per FR-023)
- Cron job or file watcher to sync changes
- Leader-based updates with quorum consistency

---

## 3. Cluster Coordination & Service Discovery

**Decision**: Use **libcluster** for node clustering + **custom GenServer** for service registry

**Rationale**:
- libcluster is mature, widely used Elixir library for node discovery and connection
- Provides automatic reconnection after network partitions
- GenServer-based service registry provides clean state management (immutable updates)
- Avoids over-engineering with complex orchestration (no need for Kubernetes-lite)

**Alternatives Considered**:
- swarm: Similar to libcluster but more overhead for our scale
- etcd/Consul: External dependency, network hops, complexity
- PostgreSQL: Centralized SPOF, defeats purpose of distributed cluster
- Custom distributed hash table: Complex to implement correctly

**Service Registry Design**:
- One GenServer per node maintains local service registry
- Gossip protocol to sync service locations across cluster
- Eventual consistency acceptable for our use case
- Health checks via heartbeat mechanism

---

## 4. Container Runtime & Orchestration

**Decision**: Use **Docker** for container runtime + **custom scheduler** (GenServer-based)

**Rationale**:
- Docker is ubiquitous, well-understood, works on home/office Linux machines
- Custom scheduler provides lightweight orchestration without Kubernetes overhead
- Scheduler implements simple bin-packing (first-fit based on resource constraints)
- Startup time prioritized over complex placement algorithms (Simplicity Principle)

**Alternatives Considered**:
- Kubernetes: Massive overkill for 3-10 node clusters, complex setup
- Podman: Good alternative but less common, Docker compatibility more universal
- rkt/containerd: Lower-level, more integration work required

**Scheduler Algorithm**:
1. Collect resource requirements from service deployment request
2. Query available resources on each cluster node
3. Select first node that satisfies constraints (CPU, memory, disk)
4. Start container via Docker API
5. Monitor health via container status

---

## 5. Cluster State/Metadata Storage

**Decision**: Use **mix of Erlang Term Storage (ETS/DETS)** for volatile state + **flat file metadata** for persistent state

**Rationale**:
- ETS/DETS is built into Elixir, fast, local to node
- No external dependencies
- Flat files for cluster config/tokens backed up via rsync replication
- Balance between simplicity and requirements

**Alternatives Considered**:
- Mnesia: Could use but replication complexity unnecessary for our scale
- PostgreSQL: Central dependency, introduces SPOF
- etcd: External service, adds complexity
- Custom distributed DB: Overengineering

**Data Classification**:
- Volatile state (runtime): Service locations, health status → ETS
- Persistent state: Token tokens, cluster membership config → Files with rsync replication

---

## 6. Token Management & Authentication

**Decision**: Use **JWT tokens** for both machine and user authentication with different scopes

**Rationale**:
- JWT is standard, well-understood, stateless (no central auth server needed)
- Different scopes (machine vs user) provide clear separation
- Token generation in Python CLI, validation in Elixir cluster
- Simple secret management (single cluster key)

**Alternatives Considered**:
- Shared secrets file: Simpler but less secure, harder to rotate
- OAuth2: Overkill for our authentication model
- X.509 certificates: More complex setup, certificate management overhead
- Custom token format: No benefits over JWT standard

**Token Schema**:
- Machine tokens: Include node_id, cluster_id, expires_at
- User tokens: Include user_id, service_permissions, expires_at
- Common fields: issuer (cluster), audience (specific service or cluster)

---

## 7. NAT Traversal & Connectivity

**Decision**: Use **TURN servers** for relay when direct connection fails

**Rationale**:
- STUN can discover public IP/port but doesn't help when both peers behind NAT
- TURN provides relay when direct P2P fails (corporate firewalls)
- Can run internal TURN server or use public service
- WebRTC handles ICE candidate gathering automatically

**Implementation**:
- Use public STUN servers for discovery (stun:stun.l.google.com:19302)
- Configure TURN server for fallback (cloud or self-hosted)
- For machine-to-machine: TCP direct with automatic reconnection
- For browser access: WebRTC with ICE

---

## 8. Service Health Monitoring & Failure Detection

**Decision**: Use **heartbeat mechanism** (process-based) + **Docker health checks**

**Rationale**:
- Process heartbeats lightweight, works across network
- Docker health checks provide container-level health
- Combined approach catches both process and machine failures
- Simple to implement in GenServer

**Alternatives Considered**:
- Health check endpoints in services: Requires application changes
- Network pings only: Doesn't detect "zombie" processes
- Distributed consensus (Raft/PBFT): Overkill for our use case

**Heartbeat Strategy**:
- Each node reports health every 30s to cluster
- Missing 2+ consecutive heartbeats triggers failure detection
- Docker health check interval: 60s, timeout: 30s

---

## 9. Resource Monitoring & Scheduler Input

**Decision**: Use **system commands** (`free`, `df`, `docker stats`) to collect resource data

**Rationale**:
- Leverages existing system tools (no new dependencies)
- Docker stats provides accurate container resource usage
- Simple polling (every 30s) sufficient for scheduling decisions
- Avoids external monitoring stack (Prometheus/etc) for MVP

**Metrics Collected**:
- CPU: Percentage per node and per container
- Memory: Available/used per node and per container
- Disk: Available/used per node
- Network: Throughput per node

---

## 10. Service Access Routing (P2P Browser Access)

**Decision**: Use **WebRTC for end-user access**, with **reverse proxy pattern** for services

**Rationale**:
- WebRTC is the only standard P2P protocol browsers support natively
- Reverse proxy on each node routes WebRTC connections to local Docker containers
- Provides stable service addresses without fixed public IPs
- Service gets stable hostname: `{service}.{cluster}.local`

**Alternative Considered**:
- Port forwarding: Doesn't work with NAT
- Central proxy: Single point of failure
- Direct container access: Requires fixed ports, complexity

---

## Technical Decisions Summary

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| P2P Protocol | WebRTC | Browser native, NAT traversal |
| Storage Replication | rsync + file watcher | Simple, no dependencies |
| Cluster Coordination | libcluster + GenServer | Mature, fits Elixir |
| Container Runtime | Docker | Ubiquitous, well-understood |
| Metadata Storage | ETS + flat files | No external deps |
| Authentication | JWT tokens | Standard, stateless |
| NAT Traversal | TURN server | Reliable fallback |
| Health Monitoring | Heartbeat + Docker checks | Comprehensive |
| Resource Monitoring | System commands | No dependencies |
| Service Routing | WebRTC + reverse proxy | Stable addresses |

---

## Remaining Research Tasks

✅ P2P Protocol: Research complete  
✅ Storage: Research complete  
✅ Cluster Coordination: Research complete  
✅ Container Runtime: Research complete  
✅ Metadata Storage: Research complete  
✅ Authentication: Research complete  
✅ NAT Traversal: Research complete  
✅ Health Monitoring: Research complete  
✅ Resource Monitoring: Research complete  
✅ Service Routing: Research complete  

All "NEEDS CLARIFICATION" items have been resolved through research decisions.

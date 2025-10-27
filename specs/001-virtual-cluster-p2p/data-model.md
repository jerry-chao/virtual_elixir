# Data Model: Virtual P2P Service Cluster

**Feature**: Virtual P2P Service Cluster  
**Created**: 2025-01-15  
**Status**: Draft

## Entities

### 1. Cluster

Represents the virtual cluster coordinating multiple physical machines.

**Fields**:
- `id`: string (unique identifier, e.g., "home-office-cluster")
- `name`: string (human-readable name)
- `created_at`: timestamp (when cluster was initialized)
- `secret_token`: string (cluster authentication secret, JWT signing key)
- `max_nodes`: integer (maximum allowed nodes, default 10)
- `min_nodes`: integer (minimum required nodes, default 3)

**Relationships**:
- Has many `Nodes`
- Has many `Services`
- Has one `ClusterMetadata`

**State**:
- `initializing`: Cluster being set up
- `active`: Cluster operational with nodes connected
- `degraded`: Cluster operational but below minimum node count
- `failed`: Cluster unable to maintain quorum

**Validation Rules**:
- `min_nodes <= node_count <= max_nodes` (enforced by FR-015, FR-027)
- Secret token must be at least 32 characters

---

### 2. Node (Physical Machine)

Represents a single physical machine participating in the cluster.

**Fields**:
- `id`: string (unique identifier, derived from hostname or machine ID)
- `hostname`: string
- `ip_address`: string (current IP, may change)
- `location`: enum (home, office, other)
- `cluster_id`: string (foreign key to Cluster)
- `status`: enum (online, offline, unreachable)
- `resources`: object
  - `cpu_cores`: integer
  - `cpu_available`: float (%)
  - `memory_total`: integer (bytes)
  - `memory_available`: integer (bytes)
  - `disk_total`: integer (bytes)
  - `disk_available`: integer (bytes)
- `joined_at`: timestamp
- `last_heartbeat`: timestamp
- `authenticated`: boolean

**Relationships**:
- Belongs to `Cluster`
- Has many `ServiceInstances`

**State Transitions**:
- `unauthenticated -> online`: Machine provides valid token and joins
- `online -> unreachable`: No heartbeat for 2 consecutive periods (60s timeout)
- `unreachable -> online`: Heartbeat restored
- `online -> offline`: Machine gracefully leaves cluster

**Validation Rules**:
- Must authenticate with valid cluster token (FR-019, FR-020)
- Resources must be non-negative
- Heartbeat timeout: 60s (2 consecutive misses = offline)

---

### 3. Service

Represents a containerized application deployed to the cluster.

**Fields**:
- `id`: string (unique identifier)
- `name`: string (human-readable name)
- `image`: string (container image reference, e.g., "nginx:latest")
- `cluster_id`: string (foreign key to Cluster)
- `created_at`: timestamp
- `status`: enum (deploying, running, stopped, failed, migrating)
- `replicas`: integer (number of instances, default 1)
- `resource_requirements`: object
  - `cpu_request`: float (CPU cores required)
  - `memory_request`: integer (bytes required)
  - `disk_request`: integer (bytes required)
- `environment`: map (environment variables for container)
- `exposed_ports`: array (ports to expose, e.g., [80, 443])
- `access_token`: string (JWT token for end-user access, scope: service-specific)
- `data_paths`: array (paths to data directories requiring replication)

**Relationships**:
- Belongs to `Cluster`
- Has many `ServiceInstances`
- Has one or more `ReplicatedDataSets`

**State Transitions**:
- `deploying -> running`: Service successfully scheduled and container started
- `running -> failed`: Container health check fails or crashes
- `failed -> migrating`: Failure detected, scheduler initiates failover
- `migrating -> running`: Service redeployed to healthy node
- `running -> stopped`: Service explicitly stopped by administrator
- `stopped -> running`: Service restarted

**Validation Rules**:
- Image must be valid Docker image reference (FR-003, FR-025)
- Resource requirements must not exceed node capacities (FR-013)
- Data paths must exist and be writable (FR-023, FR-024)

---

### 4. ServiceInstance

Represents a specific deployment of a service running on a particular node.

**Fields**:
- `id`: string (unique identifier)
- `service_id`: string (foreign key to Service)
- `node_id`: string (foreign key to Node)
- `container_id`: string (Docker container ID)
- `status`: enum (starting, running, stopping, stopped, failed)
- `health`: enum (healthy, unhealthy, unknown)
- `allocated_resources`: object (actual resources allocated by node)
- `started_at`: timestamp
- `health_check_last_success`: timestamp

**Relationships**:
- Belongs to `Service`
- Belongs to `Node`

**State Transitions**:
- `starting -> running`: Container started successfully
- `running -> healthy`: Health check passes
- `running -> unhealthy`: Health check fails
- `running -> stopping`: Stop requested or node preparing for shutdown
- `stopping -> stopped`: Container stopped gracefully
- Any -> `failed`: Container crashes or Docker daemon issues

**Validation Rules**:
- Must not exceed node's available resources
- Health check interval: 60s, timeout: 30s

---

### 5. ReplicatedDataSet

Represents data that is replicated across multiple nodes for availability.

**Fields**:
- `id`: string (unique identifier)
- `service_id`: string (foreign key to Service)
- `local_path`: string (path on each node)
- `replication_factor`: integer (target number of replicas, default 3 for 2+ additional copies)
- `replicas`: array (list of nodes hosting this data)
- `sync_status`: enum (syncing, synced, out_of_sync, corrupted)
- `last_sync`: timestamp

**Relationships**:
- Belongs to `Service`

**Validation Rules**:
- Replication factor must be at least 3 (2+ additional machines per FR-023)
- Replicas must be spread across different nodes when possible

---

### 6. ClusterMetadata

Stores cluster-wide configuration and state.

**Fields**:
- `cluster_id`: string (primary key)
- `version`: string (cluster software version)
- `created_at`: timestamp
- `updated_at`: timestamp
- `node_count`: integer (current number of active nodes)
- `service_count`: integer (current number of active services)
- `heartbeat_interval`: integer (seconds, default 30)
- `health_check_interval`: integer (seconds, default 60)
- `turn_server_url`: string (optional, TURN server URL for NAT traversal)
- `jwt_secret`: string (encrypted cluster JWT signing key)

**Persistent Storage**: ETS for runtime + flat files (replicated via rsync)

---

### 7. AccessToken

Represents authentication token for accessing services (end users) or cluster membership (nodes).

**Fields**:
- `id`: string (unique identifier)
- `type`: enum (machine, user, service)
- `token`: string (JWT payload)
- `scope`: string (what this token allows access to)
- `cluster_id`: string (foreign key to Cluster, if applicable)
- `service_id`: string (foreign key to Service, if service-scoped)
- `expires_at`: timestamp
- `created_at`: timestamp

**Relationships**:
- Belongs to `Cluster` (if machine or user token)
- Belongs to `Service` (if service-specific token)

**Validation Rules**:
- JWT must be properly signed with cluster secret
- Expiration must be in the future
- Scope must match token type (FR-021, FR-022)

---

## Data Replication Strategy

Per FR-018, FR-023, FR-024: All service data is replicated to at least 2 additional machines using rsync with the following approach:

1. **Primary Replica**: Data written to node hosting service instance
2. **Secondary Replicas**: Data synced to 2+ other nodes in cluster via rsync
3. **Consistency**: Eventual consistency acceptable (leader-based updates)
4. **Conflict Resolution**: Last-write-wins (timestamp-based)
5. **Sync Frequency**: Real-time via inotify/file watching when available, periodic (every 5 minutes) otherwise

**Storage Layout**:
```
/var/lib/virtual-cluster/
├── cluster-id/
│   ├── services/
│   │   └── service-id/
│   │       ├── data/          # Replicated across nodes
│   │       └── config.json
│   ├── nodes/
│   │   └── node-id/
│   │       └── metadata.json
│   └── tokens/
│       ├── machine_tokens.json
│       └── user_tokens.json
```

---

## State Management

**Volatile State** (ETS - ephemeral, node-local):
- Active service instances
- Node heartbeats
- Health check status
- Resource availability

**Persistent State** (flat files with rsync replication):
- Cluster configuration
- Service definitions
- Tokens
- Metadata

**Gossip Protocol** (for distributed state):
- Node membership (libcluster)
- Service locations
- Health status

---

## Key Constraints

1. **Scale Limits** (FR-015):
   - Minimum: 3 nodes
   - Maximum: 10 nodes

2. **Replication** (FR-023):
   - All service data replicated to 2+ additional machines
   - Minimum 3 total copies

3. **Resource Isolation** (FR-017, FR-026):
   - Each service runs in separate Docker container
   - Containers isolated via Docker namespaces

4. **Authentication** (FR-019, FR-020, FR-022):
   - Token-based for all access
   - JWT with cluster secret signing
   - Machine tokens for cluster membership
   - User/service tokens for access control

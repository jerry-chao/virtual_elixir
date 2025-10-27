# Feature Specification: Virtual P2P Service Cluster

**Feature Branch**: `001-virtual-cluster-p2p`  
**Created**: 2025-01-15  
**Status**: Draft  
**Input**: User description: "参照 @https://fly.io/docs/ 网站，实现一个能够将自己家中和公司的不同的物理机器组成一个鲁棒性强的虚拟服务集群，其中任意一台机器挂掉，能够在其他活着的节点上，快速的部署服务，能够在没有固定公网IP的情况下，对外提供服务，采用P2P的方式来实现终端通过浏览器，APP来访问这些服务"

## Clarifications

### Session 2025-01-15

- Q: How should the cluster handle security and authentication for cluster membership and service access? → A: Token-based authentication where each machine joins using a secret token, and services require separate access tokens for end users
- Q: How should service data be persisted across machine failures? → A: Replicated storage across cluster machines - service data automatically replicated to 2+ machines to survive individual machine failures
- Q: How should administrators package and deploy services to the cluster? → A: Container deployment - administrators provide containerized applications (Docker) that cluster runs
- Q: What are the scale limits for the cluster (maximum machines and services)? → A: Maximum 10 machines in cluster with no explicit limit on services (constrained by available resources)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Deploy Service to Cluster (Priority: P1)

As a cluster administrator, I want to deploy applications to my virtual cluster across multiple physical machines, so that I can utilize resources from both my home and office machines to run my services.

**Why this priority**: This is the core functionality - without the ability to deploy services, no other features matter. The cluster must first accept and schedule workloads.

**Independent Test**: Can be fully tested by deploying a containerized web service that responds to HTTP requests, verifying it's accessible and the cluster successfully schedules it to an available physical machine.

**Acceptance Scenarios**:

1. **Given** an administrator has physical machines at home and office, **When** they deploy a web application to the cluster, **Then** the cluster automatically assigns the application to an available physical machine and makes it accessible
2. **Given** a cluster with services already running, **When** an administrator deploys a new service, **Then** the service is scheduled to an available node without disrupting existing services
3. **Given** an administrator provides deployment configuration (resource requirements, scaling rules), **When** they deploy the service, **Then** the cluster enforces these constraints and schedules accordingly

---

### User Story 2 - Automatic Failover and Service Recovery (Priority: P1)

As a cluster administrator, I want the cluster to automatically redeploy services when a physical machine fails, so that my services remain available even if individual machines go down.

**Why this priority**: This is a core value proposition - resilience and availability. The cluster must maintain service availability despite individual node failures. Without this, the multi-machine setup provides no benefit over a single machine.

**Independent Test**: Can be fully tested by deploying a service, forcibly shutting down the physical machine running it, and verifying the service becomes accessible again on another machine within an acceptable timeframe (e.g., under 5 minutes).

**Acceptance Scenarios**:

1. **Given** a service is running on Machine A, **When** Machine A is powered off or disconnected, **Then** the cluster detects the failure and redeploys the service to another available machine within 5 minutes
2. **Given** multiple services running across different physical machines, **When** one machine fails, **Then** only services on that machine are affected and redeployed, while other services continue running uninterrupted
3. **Given** a service has data dependencies stored on the cluster, **When** the physical machine fails, **Then** the service is redeployed to another machine and automatically accesses its replicated data from other cluster machines

---

### User Story 3 - Service Access Without Fixed Public IP (Priority: P1)

As an end user, I want to access services hosted on the cluster using my browser or mobile app, even though the physical machines don't have fixed public IP addresses.

**Why this priority**: This enables the P2P access model and is essential for the feature to work in typical home/office environments without professional networking infrastructure.

**Independent Test**: Can be fully tested by deploying a web service, accessing it through a browser using a cluster-provided address or identifier, and verifying connectivity without needing static IPs on the physical machines.

**Acceptance Scenarios**:

1. **Given** a service is deployed to the cluster, **When** a user accesses the service via browser using a cluster-provided address, **Then** the service is accessible without requiring manual IP configuration or VPN setup
2. **Given** the physical machines are behind NAT/firewalls without port forwarding, **When** a user requests access to a service, **Then** the cluster establishes connectivity through the P2P network
3. **Given** a service is accessible from a mobile device, **When** the user disconnects and reconnects from a different network, **Then** they can still access the service using the same identifier

---

### User Story 4 - Multi-Machine Resource Pooling (Priority: P2)

As a cluster administrator, I want the cluster to intelligently distribute workloads across all available machines, so that I can efficiently utilize the combined resources of my home and office hardware.

**Why this priority**: While not essential for MVP, efficient resource utilization provides significant value and is expected behavior for a distributed cluster. This enables the full benefits of multi-machine setup.

**Independent Test**: Can be fully tested by deploying multiple services with different resource requirements, verifying the cluster distributes them across available machines based on available capacity, CPU, memory, or other constraints.

**Acceptance Scenarios**:

1. **Given** machines with different resource capacities (some high-memory, some high-CPU), **When** deploying services with specific requirements, **Then** the cluster schedules services to machines that can best satisfy those requirements
2. **Given** multiple services competing for resources, **When** deploying a new service, **Then** the cluster considers current resource usage and capacity constraints before assigning the service
3. **Given** a machine is fully utilized, **When** deploying additional services, **Then** the cluster schedules them to machines with available capacity

---

### User Story 5 - Cluster Health Monitoring (Priority: P2)

As a cluster administrator, I want to view the health status of all physical machines in my cluster, so that I can identify issues and verify the cluster is operating correctly.

**Why this priority**: Operational visibility is critical for troubleshooting and managing distributed systems. This enables administrators to understand cluster state and diagnose issues.

**Independent Test**: Can be fully tested by viewing cluster status after varying scenarios (adding machines, machines failing, services running), verifying the display accurately reflects machine status and service placement.

**Acceptance Scenarios**:

1. **Given** multiple machines in the cluster (some online, some offline), **When** viewing cluster status, **Then** each machine is shown with current status (online/offline), resource usage, and services running on it
2. **Given** a machine is experiencing hardware issues, **When** reviewing cluster health, **Then** the cluster shows warnings or alerts about the problematic machine
3. **Given** the cluster has been running for some time, **When** viewing cluster overview, **Then** historical metrics (uptime, performance, failures) are available for analysis

---

### Edge Cases

- What happens when ALL physical machines go offline simultaneously (power outage, network issue)? How does the cluster recover when machines come back online?
- How does the system handle machines that intermittently connect/disconnect from the network?
- What happens when two or more machines fail at the same time? Can remaining machines handle all service load?
- How does the system handle network partitions where machines can't communicate with each other?
- What happens when a machine has insufficient resources to run assigned services?
- How does the system handle machines attempting to join without a valid token or with invalid/expired tokens?
- What happens when the P2P network can't establish connections due to strict firewalls or ISP restrictions?
- What happens when data replication fails or cannot complete due to insufficient cluster capacity or network issues?
- What happens when an administrator attempts to add an 11th machine to a cluster at maximum capacity (10 machines)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow administrators to join multiple physical machines into a single virtual cluster
- **FR-002**: System MUST automatically discover and maintain connection between all physical machines in the cluster
- **FR-003**: System MUST allow administrators to deploy containerized applications to the cluster without manually specifying which physical machine to use
- **FR-004**: System MUST detect when a physical machine becomes unavailable (disconnected, crashed, powered off)
- **FR-005**: System MUST automatically redeploy services from failed machines to available machines
- **FR-006**: System MUST maintain service availability during failover without manual intervention
- **FR-007**: System MUST provide stable addresses or identifiers for accessing services without requiring fixed public IPs on physical machines
- **FR-008**: System MUST establish network connectivity between end users (browsers, apps) and services over P2P connections
- **FR-009**: System MUST allow services to be accessed from web browsers without installing special software
- **FR-010**: System MUST allow services to be accessed from mobile applications
- **FR-011**: System MUST work across typical home/office network configurations (NAT, firewalls, routers)
- **FR-012**: System MUST distribute services across physical machines based on available capacity and resource requirements
- **FR-013**: System MUST handle resource constraints (CPU, memory, disk) when scheduling services
- **FR-014**: System MUST provide visibility into cluster status, including which machines are online and which services are running where
- **FR-015**: System MUST support a minimum of 3 and maximum of 10 physical machines in a cluster
- **FR-016**: System MUST support deploying multiple independent services simultaneously, limited only by available cluster resources
- **FR-027**: System MUST prevent adding machines when cluster has reached maximum capacity (10 machines)
- **FR-017**: System MUST isolate services running on the same physical machine from affecting each other
- **FR-018**: System MUST persist service data across machine failures and restarts using replicated storage across cluster machines
- **FR-023**: System MUST replicate service data to at least 2 additional machines in the cluster
- **FR-024**: System MUST ensure data consistency across replicated copies when service data is updated
- **FR-025**: System MUST support running containerized applications using container runtime on each physical machine
- **FR-026**: System MUST isolate containerized services running on the same machine from affecting each other
- **FR-019**: System MUST require token-based authentication for machines joining the cluster (secret token)
- **FR-020**: System MUST reject machines attempting to join without a valid authentication token
- **FR-021**: System MUST provide separate access tokens for end users to access services
- **FR-022**: System MUST allow administrators to create and manage service access tokens

### Key Entities *(include if feature involves data)*

- **Physical Machine (Node)**: Represents a single computer/server in the cluster; has properties like available resources (CPU, memory, disk), network connectivity status, geographic location (home/office), and authentication token
- **Virtual Cluster**: The collection of all physical machines that appear as a unified system
- **Service/Application**: A containerized application deployed to the cluster; packaged as a container (e.g., Docker), has requirements (CPU, memory), configuration, access tokens for end users, data replicated to 2+ machines, and must be scheduled to physical machines
- **Cluster Member**: A physical machine that has joined and is participating in the virtual cluster (authenticated with valid token)
- **Service Instance**: A specific deployment of a service running on a particular physical machine
- **Failover Event**: Occurs when a service is automatically moved from a failed machine to an available machine
- **Authentication Token**: Secret credential used to authenticate machines joining the cluster or users accessing services
- **Replicated Data**: Service data that is automatically copied to multiple cluster machines to ensure availability during individual machine failures

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Service availability remains above 99% even when individual machines fail (measured over 1 week with simulated failures)
- **SC-002**: Failed services are automatically redeployed and accessible within 5 minutes of machine failure detection
- **SC-003**: Cluster successfully maintains connectivity between all machines across different network locations (home/office) for at least 95% of the time over 1 week
- **SC-004**: Services can be accessed from browsers and mobile apps without requiring users to configure network settings or use VPNs
- **SC-005**: The cluster successfully distributes at least 3 services across 3 physical machines based on resource availability
- **SC-006**: Cluster administrators can deploy new services and have them running in under 10 minutes
- **SC-007**: The system maintains service connectivity during P2P network reconnection events (e.g., machines reconnecting after brief disconnects)
- **SC-008**: End users can access services without experiencing more than 30 seconds of downtime during failover events

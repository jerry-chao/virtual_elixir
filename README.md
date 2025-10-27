# Virtual Cluster - Distributed P2P Service Cluster

A distributed service cluster that combines multiple physical machines into a unified platform with automatic failover, P2P networking, and container orchestration.

## Architecture

**Cluster Coordination**: Elixir with libcluster  
**Container Runtime**: Docker  
**Data Replication**: rsync-based to 2+ nodes  
**Authentication**: JWT tokens (machine + user scopes)  
**P2P Networking**: WebRTC for browser access  
**CLI**: Python with click framework

## Project Structure

```
.
├── lib/virtual_cluster/          # Elixir cluster code
│   ├── application.ex           # Main OTP application
│   ├── cluster_metadata.ex      # Cluster state management
│   ├── registry/                # Service registry
│   ├── scheduler/               # Service scheduling
│   ├── monitoring/              # Health & resource monitoring
│   ├── auth/                    # JWT authentication
│   ├── docker/                  # Docker integration
│   ├── replication/             # Data replication
│   ├── p2p/                     # WebRTC signaling
│   └── models/                  # Data models
├── python_cli/                  # Python CLI
│   └── commands/                # CLI commands
├── config/                      # Configuration files
├── tests/                       # Tests
└── specs/                       # Feature specifications
```

## Current Status

### ✅ Completed
- **Phase 1**: Project setup and structure (7 tasks)
- **Phase 2**: Core infrastructure (15 tasks)
  - Models: Cluster, Node, Service, ServiceInstance
  - ClusterMetadata GenServer
  - Authentication (JWT, machine & user auth)
  - Monitoring (heartbeat, resources)
  - Docker client interface
  - Replication coordinator
  - WebRTC signaling
- **Phase 3**: Service deployment infrastructure (9 tasks)
  - ServiceScheduler GenServer
  - Bin-packing algorithm
  - Docker deployer
  - Service registry
  - Resource collection
  - Python CLI deploy command
  - Config parser
  - Status tracking

### ✅ Completed: All Phases (85/85 tasks)

- **Phase 1**: Project setup and structure (7 tasks) ✅
- **Phase 2**: Core infrastructure (15 tasks) ✅
- **Phase 3**: Service deployment (13 tasks) ✅
- **Phase 4**: Automatic failover (12 tasks) ✅
- **Phase 5**: P2P Access (12 tasks) ✅
- **Phase 6**: Advanced features (11 tasks) ✅
- **Phase 7**: Polish & Cross-cutting (12 tasks) ✅

### 🎉 All Features Implemented

The complete Virtual Cluster system is now implemented with:
- Service deployment with intelligent scheduling
- Automatic failover and service migration
- P2P browser/mobile access without fixed IPs
- Resource pooling and monitoring
- Comprehensive health visibility
- Structured logging and observability

## Getting Started

### Prerequisites

- Elixir 1.16+
- Python 3.11+
- Docker
- 3-10 Linux machines

### Setup

```bash
# Install dependencies
mix deps.get

# Setup Python environment
cd python_cli
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Development

```bash
# Start cluster
iex -S mix

# Run tests
mix test

# Format code
mix format
```

## Key Features

- **Multi-machine cluster**: 3-10 physical machines
- **Automatic scheduling**: Bin-packing algorithm
- **High availability**: Automatic failover
- **Data replication**: rsync to 2+ nodes
- **P2P access**: WebRTC without fixed IPs
- **Token auth**: JWT for security

## License

MIT


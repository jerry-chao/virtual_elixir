# Deployment Guide: Virtual Cluster

**Version**: 0.1.0  
**Date**: 2025-01-15

## Overview

This guide walks through deploying the Virtual Cluster system across multiple machines.

## Prerequisites

### Hardware Requirements

- 3-10 physical machines (Linux)
- Minimum per machine:
  - 2 CPU cores
  - 4GB RAM
  - 20GB free disk space
- Network connectivity between machines (home/office networks)

### Software Requirements

- Docker 20.10+
- Elixir 1.16+
- Python 3.11+
- SSH access to all machines

## Quick Start

### 1. First Machine Setup

```bash
# Clone repository
git clone <repository-url>
cd virtual_elixir

# Install Elixir dependencies
mix deps.get

# Initialize Python environment
cd python_cli
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Initialize cluster
python main.py cluster init my-cluster

# Save the generated token securely
# Token: <your-cluster-secret-token>
```

### 2. Join Additional Machines

On each additional machine:

```bash
# Install dependencies (same as above)

# Join cluster
python main.py cluster join \
  --token <your-cluster-secret-token> \
  my-cluster

# Verify join
python main.py cluster status
```

### 3. Deploy First Service

```bash
python main.py services deploy \
  --name hello \
  --image nginx:latest \
  --port 80

# Get access URL
python main.py services list
# Access: https://hello.my-cluster.local
```

## Production Deployment

### 1. Configure Environment

Edit `config/prod.exs`:

```elixir
config :virtual_cluster,
  cluster_secret_key: System.get_env("CLUSTER_SECRET_KEY"),
  max_nodes: 10,
  heartbeat_interval: 30_000
```

Set environment variable:

```bash
export CLUSTER_SECRET_KEY=$(openssl rand -base64 64)
```

### 2. Run as Service

Create systemd service (`/etc/systemd/system/virtual-cluster.service`):

```ini
[Unit]
Description=Virtual Cluster Node
After=network.target docker.service

[Service]
Type=simple
User=your-user
WorkingDirectory=/path/to/virtual_elixir
ExecStart=/usr/bin/mix run --no-halt
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable virtual-cluster
sudo systemctl start virtual-cluster
```

### 3. Configure Firewall

The cluster uses P2P networking, but ensure required ports are open:

```bash
# Allow libcluster EPMD connections
sudo ufw allow 4369/tcp

# Allow libcluster node-to-node connections  
sudo ufw allow 9000:9100/tcp

# Optional: WebRTC signaling (if running dedicated server)
sudo ufw allow 8080/tcp
```

## Monitoring

### Health Checks

```bash
# Check cluster status
python main.py status

# View nodes
python main.py status nodes

# Check resources
python main.py status resources
```

### Logs

```bash
# View cluster logs
journalctl -u virtual-cluster -f

# View specific service logs
docker logs <container-id>
```

## Troubleshooting

### Nodes Not Connecting

```bash
# Check network connectivity
ping <other-node-ip>

# Check EPMD port
netstat -an | grep 4369

# Verify firewall rules
sudo ufw status
```

### Services Not Deploying

```bash
# Check Docker
docker ps

# Check cluster resources
python main.py resources

# Check logs
mix run --logger-level debug
```

### Performance Issues

- Check resource utilization: `python main.py resources`
- Monitor CPU/memory per node
- Consider adding more nodes if consistently >80% utilization

## Security

1. **Token Management**: Keep cluster token secure, rotate periodically
2. **Network Security**: Use VPN or private networks for sensitive deployments
3. **Container Security**: Use only trusted container images
4. **Access Control**: Restrict cluster API access

## Backup & Recovery

Service data is automatically replicated to 2+ nodes. For additional safety:

1. Backup cluster configuration
2. Export service definitions
3. Backup replicated data: `/var/lib/virtual-cluster/`

## Support

For issues, see:
- Quickstart: `specs/001-virtual-cluster-p2p/quickstart.md`
- Specifications: `specs/001-virtual-cluster-p2p/spec.md`
- Plan: `specs/001-virtual-cluster-p2p/plan.md`


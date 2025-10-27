# Quickstart Guide: Virtual P2P Service Cluster

**Feature**: Virtual P2P Service Cluster  
**Created**: 2025-01-15

## Prerequisites

- 3-10 Linux machines with Docker installed
- Python 3.11+ on management machine (CLI)
- Elixir 1.16+ runtime on each node
- Network connectivity between machines
- Cluster authentication token

## Getting Started (15 minutes)

### 1. Initialize Cluster (First Machine)

On your first machine (e.g., home machine):

```bash
# Generate cluster token
python -m virtual_cluster.cli init my-home-office-cluster

# Output: Cluster token saved to ~/.virtual-cluster/token
# Token: <secret-token-here>
```

The cluster is now initialized with a unique token. **Save this token securely** - you'll need it to add additional machines.

### 2. Add Additional Machines

On your second machine (e.g., office machine):

```bash
# Join the cluster
python -m virtual_cluster.cli join \
  --token <secret-token-here> \
  my-home-office-cluster

# Machine will connect to cluster and appear as "online"
```

Repeat for your third machine (minimum 3 machines required).

### 3. Verify Cluster Status

```bash
# Check cluster health
python -m virtual_cluster.cli status

# Expected output:
# Cluster: my-home-office-cluster
# Status: active
# Nodes: 3/10 (online: 3, offline: 0)
# Services: 0
```

### 4. Deploy Your First Service

Deploy a simple web server to the cluster:

```bash
python -m virtual_cluster.cli deploy \
  --name hello-web \
  --image nginx:latest \
  --port 80

# Service will be automatically scheduled to one of your machines
```

### 5. Access the Service

Get the service access URL:

```bash
python -m virtual_cluster.cli services

# Output:
# Service: hello-web
# Status: running
# Access: https://hello-web.my-home-office-cluster.local
```

Open the URL in your browser - the service is accessible via P2P networking even though none of your machines have a fixed public IP!

### 6. Test Automatic Failover

Shutdown the machine running the service:

```bash
# On the machine running the service
sudo shutdown -h now
```

Within 5 minutes, check the service status again:

```bash
python -m virtual_cluster.cli services

# Output:
# Service: hello-web
# Status: running  (migrated to another machine!)
# Access: https://hello-web.my-home-office-cluster.local  (same URL!)
```

The service has been automatically redeployed to another machine in your cluster, and it's still accessible at the same URL!

## Common Workflows

### Deploy a Custom Application

```bash
# Build and push your container to a registry (Docker Hub, etc.)
docker build -t myusername/myapp:latest .
docker push myusername/myapp:latest

# Deploy to cluster
python -m virtual_cluster.cli deploy \
  --name myapp \
  --image myusername/myapp:latest \
  --port 3000 \
  --cpu 1.0 \
  --memory 512

# Set environment variables
python -m virtual_cluster.cli configure myapp \
  --env DATABASE_URL=postgres://... \
  --env API_KEY=secret-key
```

### Scale a Service

```bash
# Increase to 3 replicas
python -m virtual_cluster.cli scale myapp --replicas 3

# Check instance distribution
python -m virtual_cluster.cli instances myapp

# Output:
# Instance 1: running on office-machine-01
# Instance 2: running on home-machine-02
# Instance 3: running on home-machine-03
```

### Monitor Cluster Health

```bash
# View all nodes
python -m virtual_cluster.cli nodes

# View resource usage
python -m virtual_cluster.cli resources

# Get service logs
python -m virtual_cluster.cli logs hello-web --tail 50
```

### Add More Machines

When you want to expand capacity (up to 10 total machines):

```bash
# On the new machine
python -m virtual_cluster.cli join \
  --token <secret-token-here> \
  my-home-office-cluster

# Cluster automatically discovers the new machine
```

## Access Services from Mobile/Remote Locations

### Mobile Access

Install the cluster mobile app (iOS/Android) and connect:

1. Open the app
2. Enter cluster name: `my-home-office-cluster`
3. Scan QR code or enter token manually
4. Browse and access your services

### Browser Access

Services are automatically accessible via P2P networking:
- No VPN required
- No port forwarding needed
- Works even if machines are behind NAT/firewalls

Simply use the provided URLs (e.g., `https://hello-web.my-home-office-cluster.local`)

## Troubleshooting

### Cluster Not Connecting

```bash
# Check node connectivity
python -m virtual_cluster.cli ping

# Check if cluster secret token matches on all machines
python -m virtual_cluster.cli verify-token
```

### Service Not Starting

```bash
# Check service logs
python -m virtual_cluster.cli logs myapp

# Check cluster resources
python -m virtual_cluster.cli resources

# If insufficient resources, add another machine to cluster
```

### P2P Connection Failing

```bash
# Configure TURN server for NAT traversal
python -m virtual_cluster.cli configure-cluster \
  --turn-server turn.example.com:3478 \
  --turn-username myuser \
  --turn-password mypass
```

## Advanced Configuration

### Set Up High Availability

By default, services have 1 replica. For HA, increase replicas:

```bash
python -m virtual_cluster.cli deploy \
  --name critical-service \
  --image myapp:latest \
  --replicas 3  # Ensures at least 1 always available
```

### Configure Resource Limits

```bash
python -m virtual_cluster.cli deploy \
  --name myapp \
  --image myapp:latest \
  --cpu 2.0 \
  --memory 2048 \
  --disk 10000  # 10GB
```

### Persistent Data

Services automatically get persistent storage replicated across nodes:

```bash
# Data is stored at: /var/lib/virtual-cluster/clusters/{cluster-id}/services/{service-id}/data/
# This data is replicated to 2+ additional nodes automatically
```

## Next Steps

1. **Deploy More Services**: Try deploying a database, web app, or API
2. **Monitor Performance**: Use `virtual_cluster.cli monitor` for real-time metrics
3. **Automate Deployments**: Integrate with CI/CD pipelines
4. **Scale Cluster**: Add more machines (up to 10 total)

## Getting Help

- View logs: `python -m virtual_cluster.cli logs {service-name}`
- Check documentation: `python -m virtual_cluster.cli docs`
- Report issues: GitHub issues or contact support

---

**Success!** You now have a resilient virtual service cluster running across your physical machines, with automatic failover and P2P accessibility.

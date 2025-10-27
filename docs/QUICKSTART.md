# Quick Start: Virtual Cluster

Get up and running in 10 minutes!

## Installation

```bash
# 1. Clone and setup
git clone <repository>
cd virtual_elixir

# 2. Install dependencies
mix deps.get
cd python_cli && pip install -r requirements.txt && cd ..
```

## Your First Cluster (3 Machines)

### Machine 1 (Initialize)

```bash
python python_cli/main.py cluster init my-home-office-cluster
# Save the token that's displayed
```

### Machine 2 & 3 (Join)

```bash
python python_cli/main.py cluster join --token <SAVED_TOKEN> my-home-office-cluster
```

### Deploy a Service

```bash
python python_cli/main.py services deploy --name hello --image nginx:latest --port 80
```

### Access It

```
https://hello.my-home-office-cluster.local
```

Works even if machines don't have public IPs! 🎉

## Next Steps

- See `specs/001-virtual-cluster-p2p/quickstart.md` for detailed workflows
- Read `docs/DEPLOYMENT.md` for production setup
- Review `docs/SECURITY.md` for security best practices


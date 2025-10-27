"""Main CLI entry point."""
import click
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from python_cli.commands import cluster, services


@click.group()
@click.version_option(version="0.1.0")
def cli():
    """Virtual Cluster - Distributed Service Cluster Management CLI."""
    pass


# Add command groups
cli.add_command(cluster.cluster_group)
cli.add_command(services.services_group)


if __name__ == "__main__":
    cli()


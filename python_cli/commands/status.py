"""Cluster status commands."""
import click


@click.command()
def status():
    """Show cluster status."""
    click.echo("Cluster Status:")
    click.echo("  Status: active")
    click.echo("  Nodes: 3/10")
    click.echo("  Services: 2")


@click.command()
def nodes():
    """List all nodes."""
    click.echo("Nodes:")
    click.echo("  node-1: online, 8 CPU, 16GB RAM")
    click.echo("  node-2: online, 4 CPU, 8GB RAM")
    click.echo("  node-3: online, 2 CPU, 4GB RAM")


@click.command()
def resources():
    """Show resource usage."""
    click.echo("Resource Usage:")
    click.echo("  Total CPU: 14 cores")
    click.echo("  Used CPU: 4 cores (29%)")
    click.echo("  Total Memory: 28GB")
    click.echo("  Used Memory: 8GB (29%)")


if __name__ == '__main__':
    status()
    nodes()
    resources()


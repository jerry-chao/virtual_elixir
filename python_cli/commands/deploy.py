"""Service deployment command."""
import click
import requests


@click.command()
@click.option('--name', required=True, help='Service name')
@click.option('--image', required=True, help='Container image')
@click.option('--port', type=int, multiple=True, help='Ports to expose')
@click.option('--env', type=(str, str), multiple=True, help='Environment variables')
@click.option('--cpu', type=float, default=0.5, help='CPU requirement (cores)')
@click.option('--memory', type=int, default=1024, help='Memory requirement (MB)')
def deploy(name, image, port, env, cpu, memory):
    """Deploy a new service to the cluster."""
    config = {
        "name": name,
        "image": image,
        "exposed_ports": list(port),
        "environment": dict(env) if env else {},
        "resource_requirements": {
            "cpu_request": cpu,
            "memory_request": memory * 1_000_000  # Convert MB to bytes
        }
    }
    
    # TODO: Send to cluster API
    click.echo(f"Deploying service '{name}' from image '{image}'...")
    click.echo(f"Configuration: {config}")
    click.echo("Deployment initiated (not yet implemented)")


if __name__ == '__main__':
    deploy()


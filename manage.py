#!/usr/bin/env python
"""CLI tool for managing the MoneyManager application."""
import argparse
import subprocess
import sys


def build(args):
    """Build the Docker image."""
    tag = args.tag or "moneymanager:latest"
    cmd = ["docker", "build", "-t", tag, "."]
    print(f"Building image: {tag}")
    subprocess.run(cmd, check=True)


def run(args):
    """Run the Docker container."""
    tag = args.tag or "moneymanager:latest"
    port = args.port or "8000"
    cmd = ["docker", "run", "-p", f"{port}:8000", tag]
    print(f"Running container on port {port}")
    subprocess.run(cmd, check=True)


def main():
    parser = argparse.ArgumentParser(description="MoneyManager CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Build command
    build_parser = subparsers.add_parser("build", help="Build the Docker image")
    build_parser.add_argument("-t", "--tag", help="Image tag (default: moneymanager:latest)")
    build_parser.set_defaults(func=build)

    # Run command
    run_parser = subparsers.add_parser("run", help="Run the Docker container")
    run_parser.add_argument("-t", "--tag", help="Image tag (default: moneymanager:latest)")
    run_parser.add_argument("-p", "--port", help="Host port (default: 8000)")
    run_parser.set_defaults(func=run)

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(1)

    args.func(args)


if __name__ == "__main__":
    main()

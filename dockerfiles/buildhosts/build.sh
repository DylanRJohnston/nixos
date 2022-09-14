#!/usr/bin/env bash

docker build . --platform=linux/amd64 -t nix-build-slave-amd64:latest
docker build . --platform=linux/arm64 -t nix-build-slave-arm64:latest

docker run --name nix-build-slave-arm64 -d -p 3022:22 --platform=linux/arm64 nix-build-slave-arm64
docker run --name nix-build-slave-amd64 -d -p 4022:22 --platform=linux/amd64 nix-build-slave-amd64


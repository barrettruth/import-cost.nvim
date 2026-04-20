#!/bin/sh
set -eu

exec nix develop .#ci --command just ci

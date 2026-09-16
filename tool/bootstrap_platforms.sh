#!/usr/bin/env bash
set -euo pipefail

# Reproducibly refresh the stock Flutter platform projects before reviewing
# and committing their generated changes. CI must build committed platforms.
flutter create \
  --platforms=android,ios \
  --project-name calculator_vault \
  --org com.theeb \
  .

#!/usr/bin/env bash
# Synchronise le site (index.html, pkg/, voice/, sw.js, manifest.json, favicon.svg) vers le VPS qui sert physiotech.ch et
# mouveo.loicberthod.ch (même dossier, bloc Caddy déjà en place).
set -euo pipefail
cd "$(dirname "$0")"
rsync -az --delete --exclude .git --exclude deploy.sh --exclude README.md --exclude LICENSE \
  -e "ssh -i ~/.ssh/loicberthodvps" ./ ubuntu@179.237.71.235:/mnt/data/mouveo/dist/
# Vérification (n'interrompt pas le script : un cache DNS négatif local suffirait à faire échouer curl).
curl -s -o /dev/null -w "https://physiotech.ch/ -> %{http_code}\n" --max-time 30 https://physiotech.ch/ || echo "vérification HTTPS impossible depuis cette machine (DNS ?) — le rsync, lui, est fait"

#!/usr/bin/env bash
# Génère le passage français du livre avec les modèles de synthèse vocale locaux, voix par voix.
# Seul prérequis : uv (https://docs.astral.sh/uv/). Tout le reste est téléchargé à la volée.
#
# Usage : ./generer.sh [pocket|kyutai|phonon|tout]   (défaut : tout)
# Fichiers produits : audio/<modele>-<taille>-<voix>-fr.wav
set -uo pipefail

ICI="$(cd "$(dirname "$0")" && pwd)"
TEXTE="$ICI/texte/extrait-fr.txt"
AUDIO="$ICI/audio"
PYTHON="3.12"
mkdir -p "$AUDIO"

# --- Voix testées --------------------------------------------------------------
# Pocket TTS : voix intégrées (Estelle = voix française d'origine, les autres sont à écouter).
VOIX_POCKET="estelle cosette fantine eponine azelma javert jean marius"
# Phonon : les 15 voix françaises du catalogue Gradium.
VOIX_PHONON="Noémie Coralie Maëlys Solène Lilou Tiphaine Orianne Ninon Hélène Augustin Jules Marius Arnaud Baptiste Lucien"
# Kyutai TTS 1.6B : nom court => voix du dépôt kyutai/tts-voices.
VOIX_KYUTAI=(
  "cml10087=cml-tts/fr/10087_11650_000028-0002_enhanced.wav"
  "developpeuse=unmute-prod-website/developpeuse-3.wav"
  "fabieng=unmute-prod-website/fabieng-enhanced-v2.wav"
)

# Jeton Hugging Face (nécessaire pour Phonon uniquement), lu depuis _SECRET s'il existe.
SECRET_HF="$ICI/../_SECRET/huggingface.txt"
if [[ -z "${HF_TOKEN:-}" && -s "$SECRET_HF" ]]; then
  HF_TOKEN="$(tr -d '[:space:]' < "$SECRET_HF")"
  export HF_TOKEN
fi

# Nom de fichier : minuscules, sans accents.
nom() { echo "$1" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9.'; }

chrono() { # chrono <libellé> <commande…> : lance la commande et affiche la durée mesurée
  local libelle="$1"; shift
  local debut fin
  debut=$(date +%s)
  if "$@" >/dev/null 2>&1; then
    fin=$(date +%s)
    echo "[OK] $libelle : $((fin - debut)) s de calcul"
  else
    echo "[ÉCHEC] $libelle"
  fi
}

pocket() {
  local variante taille voix
  for variante in french french_24l; do
    [[ "$variante" == french ]] && taille="100m" || taille="24l"
    for voix in $VOIX_POCKET; do
      chrono "pocket-$taille-$voix" \
        uvx --python "$PYTHON" pocket-tts generate --language "$variante" --voice "$voix" \
          --text "$(cat "$TEXTE")" --output-path "$AUDIO/pocket-$taille-$voix-fr.wav" -q
    done
  done
}

kyutai() {
  # Mac Apple Silicon uniquement (MLX). Script officiel Kyutai, exécuté directement depuis GitHub.
  local script="https://raw.githubusercontent.com/kyutai-labs/delayed-streams-modeling/main/scripts/tts_mlx.py"
  local entree court chemin
  for entree in "${VOIX_KYUTAI[@]}"; do
    court="${entree%%=*}"; chemin="${entree#*=}"
    chrono "kyutai-1.6b-$court" \
      uv run --python "$PYTHON" "$script" "$TEXTE" "$AUDIO/kyutai-1.6b-$court-fr.wav" --voice "$chemin"
  done
}

phonon() {
  if [[ -z "${HF_TOKEN:-}" ]]; then
    echo "[SAUTÉ] Phonon : jeton Hugging Face absent (_SECRET/huggingface.txt ou HF_TOKEN)."
    return
  fi
  local voix
  for voix in $VOIX_PHONON; do
    chrono "phonon-40m-$(nom "$voix")" \
      uvx --python "$PYTHON" ptts --model hf://gradium/phonon-40m-fr --lang fr --quant q8 \
        --voice "$voix" "$(cat "$TEXTE")" -o "$AUDIO/phonon-40m-$(nom "$voix")-fr.wav"
  done
}

case "${1:-tout}" in
  pocket) pocket ;;
  kyutai) kyutai ;;
  phonon) phonon ;;
  tout)   pocket; kyutai; phonon ;;
  *) echo "Usage : $0 [pocket|kyutai|phonon|tout]"; exit 1 ;;
esac

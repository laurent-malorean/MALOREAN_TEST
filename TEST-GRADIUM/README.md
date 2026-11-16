# TEST-GRADIUM — synthèse vocale locale en français

[← Retour à l'accueil du dépôt](../README.md)

## Ce qu'on fait

On compare la qualité de voix de trois modèles de synthèse vocale **qui tournent en local**, sans service en ligne ni clé API payante, sur un même passage en français du livre *Malorean Corp* (introduction, 842 caractères, environ 38 secondes d'audio).

But : choisir le modèle au meilleur rendu pour une éventuelle version audio gratuite du livre.

Pour l'instant : **français uniquement**.

## Les trois modèles

| | Kyutai TTS 1.6B | Kyutai Pocket TTS | Gradium Phonon 40m (fr) |
|---|---|---|---|
| Éditeur | Kyutai (laboratoire d'où est issu Gradium) | Kyutai | Gradium |
| Taille | 1,8 milliard de paramètres | 100 millions | 40 millions |
| Conçu pour | La qualité | La légèreté (processeur seul) | Les téléphones et petits appareils |
| Langues | Français, anglais | Français, anglais, allemand, espagnol, portugais, italien, néerlandais | Français (un modèle par langue : fr, en, de, es, pt) |
| Machine requise | Mac Apple Silicon (version MLX) | Tout ordinateur, pas de carte graphique | Tout ordinateur, téléphone, Raspberry Pi |
| Licence du modèle | CC BY 4.0 : usage libre, y compris commercial, en citant Kyutai | CC BY 4.0 : idem | CC BY-NC 4.0 : **pas d'usage commercial** sans licence Gradium |
| Accès | Libre | Libre (version sans clonage de voix) | Compte Hugging Face + acceptation de la licence |
| Statut du test | **Généré** | **Généré** | **Généré** |

### Contraintes à connaître

- **Licence des voix** : distincte de celle du modèle. Les voix françaises Kyutai utilisées viennent du jeu de données CML-TTS (CC BY 4.0). Les voix du jeu « expresso » de Kyutai sont **non commerciales** : à éviter.
- **Phonon et livre audio gratuit** : un usage gratuit est en principe non commercial, mais la page renvoie vers la version papier payante, ce qui peut être vu comme de la promotion. Demander confirmation à Gradium avant toute publication.
- **Clonage de voix** : reproduire la voix d'une personne réelle exige son accord, quelle que soit la licence.
- **Langues absentes** : aucun des trois ne parle coréen, japonais ou chinois.
- Ces informations viennent des pages officielles des modèles (novembre 2026) ; ce n'est pas un avis juridique.

## Voix testées

Fichiers : `audio/<modèle>-<taille>-<voix>-fr.wav`.

| Modèle | Voix | Licence des voix |
|---|---|---|
| Kyutai TTS 1.6B (3) | cml10087 (lecteur CML-TTS), developpeuse, fabieng | CC BY 4.0 (CML-TTS), CC0 (developpeuse, fabieng) |
| Pocket TTS 100m et 24l (8 chacun) | estelle (voix française d'origine), cosette, fantine, eponine, azelma, javert, jean, marius | Voix intégrées au modèle |
| Phonon 40m (15) | Femmes : noemie, coralie, maelys, solene, lilou, tiphaine, orianne, ninon, helene. Hommes : augustin, jules, marius, arnaud, baptiste, lucien | Apache 2.0 (catalogue gradium/phonon-voices) |

## Mesures (Mac M4, 32 Go)

Chaque modèle mesuré seul, une voix après l'autre.

| Modèle | Durée audio | Temps de calcul mesuré par voix |
|---|---|---|
| Phonon 40m | 37,8 à 51,3 s | 2 à 11 s |
| Pocket TTS 100m | 37,2 à 48,0 s | 11 à 37 s |
| Pocket TTS 24l (aperçu) | 37,0 à 49,0 s | 20 à 26 s |
| Kyutai TTS 1.6B | 36,2 à 38,7 s | 285 s (mesuré seul, une voix) ; 307 à 415 s en parallèle d'autres générations |

Les temps incluent le démarrage de l'outil et le chargement du modèle à chaque voix.

## Clonage de voix

| Modèle | Clonage | Comment |
|---|---|---|
| Kyutai TTS 1.6B | Non | Volontairement limité aux voix pré-calculées de Kyutai. |
| Pocket TTS | Oui, 100 % local | Version avec clonage (accès Hugging Face restreint, acceptation de la licence) + un enregistrement. |
| Phonon | Oui, via Gradium | Enregistrement d'environ 10 s envoyé à Gradium (clé API Gradium), voix ensuite utilisable en local. |

Tests prévus : voir [la liste à faire](../todo.md).

## Lancer le test

Seul prérequis : [uv](https://docs.astral.sh/uv/). Tout le reste (Python, modèles, voix) est téléchargé automatiquement au premier lancement.

```sh
./generer.sh            # les trois modèles, toutes les voix
./generer.sh pocket     # un seul : pocket, kyutai ou phonon
```

Pour Phonon : accepter la licence sur https://huggingface.co/gradium/phonon-40m-fr, puis placer un jeton Hugging Face dans `../_SECRET/huggingface.txt` (jamais poussé sur GitHub).

## Contenu

- [generer.sh](generer.sh) : génère les audios et mesure les temps.
- [texte/extrait-fr.txt](texte/extrait-fr.txt) : le passage lu.
- [audio/](audio/) : les 34 audios générés.

Source du texte : https://malorean.net/livre2-malorean_corp/telecharger.html

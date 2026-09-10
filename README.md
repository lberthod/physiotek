# PhysioTech.ch — Attrape-bulles

> ## ⚠️ Démonstration technologique, pas un outil médical
>
> PhysioTech.ch est une **démo de vision par ordinateur** (suivi du corps et
> des mains dans le navigateur, avatar 3D, jeu de capture). Elle n'a **aucune
> valeur médicale, thérapeutique ni scientifique** : rien n'y est validé
> cliniquement, aucune mesure n'est fiable au sens clinique, aucun avis
> médical n'y est donné. Ce n'est ni un dispositif médical ni un programme de
> rééducation. Consultez un professionnel de santé pour tout exercice de
> rééducation ; arrêtez immédiatement en cas de douleur, vertige ou inconfort.

Jeu de capture dans le navigateur : la caméra suit votre corps et vos mains
(MediaPipe), un mannequin 3D vous imite, et des bulles apparaissent autour de
vous — attrapez-les avant qu'elles n'éclatent, avec le geste que leur couleur
impose. En ligne : **https://physiotech.ch/**

## Origine et auteurs

- **[Mouvéo](https://github.com/antoinequarroz/mouveo-reeducation)** par
  [Antoine Quarroz](https://github.com/antoinequarroz) : le prototype web
  d'origine (React + MediaPipe Pose + canvas 2D), dont ce jeu reprend l'idée
  — un patient face à sa caméra, des cibles lumineuses à atteindre, un score
  motivant — et l'avertissement « prototype de coaching, sans diagnostic ni
  mesure clinique ».
- **[Loïc Berthod](https://github.com/lberthod)** : portage sur le moteur
  [RusteeGear](https://github.com/lberthod/rusteegear) (Rust, WebAssembly,
  WebGPU), mannequin 3D, suivi des doigts, mode attrape-bulles, code couleur
  des gestes.

## Le jeu

| Couleur | Geste |
| --- | --- |
| Blanc | toucher |
| Bleu | toucher **poing fermé** |
| Vert | toucher **main ouverte** |
| Noir (halo rouge) | **bombe**, ne pas toucher : −20 points |

- Les bulles naissent autour de vos épaules, jusqu'au-dessus de la tête, et
  toujours dans le champ de la caméra ; leur halo rétrécit avant qu'elles
  n'éclatent.
- 10 points par bulle, +5 par palier de 3 dans la série ; trois rythmes (doux,
  moyen, vif) ; 60 s de temps actif (le chrono se fige si vous sortez du cadre).
- Sans caméra, la main du mannequin se pilote au stick tactile ou aux flèches.
- Avatar : mannequin neutre construit sur vos repères (doigts compris) ou
  squelette de bâtons.

## Comment c'est fait

- **Page** `index.html` : caméra, MediaPipe *Pose Landmarker* + *Hand
  Landmarker* dans un Web Worker (~30 images/s, repli 15), squelette dessiné sur
  la vignette miroir, repères poussés au moteur (`set_pose_landmarks`,
  `set_hand_landmarks`).
- **Moteur** `pkg/` : RusteeGear compilé en WebAssembly + WebGPU (Rust, wgpu,
  egui, scripts Lua). Tout le gameplay est une scène de démo du moteur
  (`src/scene/demos/reeducation.rs` dans
  [rusteegear](https://github.com/lberthod/rusteegear), doc dans
  `docs/REEDUCATION.md`). Ce dépôt ne contient que le site prêt à servir.

Navigateur requis : WebGPU (Chrome/Edge 113+, Safari 18+, Firefox 141+) et une
webcam pour le mode caméra.

## Reconstruire le site

Depuis un clone de [rusteegear](https://github.com/lberthod/rusteegear) (Rust
1.98, cible `wasm32-unknown-unknown`, `wasm-bindgen-cli` à la version du
lockfile, `binaryen`) :

```bash
./packaging/build_web.sh
cp packaging/web/reeduc.html ../physiotek/index.html
cp packaging/web/pkg/motor3derust.js packaging/web/pkg/motor3derust_bg.wasm ../physiotek/pkg/
```

## Déployer

Site statique : servir ce dossier tel quel (HTTPS obligatoire pour la caméra).
`deploy.sh` synchronise le dossier vers le VPS qui sert physiotech.ch (Caddy).

## Licence

MIT, comme le moteur — voir `LICENSE`. Les modèles MediaPipe sont chargés
depuis leur CDN sous licence Apache 2.0.

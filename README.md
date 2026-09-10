# PhysioTech.ch — Attrape-bulles

Jeu de rééducation motrice dans le navigateur : la caméra suit votre corps et
vos mains (MediaPipe), un mannequin 3D vous imite, et des bulles apparaissent
autour de vous — attrapez-les avant qu'elles n'éclatent, avec le geste que leur
couleur impose. En ligne : **https://physiotech.ch/**

Créé par [Antoine Quarroz](https://github.com/antoinequarroz) (Mouvéo, le
prototype d'origine) et [Loïc Berthod](https://github.com/lberthod) (portage
sur le moteur [RusteeGear](https://github.com/lberthod/rusteegear)).

> Prototype de coaching, sans diagnostic ni mesure clinique — suivez les
> consignes de votre professionnel de santé, arrêtez en cas de douleur, vertige
> ou inconfort inhabituel.

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

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

Jeu de mobilité dans le navigateur : la caméra suit votre corps et vos mains
(MediaPipe), un mannequin 3D vous imite, et le coach Christophe vous guide —
attrapez les bulles avant qu'elles n'éclatent avec le geste que leur couleur
impose, ou gardez la main sur l'étoile filante. Interface complète reprise de
Mouvéo (parcours de séance, historique, espace thérapeute, PWA). En ligne :
**https://physiotech.ch/**

## Origine et auteurs

- **[Mouvéo](https://github.com/antoinequarroz/mouveo-reeducation)** par
  [Antoine Quarroz](https://github.com/antoinequarroz) : le prototype web
  d'origine (React + MediaPipe Pose + canvas 2D), dont ce jeu reprend l'idée
  — un patient face à sa caméra, des cibles lumineuses à atteindre, un score
  motivant — et l'avertissement « prototype de coaching, sans diagnostic ni
  mesure clinique ».
- **[Loïc Berthod](https://github.com/lberthod)** : portage sur le moteur
  [RusteeGear](https://github.com/lberthod/rusteegear) (Rust, WebAssembly,
  WebGPU), mannequin 3D, suivi des doigts, modes Attrape-bulles et Étoile
  filante, code couleur des gestes, intégration de l'interface Mouvéo.

## Le jeu

Deux modes, trois rythmes (doux, moyen, vif), des manches de 30 à 90 s.

**Attrape-bulles** — des bulles naissent autour de vos épaules, jusqu'au-dessus
de la tête, toujours dans le champ de la caméra, toujours **loin de vos mains**
(≥ 0,55 m) et **loin les unes des autres** (≥ 0,6 m) ; leur halo rétrécit avant
qu'elles n'éclatent. Attrapez-les avec le geste que leur couleur impose :

| Couleur | Geste |
| --- | --- |
| Blanc | toucher |
| Bleu | toucher **poing fermé** |
| Vert | toucher **main ouverte** |
| **Cube rouge** (halo rouge qui pulse) | **bombe**, ne pas toucher : −20 points, série cassée |

Les bombes sont rares par construction : **une seule à la fois**, puis 3 à
8 s sans bombe ; 8 / 12 / 16 % des apparitions selon le rythme ; jusqu'à
2 / 3 / 4 bulles simultanées. 10 points par bulle, +5 par palier de 3 dans la
série.

**Étoile filante** — une étoile dorée glisse lentement autour de vous : gardez
une main dessus. 10 points par seconde de contact, +5 par palier de 3 s
d'affilée ; la perdre compte une perte et casse la série.

## L'interface (reprise de Mouvéo)

- **Parcours de séance** : accueil (séance simple ou parcours guidé de 1 à
  4 manches, mode de jeu, ambiance jardin / espace / océan, rythme, douleur
  avant séance) → préparation de l'espace → caméra → calibration (corps
  détecté, position stable, repères prêts) → compte à rebours 3-2-1 → partie
  (score, série, chrono, consigne, qualité du geste) → pause → repos entre
  les manches → bilan (points, étoiles, précision, meilleure série,
  régularité, douleur après, fatigue, conseil, enregistrer, partager).
- **Coach Christophe** : une seule voix enregistrée (22 clips, Chatterbox
  open source, persona original de Mouvéo) qui commente chaque étape ; file
  de lecture sans doublon ni coupure. Bouton on/off et test.
- **Progression** (sur l'appareil, `localStorage`) : 30 séances, jardin de
  mobilité, badges, série de jours, objectif hebdomadaire, vue « Progrès ».
- **Espace thérapeute** : programme (mode, rythme, amplitude, durée de
  manche, nombre de manches, mode assis, prénom et code patient), suivi des
  dernières séances et de la douleur. Tout reste sur l'appareil.
- **PWA** : installable, utilisable hors ligne après une première séance
  (`manifest.json`, `sw.js`).
- **Sans caméra** : mode démo, la main du mannequin se pilote au stick tactile
  ou aux flèches. **Mise en page** : tout tient à l'écran à 100 % (pas de
  défilement au-dessus de 1024 px), bouton plein écran (touche F) ; sur
  téléphone, la scène prend tout l'écran pendant la séance et la caméra de jeu
  cadre le corps entier en portrait (bulles et étoile restent dans l'image).
- **Avatar** : mannequin neutre construit sur vos repères (doigts compris) ou
  squelette de bâtons ; la caméra de jeu recule d'elle-même en portrait.

## Comment c'est fait

- **Page** `index.html` : interface complète en HTML / CSS / JS purs (pas
  d'étape de build), caméra, MediaPipe *Pose Landmarker* + *Hand Landmarker*
  dans un Web Worker (~30 images/s, repli 15), squelette dessiné sur la
  vignette miroir, repères poussés au moteur (`set_pose_landmarks`,
  `set_hand_landmarks`). La page pilote le jeu (`push_hud_event`,
  `set_script_var`) et lit son état chaque image (`window.__rusteegear_vars`,
  variables `ui_*`) ; elle dessine le HUD à la place du moteur
  (`set_hud_widgets_visible(false)`).
- **Moteur** `pkg/` : RusteeGear compilé en WebAssembly + WebGPU (Rust, wgpu,
  egui, scripts Lua). Tout le gameplay est une scène de démo du moteur
  (`src/scene/demos/reeducation.rs` dans
  [rusteegear](https://github.com/lberthod/rusteegear), doc dans
  `docs/REEDUCATION.md`, roadmap de l'interface dans
  `docs/roadmapMouveoFrontend10septembre.md`). Ce dépôt ne contient que le
  site prêt à servir.
- **Voix** `voice/christophe/` : clips mp3 de Mouvéo (`NOTICE.txt`).

Navigateur requis : WebGPU (Chrome/Edge 113+, Safari 18+, Firefox 141+) et une
webcam pour le mode caméra.

## Reconstruire le site

Depuis un clone de [rusteegear](https://github.com/lberthod/rusteegear) (Rust
1.98, cible `wasm32-unknown-unknown`, `wasm-bindgen-cli` à la version du
lockfile, `binaryen`) :

```bash
./packaging/build_web.sh
cp packaging/web/reeduc.html ../physiotek/index.html
cp packaging/web/sw.js packaging/web/manifest.json packaging/web/favicon.svg ../physiotek/
cp packaging/web/pkg/motor3derust.js packaging/web/pkg/motor3derust_bg.wasm ../physiotek/pkg/
cp -R packaging/web/voice ../physiotek/
```

## Déployer

Site statique : servir ce dossier tel quel (HTTPS obligatoire pour la caméra).
`deploy.sh` synchronise le dossier vers le VPS qui sert physiotech.ch (Caddy).
Pense à monter la version du cache dans `sw.js` (`physiotech-vN`) à chaque
mise en ligne pour que les visiteurs reçoivent la nouvelle page.

## Licence

MIT, comme le moteur — voir `LICENSE`. Les modèles MediaPipe sont chargés
depuis leur CDN sous licence Apache 2.0.

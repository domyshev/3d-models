# Printable Models by Ilia Domyshev

This repository contains curated, release-ready 3D-printable models designed
by Ilia Domyshev. Each model is maintained in its own directory with source
files, documentation, licensing information, and any required third-party
notices.

## Models

- [Modular MagSafe Holder](models/magsafe_holder/README.md) — a tested,
  adjustable desktop holder for the official Apple MagSafe Charger, built as
  a modular OpenSCAD construction system.
  [Latest release: v0.3.2](models/magsafe_holder/releases/v0.3/README.md) combines
  one eight-piece design with textured surfaces and locally reinforced infill.

## Component library

The [details library](details/README.md) documents independently reusable parts
and their design evolution. It is not required to open or print the projects
in `models/`. Experimental component variants are kept separate from releases.

## Repository conventions

- Model-specific documentation and licensing are stored with each model.
- Vendored dependencies are pinned to explicit versions for reproducible
  rendering.
- Generated print files and release artifacts are published alongside each
  corresponding model version.

# Modular MagSafe Holder

## Start here

1. [Download the A1 mini Bambu Studio project](https://github.com/domyshev/3d-models/releases/download/v0.3.3/magsafe_holder_v0.3_a1_mini.3mf).
2. [Download the complete v0.3.3 ZIP](https://github.com/domyshev/3d-models/releases/download/v0.3.3/magsafe_holder_v0.3.3.zip) for source, STLs, images, and license files.
3. [Follow the assembly instructions](releases/v0.3/README.md#assembly-instructions).

The downloads above are the published v0.3.3 artifacts. The ZIP includes the updated documentation; STL geometry and the Bambu profile
are unchanged from v0.3.2.

**Testing status:** a working prototype and core components have been physically
tested. The exact final lightweight 3MF is slice-verified, but has not yet been
printed and load-tested as a complete set. Do not treat it as a fully print-tested
profile. See the [validation checklist](releases/v0.3/README.md#final-profile-validation-checklist).

## Version 0.3

The latest patch is [v0.3.3](https://github.com/domyshev/3d-models/releases/tag/v0.3.3),
which simplifies this guide, adds assembly instructions and a validation checklist,
and separates current licensing from historical proposals. Photos, geometry,
and print settings are unchanged from v0.3.2.

Version 0.3 is a single eight-piece design, named simply **MagSafe Holder v0.3**.
It has no Compact or Full-Height selection. The two long and two short legs
serve the X and Y axes of the same holder, not separate height variants.

The release files are under
[releases/v0.3/](releases/v0.3/README.md), with a self-contained OpenSCAD source,
individual STLs, and one A1 mini Bambu Studio project. It combines the latest
indexed outer-textured ring, hollow support without a leveling screw, rounded
integral feet, and textured M12 fasteners. See the release notes for per-object
infill settings and testing notes. The design and core components have been
physically tested, including a reprint of the latest textured ring. Not every
minor surface revision has been reprinted; the optimized infill profile has
been checked by slicing but has not yet been physically load-tested.

## Printed prototype — v0.3

| Front-left | Front-right |
| --- | --- |
| ![Printed holder, front-left](releases/v0.3/images/photos/stand-front-left.png) | ![Printed holder, front-right](releases/v0.3/images/photos/stand-front-right.png) |

| Back-right | Back-left |
| --- | --- |
| ![Printed holder, back-right](releases/v0.3/images/photos/stand-back-right.png) | ![Printed holder, back-left](releases/v0.3/images/photos/stand-back-left.png) |

These are real photographs with AI-assisted background and lighting cleanup.

## Apple MagSafe compatibility — check before printing

The ring was physically tested with the original Apple MagSafe Charger shown in
the [illustrated measurements](releases/v0.3/README.md#magsafe-compatibility--check-before-printing).
Direct caliper measurements of this unit are:

- **Outside diameter: 56 mm.**
- **Gray rim thickness: 5.5 mm.**
- **Maximum overall thickness including the white charging face: 5.7 mm.**

The maximum thickness is not the height of the white protrusion. These dimensions
apply to the measured unit, not every Apple revision. Measure your charger before
printing: other revisions and third-party chargers are not confirmed to fit.
This is compatibility with the charger, not a specific iPhone model.
Charger photos and caliper-based annotations appear before the
[pastel assembly views](releases/v0.3/README.md#assembly-views) in the release notes.

## Printing and assembly

The set contains eight pieces: one ring, one support, two long legs, two short
legs, one bolt, and one nut. Long and short legs belong to the same stand.

- [Print settings, local reinforcement, and slicer estimates](releases/v0.3/README.md#bill-of-materials-and-print-strength).
- [Step-by-step assembly](releases/v0.3/README.md#assembly-instructions).
- [Assembled views and OpenSCAD view selector](releases/v0.3/README.md#how-to-see-the-assembled-holder).
- [Historical v0.1 and v0.2 designs](HISTORY.md), including the retired Full-Height and Compact configurations.

Use the [self-contained release source](releases/v0.3/src/magsafe_holder.scad)
for v0.3, not the older development source under `src/`. There is no assembled
print-in-place STL; print the individual parts or use the supplied 3MF.

## License and dependencies

This distribution is **GPL-3.0-or-later**. See [LICENSE](LICENSE), the
[full GPL text](../../LICENSES/GPL-3.0-or-later.txt), and
[third-party notices](THIRD_PARTY_NOTICES.md) for the pinned threading library.
Future licensing ideas are archived separately in [LICENSING_PLANS.md](LICENSING_PLANS.md)
and do not add restrictions to this release.

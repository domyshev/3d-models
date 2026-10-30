# MagSafe clamp ring

Origin: [Modular MagSafe Holder](../../models/magsafe_holder/README.md). The ring
is shared by the compact and full-height configurations. These isolated variants
document later indexing experiments; they are not exact release snapshots.

## Design stages

1. Release v0.1 used smooth outer clamp-arm mating surfaces. That configuration
   was physically tested. Later work introduced indexing to lock the tilt angle.
2. [ring.scad](ring.scad) preserves the latest experimental holder with plain
   cylindrical recesses on both outer clamp-arm faces, without teeth. This
   separates the underlying arm geometry from the indexing geometry while
   investigating sliced arm defects. Each recess is nominally 21 mm in diameter
   and 0.8 mm deep around a 13 mm M12 clearance hole.
3. [ring-indexed.scad](ring-indexed.scad) seats a separate toothed insert in each
   recess, centered on the bolt hole with its flat body against the recess floor.
   The insert diameter was increased from 17 to 20 mm to enlarge the indexing
   contact area. It has 48 teeth, a 0.8 mm annular body, and a 0.7 mm peak height.
   The two positioned inserts and holder are boolean-unioned for rendering.
4. [ring-indexed-textured.scad](ring-indexed-textured.scad) adds the support/leg
   dimple finish only around the outside cylindrical wall, with a 22-degree
   keepout on both sides of the split/join direction. Both external ring rims
   now have 1 mm roundovers. The 56 mm MagSafe seat, retaining flange opening,
   arm geometry, alignment collar and 20 mm indexing inserts are unchanged.
   Earlier plain and indexed entry points keep their original sharp rims.

## Outer-only decorative finish

The new dimples use 1.6 mm pitch, a 0.6 mm cutter radius and 0.25 mm depth.
They do not enter the inner cylindrical seat or flat annular faces. The clamp
arms and their indexing area remain entirely untextured to avoid reintroducing
the sliced ear defects investigated elsewhere in the component library.
The maximum outer diameter remains 64 mm; the rim roundovers remove material
only from the outside edge of the 4 mm radial wall. This is an R1 trial because
no numeric rounding radius was specified. It needs a slicing/printing check.

The measured Apple MagSafe edge diameter is 56 mm and edge thickness is 5.5 mm.
The ring retains its 4 mm radial wall, 4.7 mm pocket depth, 2 mm retaining flange,
5 mm nominal clamp-arm gap, and internal alignment collar.

## Use and verification status

Open an entry point in OpenSCAD and render with F6. The files use the local
[shared geometry](shared/ring_geometry.scad); no complete model source or private
repository is required. The author has physically printed the 20 mm indexed
ring and reported that it fits well. The new textured/R1 variant has not yet
been printed; retain the tested untextured variant for comparison.

See the [component library](../README.md) for licensing and development policy.

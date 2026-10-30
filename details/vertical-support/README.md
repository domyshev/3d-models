# Vertical support

Origin: [Modular MagSafe Holder](../../models/magsafe_holder/README.md), compact
configuration development after v0.2. The complete model remains unchanged.

## Design stages

1. Earlier supports connected to a separate lower base ear using a lower fork.
2. [support.scad](support.scad) isolates the current direct-base design: the lower
   fork is removed, the rectangular column ends on a flat tabletop base, and
   four M12 studs connect directly to the side legs. The upper fork retains its
   inward-facing indexing teeth.
3. [support-shortened.scad](support-shortened.scad) removes exactly 10 mm from
   the straight rectangular column between the threaded-stud region and upper
   fork. The complete upper fork, bolt hole, and index rings move down together;
   their dimensions do not change. The base and all four stud axes stay fixed.
4. [support-shortened-textured.scad](support-shortened-textured.scad) adds a
   decorative satin-dimple pattern to all four outer vertical faces of the shortened
   support. Shallow spherical dimples form a regular staggered lattice rather
   than random roughness or simulated support-removal damage. The original
   shortened support remains available without this finish.
5. [support-rounded-hollow.scad](support-rounded-hollow.scad) extends the floor
   down by 1.5 mm, rounds the four external vertical corners with a 2 mm
   radius, raises the bridge between the upper arms by 8 mm, and introduces
   a small closed cavity above the stud roots. Its full outside skin is
   textured, including curved corners, ear crowns, outer fastener seating
   faces, and the raised bridge. The earlier physically printed textured
   support remains unchanged as a separate entry point.

### Rounded hollow evolution

The new variant has an exact Z=0 floor, stud axes at Z=14 mm, an upper bolt
axis at Z=62.5 mm, a bridge at Z=44 mm, and overall height 74 mm. The 14 mm
stud-axis height matches the 14 mm radius of the current round leg ends, so
the nominal stand floor and leg bearing surfaces share the same table plane.
The upper joint, M12 stud lengths/pitch, and XY stud positions are unchanged
relative to each other. Only the floor is extended down; the upper joint is
not lowered into the clamp. Raising the bridge reduces the fork opening by
8 mm; assembled holder clearance still needs physical verification.

The cavity envelope is 10.5 x 17.5 x 11.75 mm, between Z=26 and Z=37.75 mm.
Nominal shell allowance is 6.25 mm to retain at least 6 mm after the 0.25 mm
surface dimples. The material below and around the stud roots stays solid.
The cavity has 4.5 mm, 45-degree internal bevels and one 1.2 mm web to shorten
roof bridges. The enclosed void is intentionally modest rather than weakening
the threaded base. These features aid printing but do not constitute a tested
support-free slicing profile. Inspect the interior with `show_section = true`;
reset it to `false` before any export.

There is no texture on the base, inside the cavity, on the inward clamping
planes, in the bolt bore, or on the threaded studs. Narrow protective rims
remain around through-hole edges and stud roots. The outside ear faces have
texture rather than the previous large smooth fastener seating patches.
This new evolution has not yet been physically printed.

#### Smooth diagnostic control

[support-rounded-hollow-smooth-test.scad](support-rounded-hollow-smooth-test.scad)
disables only the decorative dimples to investigate sliced gaps in the upper
ears. Functional indexing teeth, rounded corners, cavity, raised bridge, stud
geometry, and all dimensions are unchanged. The textured entry point still
defaults to enabled texture. This is an A/B control, not a confirmed fix or a
change to the print-strength settings.

[support-rounded-hollow-limited-texture-test.scad](support-rounded-hollow-limited-texture-test.scad)
is the next diagnostic control after disabling texture removed the sliced ear
defects reported by the author. It restores the same dimples only below Z=50 mm:
62.5 mm upper-axis height minus 10.5 mm indexing-ring radius minus 2 mm clearance.
Complete spherical cutters must remain below this boundary, leaving the ear
region above it smooth. Cavity, indexing teeth, dimensions, upright orientation,
and print-strength settings are otherwise unchanged. The full-texture and smooth
controls remain available; this limited variant still needs slicing validation.

### Decorative surface

The textured variant uses 1.6 mm center spacing, a 0.6 mm cutter radius, and
0.25 mm recess depth (approximately 0.97 mm dimple openings). A smooth 1.5 mm
border frames the pattern. Smooth circular keepouts protect the upper fastener
seating areas and lower stud roots. Both broad Y-facing surfaces and narrow
X-facing vertical walls receive the pattern, including the straight arm edges
above the fork root. Smooth borders preserve the fork opening and rounded top.
The flat base, inward fork faces, indexing teeth, M12 studs, bolt
hole, and all mating dimensions are unchanged. This is modeled geometry, not a
slicer Fuzzy Skin setting. The original shortened textured support was printed
and reported to fit well by the author; the new rounded/hollow variant is untested.

## Dimensions

### Suspended rounded-bottom evolution

[support-rounded-bottom.scad](support-rounded-bottom.scad) retains the integral
studs and texture limit of the printed-support development branch, not the
separate-stud socket prototype. Its lowest central point is Z=1 mm instead of
Z=0; the lower envelope curves upward to meet the side walls at Z=4 mm.
The author measured 4 mm of safe removable height on the printed assembly:
1 mm is used for floor clearance and the remaining 3 mm for the rounded cap.
The earlier Z=8 mm shoulder was rejected because it intruded into the seating
region of the 17 mm leg roots, even though it cleared the 12 mm studs.

The 3 mm-deep cap is a rounded-rectangular ellipsoidal analogue, not an exact
sphere. It joins the vertical walls tangentially and has no flat sole. The new
curved underside is smooth. All geometry at and above Z=4 mm, including the
four studs, upper joint, cavity, raised bridge and texture boundary, remains
unchanged. This preserves a nominal 1 mm clearance above the table when the
leg ends support the assembly. The nominal lower edge of a 17 mm leg root is
Z=5.5 mm, leaving 1.5 mm above the top of the underside rounding. The existing
flat-bottom entry points
remain available. Inspect the underside or enable `show_section = true` to
review the material retained below the stud roots. This evolution still needs
physical testing; it transfers the load to the leg connections rather than
sharing it with the center's former sole.

### Flat sole and adjustable M6 foot

**Current default:** the author retired the leveling foot. `leveling_enabled`
is now `false`, so the latest stand has a closed flat sole without the M6
hole, and the ordinary/assembly views no longer display the leveling stud.
The Z=4 mm sole height, closed internal cavity, integral M12 studs, texture
boundary and successful ear tessellation remain unchanged. Set
`leveling_enabled = true` only to reproduce the historical design below.

[support-adjustable-base.scad](support-adjustable-base.scad) is a further
integral-stud evolution. It removes the rounded underside completely and
terminates the stand at a flat plane Z=4 mm. A centered, upward blind M6 x 1
socket is 10 mm deep, ending at Z=14 mm. The existing closed cavity begins
at Z=26 mm, leaving 12 mm of material above the socket. This is not the
open-bottom, replaceable-leg-stud prototype.

[leveling-stud-m6.scad](leveling-stud-m6.scad) is the separate headless foot:
6 mm nominal diameter, 12 mm overall length, with 0.3 mm roundovers on both
outer end rims. The bottom face has a flat-screwdriver slot 2.4 mm deep and
1.6 mm wide, providing 0.1 mm clearance per side for a 1.4 mm blade.
At 4 mm projection the foot reaches tabletop Z=0 and retains 8 mm of engagement,
with 2 mm remaining depth above its tip. The first-fit socket cutter is 6.35 mm
in diameter (0.35 mm diametral allowance); printed M6 fit is not yet validated.

With the historical leveling option enabled, use `part = "all"` for the stand
and a separate, slot-up presentation copy;
`"support"` or `"stud"` for individual geometry; `"assembly"` for the installed
foot; and `"section"` for a cutaway showing socket, stud and cavity separation.
The independent stud entry point has its slot at Z=0, facing down as installed.
Texture still stops 2 mm below the indexing rings; a narrow smooth border
protects the new sole. Existing leg axes, threads, upper fork and cavity are
unchanged. This adjustable foot is an unprinted prototype. Adjust it only to
contact the table, not to jack the stand up and unload the surrounding legs.

The support locally restores `$fn=0`, `$fa=12`, `$fs=2`, matching the successful
limited-texture control's tessellation (21 segments around the 13 mm bolt hole).
The earlier global 96-segment setting changed the upper ear/indexing mesh even
though only the base was intended to change. The separate leveling stud keeps
its 96-segment rounded envelope. The flat base, M6 socket, texture limit, and
all nominal joint dimensions are unchanged by this diagnostic correction.

### Replaceable-stud socket prototype

[support-threaded-sockets.scad](support-threaded-sockets.scad) replaces the four
integral studs with M12 x 1.75 female sockets, using the existing 12.7 mm thread
cutter. The stand remains 23 x 30 x 74 mm, all four socket axes remain at
Z=14 mm, and the original upper joint is unchanged. Texture stops below Z=50 mm;
the 17 mm leg-seating faces are smooth. This is an unprinted design study.

The cavity is now open down to the table, with a 10.5 x 17.5 mm nominal opening
between the reinforcements. The upper roof has 45-degree bevels. Four 18.7 mm
bosses provide a nominal 3 mm radial allowance around individual 12.7 mm
socket channels. Their lower 45-degree haunches and overlapping material form
a common load-carrying node; the earlier separate 1.2 mm rib is not retained.
Open passage area varies with height through this node.

Each socket channel extends 10.35 mm inward and opens into the central cavity.
The communicating channels intentionally remove the thin blind-end partitions
that four isolated 8.35 mm pockets would leave. This is NOT four independent
3 mm-walled tubes: neighbouring channels interrupt the deepest portions of
some threads. Along X the outermost approximately 5.15 mm has a fully circular
thread envelope; the deeper region has only partial circumference where the
channels meet. That local geometry needs fit and strength testing before use.

The intended separate stud insertion is 8 mm per socket, not the full channel
length. At 8 mm insertion, opposite X stud ends remain 7 mm apart, opposite Y
ends remain 14 mm apart, and the perpendicular nominal 12 mm stud envelopes
have at least 1 mm separation. A 16 mm connector would share 8 mm with the
stand and 8 mm with the existing leg. No new studs are exported by this study.

Use `view = "section"` to examine the internal node; reset to `"part"` for a
printable full-part export. Opening the cavity and replacing studs may improve
repairability, but material savings and improved strength are not validated.
The internal haunches and closed upper roof still need a slicing review.

| Feature | Original | Shortened |
| --- | ---: | ---: |
| Upper bolt axis above tabletop | 71 mm | 61 mm |
| Nominal overall height | 82.5 mm | 72.5 mm |
| Upper fork starts above tabletop | 44.5 mm | 34.5 mm |
| Four stud axes above tabletop | 12.5 mm | 12.5 mm |
| Column cross section | 23 x 30 mm | 23 x 30 mm |
| Upper arm thickness / nominal gap | 6 mm / 18 mm | 6 mm / 18 mm |
| Stud external projection / thread | 8 mm / M12 x 1.75 | 8 mm / M12 x 1.75 |

The copied body uses a 0.05 mm boolean overlap below the nominal floor. The four
radial stud axes are coplanar and symmetric in X/Y. Shortening does not alter
their thread phase, projection, or attachment overlap.

## Use and verification status

Open any entry point in OpenSCAD and render with F6. The local
[shared geometry](shared/support_geometry.scad) uses the vendored Dan Kirshner
thread library under `../shared/vendor/`. In preview, the existing thread
implementation displays simplified studs; F6 renders the actual threads.

The original shortened textured variant has been physically tested. The new
rounded/hollow variant remains an unprinted experiment. The original-height
entry point is a development snapshot, not a claim of release validation.
No print orientation, infill settings, or Bambu project is changed here.

See the [component library](../README.md) for licensing and development policy.

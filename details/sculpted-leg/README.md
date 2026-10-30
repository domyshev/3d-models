# Sculpted one-piece legs

Origin: [Modular MagSafe Holder](../../models/magsafe_holder/README.md),
direct-base compact support development toward v0.3. These are new, unprinted
component experiments, not replacements already integrated into a release.

## Evolution

1. The earlier leg used an 18 mm cylinder with blind threaded holes at both
   ends, a separate connector, and a 28 x 28 x 12 mm end block.
2. This variant combines the sleeve and end block into one continuous body.
   Only the stand-side blind M12 socket remains. No connector or second socket
   is needed. The root is reduced to 17 mm, the solid middle narrows smoothly,
   and an oblate, sphere-like foot replaces the rectangular block.
3. A fine recessed satin-dimple pattern extends around the sculpted body and
   foot. The straight root is smooth for future clip attachment. No additional
   constant-diameter clip seat is introduced in the middle.
4. The flat underside cut was removed: tightening the threaded leg does not
   guarantee a particular rotational orientation. The rounded end now retains
   its full envelope; thread, texture, neck, and maximum diameter are unchanged.
5. The thin waist was rejected after reviewing the handle-like silhouette.
   The current body only widens from the 17 mm root to a 28 mm cylindrical
   end. The end has a full 10 mm constant-diameter bearing band followed by
   a 2 mm outer-edge fillet and flat axial end face. There is no underside cut.
6. Only the short Y leg subsequently received a sphere-like domed end instead
   of the flat end face. Its cylindrical bearing band is 8 mm long, followed
   by an 8 mm deep ellipsoidal dome, with no end-face disk. The transition now
   reaches full diameter earlier, so total length remains 33.1 mm. The long
   X leg retains its 10 mm band and 2 mm edge fillet unchanged.
7. The short leg's dimples were extended across the dome to its axial tip.
   Dome cutters follow the ellipsoid's surface normals, keeping the nominal
   0.25 mm recess depth rather than fading out toward the end. One centered
   tip dimple finishes the pattern. The underlying shape remains unchanged.
8. The short leg's obsolete lower texture exclusion was removed. Dimples now
   continue around the complete bearing band and dome, independent of the
   leg's rotation after tightening. The long leg remains unchanged.
9. The long leg now reuses the short leg's exact widening profile, 8 mm bearing
   band, domed tip, and all-around texture. Its extra 12.4 mm is added only to
   the smooth 17 mm root. The socket stays at the stand-facing end and retains
   its original depth; no extra threaded cavity is introduced.

## Variants and dimensions

| Feature | X pair | Y pair |
| --- | ---: | ---: |
| File | [leg-x.scad](leg-x.scad) | [leg-y.scad](leg-y.scad) |
| Quantity in the compact base | 2 | 2 |
| Length from the stand face to outer tip | 45.5 mm | 33.1 mm |
| Straight root diameter / length | 17 / 22.75 mm | 17 / 10.35 mm |
| Minimum body diameter (no waist) | 17 mm | 17 mm |
| Blind thread diameter / pitch / depth | 12.7 / 1.75 / 8.35 mm | same |
| Thread-axis height above table | 12.5 mm | 12.5 mm |
| End band plus rounding length / maximum diameter | 16 / 28 mm | same |
| Constant-diameter end band | 8 mm | 8 mm |
| Terminal rounding | 8 mm deep dome | same |

The existing 12.7 mm thread cutter and library settings are retained from the
tested nut/socket interface. Nominal wall at the thread's major diameter is
2.15 mm. The full 17 mm short root extends 2 mm beyond the blind socket before
the taper starts; the long root adds another 12.4 mm of solid length. All
material beyond the socket is solid in the CAD model.

Both feet share exactly the same geometry and texture, without a flat underside
cut. The body widens with zero-slope joins at both ends of the transition.
The short leg reaches 28 mm diameter at X=17.1 mm, holds that diameter to
X=25.1 mm, then closes with an 8 mm axial / 14 mm radial ellipsoidal half-dome
at X=33.1 mm. This is deliberately sphere-like, not a mathematically spherical
hemisphere: it preserves the length and 8 mm bearing band without a thin waist.
For the long leg, all these head positions and texture cutters are translated
by 12.4 mm without scaling or redistributing any dimples.
The full 28 mm-diameter foot extends from Z=-1.5 to Z=26.5 in the source's
stand-floor coordinates. The root and socket remain concentric with the
support's studs at Z=12.5 mm. Removing the cut does not reduce the radius:
the foot now projects 1.5 mm below the stand's original floor. Equal contact
with that stand floor has not been restored by silently resizing the foot.

Lengths preserve the current direct-base assembly's outer extents: with a
23 x 30 mm support, the full X/Y span remains 114 x 96.2 mm. These are measured
from the current development geometry, not the older 110 x 78 mm base target.

## Texture and print testing

The dimples use the support's 1.6 mm spacing, 0.6 mm cutter radius, and
0.25 mm depth, distributed around the varying circumference in staggered rows.
Dimples start only once the widening profile can retain a 17 mm central
envelope after the 0.25 mm cut. Texture does not enter the threaded root.
Neither leg has a smooth lower strip: both bands and domes are textured all
around, with identical dimple positions relative to the end.
Neither variant has a planar underside cut.

The design target is 100% infill with five walls, pending slicing and physical
validation. A successful render alone does not validate strength, thread fit,
or resistance to overtightening. Tighten using the smooth root rather than
twisting the textured body. Both files retain the original stud-axis coordinates;
their rounded feet extend below Z=0. Place the part on the print bed in the
slicer before printing; the source view is not a validated print orientation.

Open either SCAD entry point and use F6 for actual thread geometry. Preview
uses a plain socket cutter. The dependency is the pinned Dan Kirshner
`threads.scad` 2.7 in `details/shared/vendor/`, independent of `models/`.
See the [component library](../README.md) for licensing and dependency notices.

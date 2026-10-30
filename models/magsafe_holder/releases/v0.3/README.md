# MagSafe Holder v0.3

## Release v0.3.1

Released on 2026-10-30.

Version 0.3.1 is a presentation-only update to v0.3.0. The GitHub release page
now displays all four assembly renders, and each PNG is also a downloadable
release asset. Geometry, STL files, print settings, and the Bambu project are
unchanged from v0.3.0. These images are CAD renders, not photographs.

Version 0.3 has one design, named simply **MagSafe Holder v0.3**. There is no
Compact or Full-Height selection for this version. This self-contained snapshot
combines the latest direct-base support, indexed MagSafe ring, integral rounded
legs, and textured clamp fasteners.

The Full-Height and Compact artifacts of v0.2 remain available as historical
releases; they are not alternative configurations of v0.3.

The support has four integral M12 attachment studs and a closed flat bottom:
there is no M6 leveling socket or leveling screw in this set. The separate
crosspiece, sleeve connectors and rectangular end blocks are no longer needed.
The feet are rotationally symmetric, with an 8 mm cylindrical contact band and
a textured domed end. The long leg extends only the smooth root of the short
leg; both ends have identical dimensions.
Both leg lengths belong to the same holder: two long legs run along X and two
short legs along Y. They are not different stand-height variants.

## Files and views

- [OpenSCAD source](src/magsafe_holder.scad), including its pinned thread library.
- [Individual STL files](stl/): six unique components; duplicate both leg files.
- [Bambu Studio project](bambu/magsafe_holder_v0.3_a1_mini.3mf): all eight pieces
  are independently movable objects, arranged for an A1 mini.

There is only one printable support: `stl/support.stl`. The source file
`components/vertical-support/support-adjustable-base.scad` builds the final
support using helpers from `support-rounded-hollow.scad`. These are implementation
dependencies, not two stand variants. The historical `adjustable` filename does
not indicate an active leveling socket: the v0.3 entry point disables it.

### How to see the assembled holder

The view switch is in the **SCAD source**, not in an STL file. An STL contains
fixed geometry and has no switch between separate parts and an assembled model.

1. Open [src/magsafe_holder.scad](src/magsafe_holder.scad) in OpenSCAD.
2. Near the beginning of the file, replace `part = "layout";` with:

   ```scad
   part = "assembly";
   ```

3. Press **F5** (Preview) to see the complete assembled holder. Depending on
   your keyboard, use **Fn+F5**, or choose **Design > Preview** from the menu.
4. To return to the separated, labeled parts, set `part = "layout";` and
   preview again. `show_labels` affects only this presentation layout.

There is currently no supplied STL of the whole assembled holder. To create
one for viewing, keep `part = "assembly";`, choose **Design > Render** (F6),
then **File > Export > Export as STL** and save it as `assembly.stl`.
That file is a visualization of the assembled product, not a print-in-place
model. For printing, use the individual STL files or the supplied Bambu project.

Individual-part selectors are `"ring"`, `"support"`, `"leg_x"`, `"leg_y"`,
`"bolt"` and `"nut"`. This release does not depend on the experimental
`details/` tree.

### Assembly images

No CAD software is needed to view the PNG files in
[images/assembly/](images/assembly/):

| Front-left perspective | Back-right perspective |
| --- | --- |
| ![Assembled holder, front-left perspective](images/assembly/front-left.png) | ![Assembled holder, back-right perspective](images/assembly/back-right.png) |

| Front | Back |
| --- | --- |
| ![Assembled holder, front view](images/assembly/front.png) | ![Assembled holder, back view](images/assembly/back.png) |

## Bill of materials and print strength

| Part | Quantity | Infill | Wall loops |
| --- | ---: | --- | ---: |
| Outer-textured indexed ring | 1 | 15% Grid | 2 |
| Upright hollow support, integral studs | 1 | 25% Grid; 100% Zig Zag at stud roots | 6 |
| Long rounded leg | 2 | 25% Grid; 100% Zig Zag at socket | 5 |
| Short rounded leg | 2 | 25% Grid; 100% Zig Zag at socket | 5 |
| Textured M12 clamp bolt | 1 | 100% Zig Zag | 5 |
| Textured M12 clamp nut | 1 | 100% Zig Zag | 5 |

STL filenames are ring.stl, support.stl, leg_x.stl (long), leg_y.stl (short),
bolt.stl and nut.stl. They are binary STL files, one component per file.

![Eight separate objects on the A1 mini plate](bambu/plate.png)

Printer: Bambu Lab A1 mini, 0.4 mm nozzle, 0.20 mm layers, white PolyTerra PLA.
Strength settings are per-object overrides: the global default is only 15%.
Supports are tree supports from the build plate only. The support stands upright
on its flat base. In the currently saved project, all four legs stand on their
socket ends with the rounded ends upward; the bolt and nut also stand upright.
Five non-printing volume modifiers preserve solid infill in the loaded regions:

- The support's bottom 22 mm of print height is solid, covering all four integral
  studs and their roots up to assembly Z=26 mm. The original modeled cavity
  above this region remains hollow.
- The first 10.35 mm of each leg, measured axially from its socket opening, is
  solid. This includes the 8.35 mm socket and its 2 mm backing.

All remaining support and leg regions use 25% infill with the original wall
counts. Ring and fastener strength settings and support settings are unchanged.
The final layout places the legs upright. All eight printable meshes were compared against the previous
project and are identical: no dimensions, textures or indexing teeth changed.
The modifiers affect slicing only; the SCAD and STL geometry is unchanged.
The deliberately modeled internal cavity remains hollow even with 100% infill.
Do not interpret the global infill percentage as the percentage of every object.

### Verified slice

The final upright-leg layout was sliced on 2026-10-30 with Bambu Studio 2.7.1.62.
The project contains one 180 x 180 mm plate with all eight objects and five local
strength modifiers. All six STL exports completed successfully, and the complete
plate sliced with no object skipped or outside the build area.
Estimated consumption is **109.60 g (34.78 m)**, including supports; estimated
total time is **4 h 55 min 40 s**. These are slicer estimates, not measured print
results. The supplied project contains the verified sliced output, and the plate
PNG shows the same upright-leg arrangement.

For comparison, the earlier horizontal-leg layout with optimized infill estimated
110.65 g and 5 h 25 min 46 s. Before infill optimization, the horizontal layout
estimated 121.88 g and 5 h 43 min 6 s. The final profile and orientation together
save approximately 10.1% of filament relative to that original estimate without
changing the exterior. The lighter settings still require physical load testing;
preserved loaded zones are not a guarantee of identical mechanical performance.

The [profile utility](tools/optimize_infill.py) documents the exact modifier
construction. Run it on the original unmodified v0.3 project, then re-slice the
output in Bambu Studio. Do not apply it twice to an already optimized project.

The inherited white-PLA preset sets the textured PEI bed to 65 degrees C.
Bambu Studio reports a bed-temperature warning for this filament. This setting
was retained from the existing print profile, not silently changed; review it
before printing. CLI preset-location and organic-support notices also occur.
Successful slicing does not substitute for inspecting the preview or test prints.

## Fit and testing notes

The overall design and core components have been physically printed and tested.
The latest outer-textured, indexed MagSafe ring has also been reprinted and
confirmed to fit and work correctly. Textured versions of the support and legs
were tested during development.

Not every component has been reprinted after the latest minor surface changes,
including the added texture on the bolt head and nut. These final decorative
revisions should not be interpreted as independently print-validated.
Separately, the lighter infill settings with localized reinforcement have been
verified by slicing, but have not yet been physically load-tested. Earlier
component tests do not establish the strength of the optimized print profile.

The nominal footprint is 114 x 96.2 mm. Foot axes are at 14 mm above the table;
the support's flat bottom is at 4 mm, so it intentionally clears the tabletop.
M12 studs project 8 mm; leg sockets are 8.35 mm deep. Avoid overtightening PLA
threads. Full infill does not eliminate layer-direction weakness at stud roots.

Support dimples stop 2 mm below the lower edge of the upper indexing disk.
The upper fork retains the known successful local tessellation. Inspect the
sliced fork walls before printing; do not confuse support paths with model walls.

Existing licensing and third-party notices in the model root apply, including
GPL-3.0-or-later for this distribution with Dan Kirshner's threads.scad 2.7.


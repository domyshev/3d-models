# Modular MagSafe Holder

## Project status

Version **0.1** has been assembled and tested as a functional desktop MagSafe
holder and phone stand. It holds an official Apple MagSafe Charger securely
and allows the phone to be removed without pulling the charger out of its
retaining ring.

The project is designed in OpenSCAD as a modular construction system. Individual
parts can be adjusted, reprinted, and replaced without rebuilding the entire
stand.

## Photos

| Front view | Rear view | Retaining ring without MagSafe |
| --- | --- | --- |
| ![Front view of the assembled MagSafe holder](images/magsafe-holder-front.png) | ![Rear view of the assembled MagSafe holder](images/magsafe-holder-rear.png) | ![MagSafe holder with the charger removed](images/magsafe-holder-empty-clamp.png) |

## Apple MagSafe compatibility

The official Apple MagSafe Charger was measured with calipers:

- outer diameter: **56 mm**;
- axial edge thickness: **5.5 mm**;
- the central magnetic surface protrudes approximately **0.8 mm** beyond the
  edge;
- working holder pocket depth: **4.7 mm**.

Measure other charger revisions before printing. Even a small dimensional
difference can noticeably change the clamping force.

## Release files

Version 0.1 includes:

- [nine individual STL files](releases/v0.1/stl/) for custom slicing;
- a ready-to-open [Bambu Studio project for the A1 mini](releases/v0.1/bambu/magsafe_holder_v0.1_a1_mini.3mf)
  with the complete 19-piece print set arranged on one plate.

The Bambu Studio project uses the **0.20 mm Standard** process, a **0.4 mm**
nozzle, and the **PolyTerra PLA @ BBL A1M** filament preset. Organic supports
are enabled. Threaded connectors, sleeves, bolts, and nuts use 100% Zig Zag
infill with five walls. The clamp ring, vertical support, threaded base, and
end blocks use the standard 15% Grid infill with two walls.

### Complete version 0.1 bill of materials

| Part | Quantity |
| --- | ---: |
| MagSafe clamp ring | 1 |
| Vertical support | 1 |
| Threaded base | 1 |
| Long sleeve | 2 |
| Short sleeve | 2 |
| Threaded end block | 4 |
| M12 hex-socket connector | 4 |
| M12 long bolt | 2 |
| M12 nut | 2 |
| **Total** | **19** |

The supplied project was test-sliced successfully in Bambu Studio 2.7.1.62
for the Bambu Lab A1 mini. The complete one-plate print uses **103.22 g**
(**32.76 m**) of filament: **97.43 g** (**30.92 m**) for the models and
**5.79 g** (**1.84 m**) for supports. Estimated model printing time is
**4 hours**, and the complete estimate including preparation and timelapse is
**4 hours 9 minutes**. Estimates vary with slicer and filament-profile updates.

## OpenSCAD view modes

Open [`magsafe_holder.scad`](src/magsafe_holder.scad) and change the `part`
value near the beginning of the file to switch between presentation, assembly,
and individual-part views:

```scad
part = "all";
```

The main presentation modes are:

- `"all"` — displays one of every current part in a labeled layout;
- `"assembly"` — displays the fully assembled stand;
- `"platform_preview"` — displays the assembled modular lower base;
- an individual part name — displays only that part for inspection or export.

Additional display options are controlled independently:

```scad
show_labels = true;
show_magsafe_reference = false;
```

`show_labels` controls the descriptive labels in the `"all"` layout.
`show_magsafe_reference` adds a translucent reference puck to the layout or
assembly. Labels are not included when individual parts are exported.

## Source and licensing

- [`src/magsafe_holder.scad`](src/magsafe_holder.scad) contains the complete
  parametric model and assembly views.
- [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) documents the vendored
  threading dependency.
- [`LICENSE`](LICENSE) describes the license currently applicable to this
  model and the intended future licensing direction.

The vendored dependency is included in the repository so the model opens and
renders without requiring users to configure a separate OpenSCAD library path.

## Version 0.1 highlights

- Securely holds an official Apple MagSafe Charger.
- The split upper ring is tightened with an M12 bolt. Its adjustable clamping
  force prevents the charger from being pulled out when the phone is removed.
- The phone angle and vertical support angle can be adjusted independently.
- The elevated phone position is convenient for viewing and charging at a
  desk.
- The stand provides good stability while using relatively little filament.
- The minimalist engineering design avoids large solid surfaces, reducing
  material use, weight, and print time.
- The modular construction allows a single component to be redesigned or
  replaced. Hopefully, it will also inspire custom variations of the stand.

## Engineering problems solved

### M12 printed fasteners

The M12 fasteners are sized to tolerate strong tightening without easily
breaking the printed plastic. Load-bearing threaded parts use reinforced print
settings and experimentally adjusted fit clearances.

### MagSafe retaining ring

The ring and clamp-arm geometry were refined through physical test fitting. An
annular alignment collar was added around the hole on one clamp arm:

- projection into the clamp gap: **3 mm**;
- radial wall thickness: **3 mm**;
- inner diameter: **13 mm**;
- outer diameter: **19 mm**.

The collar reduces severe arm misalignment during tightening, limits unsafe
angular displacement, and lowers the risk of breaking a clamp arm. It also
helps prevent excessive clamping and cable pinching.

### Modular lower cross base

The lower cross base combines several functions:

- central mounting point for the vertical support;
- load distribution in four directions;
- attachment points for replaceable threaded sockets and end blocks;
- adjustable base dimensions without reprinting the complete stand.

### Radial indexing teeth

Radial indexing teeth are included at the support and lower-cross joints. Once
the bolts are tightened, they lock the selected angles and resist unwanted
rotation.

Version 0.1 uses a smooth mating surface on the MagSafe clamp arms. This
configuration has been physically tested and securely holds the selected
angle. Matching indexing teeth may be evaluated in a future revision.

## Known version 0.1 limitations and version 0.2 plans

- The support feels taller than necessary. If the stand tips over, its height
  increases both the phone's fall distance and travel radius. The current base
  feels stable in use, but that does not eliminate the potential drop height.
- The lower cross is more complex than necessary, with one bolted joint for the
  support arms and a separate row of threaded connections for the lateral base
  members.

These areas are planned for revision in version **0.2**.

## Testing and printing

Version 0.1 was tested with the following configuration:

- filament: **Polymaker PolyTerra PLA Cotton White**, 1.75 mm;
- printer: **Bambu Lab A1 mini** without AMS;
- standard **0.4 mm** nozzle;
- threaded bolts, connectors, and load-bearing sockets: 100% infill and five
  walls;
- other components: standard 15% Grid infill and two walls.

The project was produced and tested in **August 2026**.

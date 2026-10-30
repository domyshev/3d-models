# Textured M12 clamp fasteners

Origin: the [Modular MagSafe Holder](../../models/magsafe_holder/README.md).
These components isolate the existing M12 bolt/nut dimensions and add the
same recessed satin-dimple finish used on the support and legs.

- [bolt-textured.scad](bolt-textured.scad): M12 x 1.75, 37.5 mm useful length,
  16 mm threaded end, 19 mm head across flats, 7.5 mm head height.
- [nut-textured.scad](nut-textured.scad): 19 mm across flats, 7.5 mm height,
  existing 12.7 mm internal-thread cutter.

Dimples are 0.25 mm deep, cut with 0.6 mm-radius spheres at 1.6 mm pitch. The
six external hex faces retain intact corner and end borders. The bolt's exposed
head end is textured; the underside bearing face, shank, and thread are not.
The nut's exposed top face is textured outside a protective thread margin;
its bottom bearing face and internal thread stay smooth. Across-flat dimensions
are not enlarged, and the nominal wrench size remains 19 mm.

This is decorative texture, not a new thread or fit revision. The raw fastener
modules reproduce the current model's dimensions and thread settings. They use
the pinned Dan Kirshner 2.7 library in `details/shared/vendor/`; no model source
is required. See the [component library](../README.md) for licensing. The new
surface finish has not yet been physically printed or sliced for release.

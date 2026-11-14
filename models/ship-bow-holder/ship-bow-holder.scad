// Ship bow holder and a thin profile gauge. All dimensions are in millimetres.
// Select "holder", "gauge", or "both" in the Customizer.
part = "holder"; // [both, holder, gauge]

length = 35;
base_width = 28.5;
base_height = 10;
wall_thickness = 10;
left_height = 26;
right_height = 10;
gauge_thickness = 0.2;
print_gap = 5;
curve_steps = 80;
round_radius = 6;
$fn = 48;

// Profile gauge v4 was physically fit-tested and approved on 2026-11-01.
// Both holder walls and the gauge use this same verified curve.
// Heights above the base: 26 mm at x=0, 15 mm at x=17.5, 10 mm at x=35.
function profile_height(t) = right_height + (left_height - right_height) * pow(1 - t, 2) + 4 * t * (1 - t);

module side_profile() {
    polygon(concat(
        [[0, 0], [length, 0]],
        [for (i = [curve_steps : -1 : 0])
            [length * i / curve_steps, profile_height(i / curve_steps)]]
    ));
}

// Extend below the bed before rounding, then trim at z=0 to keep it flat.
module outer_profile() {
    polygon(concat(
        [[0, -2 * round_radius], [length, -2 * round_radius]],
        [for (i = [curve_steps : -1 : 0])
            [length * i / curve_steps, base_height + profile_height(i / curve_steps)]]
    ));
}

module holder() {
    difference() {
        intersection() {
            minkowski() {
                translate([0, base_width - round_radius, 0])
                    rotate([90, 0, 0])
                        linear_extrude(height = base_width - 2 * round_radius)
                            offset(delta = -round_radius) outer_profile();
                sphere(r = round_radius);
            }
            translate([-round_radius, -round_radius, 0])
                cube([length + 2 * round_radius, base_width + 2 * round_radius,
                      base_height + left_height + round_radius]);
        }
        // Keep the slot walls and floor flat and the internal edges sharp.
        translate([-1, wall_thickness, base_height])
            cube([length + 2, base_width - 2 * wall_thickness,
                  base_height + max(left_height, right_height)]);
    }
}

module gauge() {
    linear_extrude(height = gauge_thickness)
        side_profile();
}

assert(round_radius > 0 && 2 * round_radius < base_width);
assert(base_width > 2 * wall_thickness, "The gap between the walls must be positive.");
assert(length > 0 && base_height > 0 && wall_thickness > 0 && gauge_thickness > 0);
assert(left_height > 0 && right_height > 0 && curve_steps >= 2);
assert(part == "both" || part == "holder" || part == "gauge", "Unknown part selection.");

if (part == "holder" || part == "both") holder();
if (part == "gauge") gauge();
if (part == "both") translate([length + print_gap, 0, 0]) gauge();

// One-piece compact-base leg. Local X is the leg axis; Z=0 is the stand floor.
// No dependency on complete models or sources outside the component library.
$fn = 96;
use <../../shared/vendor/dan-kirshner-threads/2.7/threads.scad>

leg_root_diameter = 17;
leg_thread_diameter = 12.7;
leg_thread_pitch = 1.75;
leg_socket_depth = 8.35;
leg_socket_back_wall = 2;
leg_root_length = leg_socket_depth + leg_socket_back_wall;
leg_axis_height = 12.5;
leg_foot_axis_length = 12;
leg_foot_diameter = 28;
leg_foot_straight_length = 10;
leg_foot_edge_radius = leg_foot_axis_length - leg_foot_straight_length; // 2 mm.
leg_short_straight_length = 8;
leg_short_dome_length = 8;
leg_x_length = 33.5 + leg_foot_axis_length; // 45.5 mm from stand face.
leg_y_length = 21.1 + leg_foot_axis_length; // 33.1 mm from stand face.
leg_color = "#F3E5C8";

leg_texture_pitch = 1.6;
leg_texture_radius = 0.6;
leg_texture_depth = 0.25;
leg_texture_floor_border = 1.5;
leg_texture_tip_border = 1.2;
leg_profile_samples = 240;
leg_epsilon = 0.05;

function leg_lerp(a, b, t) = a + (b-a)*t;
function leg_smooth(t) = t*t*(3-2*t);
function leg_foot_start(length, rounded_end = false) = rounded_end
    ? length - leg_short_straight_length - leg_short_dome_length
    : length - leg_foot_axis_length;
function leg_round_start(length, rounded_end = false) = length
    - (rounded_end ? leg_short_dome_length : leg_foot_edge_radius);
function leg_radius(length, s, textured = true, rounded_end = false) =
    s <= leg_root_length ? leg_root_diameter/2 :
    s < leg_foot_start(length, rounded_end)
        ? leg_lerp(leg_root_diameter/2, leg_foot_diameter/2,
            leg_smooth((s-leg_root_length)
                /(leg_foot_start(length, rounded_end)-leg_root_length))) :
    s <= leg_round_start(length, rounded_end) ? leg_foot_diameter/2 :
    rounded_end ? leg_foot_diameter/2 * sqrt(max(0,
        1-pow((s-leg_round_start(length, true))/leg_short_dome_length, 2))) :
    leg_foot_diameter/2 - leg_foot_edge_radius
        + sqrt(max(0, pow(leg_foot_edge_radius, 2)
            - pow(s-leg_round_start(length), 2)));

module leg_outer_body(length, textured, rounded_end = false) {
    // Include transition stations exactly, then sample each C1-smooth segment.
    stations = [0, leg_root_length, leg_foot_start(length, rounded_end),
        leg_round_start(length, rounded_end), length];
    profile = concat([[0, 0]], [
        for (segment = [0 : len(stations)-2])
            for (sample = [0 : leg_profile_samples/4-1])
                let(s = leg_lerp(stations[segment], stations[segment+1],
                    sample/(leg_profile_samples/4)))
                    [leg_radius(length, s, textured, rounded_end), s]
    ], rounded_end ? [[0, length]]
        : [[leg_radius(length, length, textured), length], [0, length]]);
    translate([0, 0, leg_axis_height])
        rotate([0, 90, 0])
            rotate_extrude(convexity = 4)
                polygon(profile);
}

module leg_socket_cutter() {
    translate([-leg_epsilon, 0, leg_axis_height])
        rotate([0, 90, 0])
            if ($preview)
                cylinder(d = leg_thread_diameter,
                    h = leg_socket_depth + leg_epsilon);
            else
                metric_thread(diameter = leg_thread_diameter,
                    pitch = leg_thread_pitch,
                    length = leg_socket_depth + leg_epsilon,
                    internal = true, leadin = 3);
}

module leg_dome_dimple_cutters(length) {
    // Place cutters along the ellipsoid normals for uniform recess depth.
    // Radial-only cutters would leave the near-axial tip almost smooth.
    a = leg_short_dome_length;
    b = leg_foot_diameter/2;
    offset = leg_texture_radius-leg_texture_depth;
    rings = 13;
    for (row = [0 : rings-1])
        let(theta = (row+0.5)*90/rings,
            r = b*cos(theta),
            count = max(3, round(2*PI*r/leg_texture_pitch)),
            nx = sin(theta)/a,
            nr = cos(theta)/b,
            magnitude = sqrt(nx*nx+nr*nr))
            // Leave room for one axial dimple at the pole without collisions.
            if (r >= 1.2*leg_texture_pitch)
                for (column = [0 : count-1])
                    let(phi = (column+(row%2)/2)*360/count,
                        cutter_r = r+offset*nr/magnitude,
                        height = leg_axis_height+cutter_r*sin(phi))
                        translate([
                            leg_round_start(length, true)+a*sin(theta)
                                + offset*nx/magnitude,
                            cutter_r*cos(phi), height
                        ])
                            sphere(r = leg_texture_radius, $fn = 16);
    translate([length+offset, 0, leg_axis_height])
        sphere(r = leg_texture_radius, $fn = 16);
}

module leg_dimple_cutters(length, rounded_end = false) {
    row_pitch = leg_texture_pitch*sqrt(3)/2;
    for (row = [0 : floor(length/row_pitch)])
        let(s = leg_root_length + leg_texture_pitch + row*row_pitch)
            if (s < length-leg_texture_tip_border
                && (!rounded_end || s < leg_round_start(length, true))
                && leg_radius(length, s, true, rounded_end)
                    >= leg_root_diameter/2 + leg_texture_depth)
                let(r = leg_radius(length, s, true, rounded_end),
                    count = max(12, round(2*PI*r/leg_texture_pitch)))
                    for (column = [0 : count-1])
                        let(angle = (column + (row%2)/2)*360/count,
                            cutter_r = r+leg_texture_radius-leg_texture_depth,
                            height = leg_axis_height+cutter_r*sin(angle))
                            if (rounded_end || height >= leg_texture_floor_border
                                + leg_texture_radius)
                                translate([s, cutter_r*cos(angle), height])
                                    sphere(r = leg_texture_radius, $fn = 16);
    if (rounded_end) leg_dome_dimple_cutters(length);
}

module sculpted_leg(length = leg_x_length, textured = true, rounded_end = false) {
    assert(length > leg_root_length + leg_foot_axis_length);
    assert(leg_root_diameter > leg_thread_diameter);
    assert(leg_root_length >= leg_socket_depth+leg_socket_back_wall);
    assert(leg_foot_diameter >= leg_root_diameter);
    assert(leg_foot_straight_length >= 10);
    assert(leg_foot_edge_radius > 0);
    assert(leg_foot_start(length, rounded_end) > leg_root_length);
    assert(!rounded_end || leg_short_straight_length >= 8);
    color(leg_color)
        difference() {
            leg_outer_body(length, textured, rounded_end);
            leg_socket_cutter();
            if (textured) leg_dimple_cutters(length, rounded_end);
        }
}

module sculpted_leg_extended_root(length = leg_x_length, textured = true) {
    // Reuse the exact short-leg profile AND texture, translated as one unit.
    // Only the smooth 17 mm root grows; the socket remains at the stand face.
    extension = length-leg_y_length;
    assert(extension >= 0);
    color(leg_color)
        difference() {
            union() {
                translate([extension, 0, 0])
                    leg_outer_body(leg_y_length, textured, true);
                if (extension > 0)
                    translate([0, 0, leg_axis_height])
                        rotate([0, 90, 0])
                            cylinder(d = leg_root_diameter,
                                h = extension+leg_epsilon);
            }
            leg_socket_cutter();
            if (textured)
                translate([extension, 0, 0])
                    leg_dimple_cutters(leg_y_length, true);
        }
}

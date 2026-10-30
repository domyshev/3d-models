// Evolution of the shortened support: a fine staggered satin-dimple finish.
// All four outward vertical faces are textured. Interfaces stay unchanged.
support_shortening = 10;
include <shared/support_geometry.scad>

texture_pitch = 1.6;
texture_sphere_radius = 0.6;
texture_depth = 0.25;
texture_edge_border = 1.5;
texture_stud_keepout_radius = bolt_diameter / 2 + 1.5;
texture_bolt_keepout_radius = stand_end_radius + 0.8;
texture_row_pitch = texture_pitch * sqrt(3) / 2;
texture_top_axis_z = stand_top_axis_height - compact_stand_bottom_z;
texture_stud_axis_z = compact_stand_stud_axis_height - compact_stand_bottom_z;
texture_top_z = texture_top_axis_z + stand_end_radius;
texture_fork_root_z = stand_upper_body_z - compact_stand_bottom_z;

assert(texture_depth > 0 && texture_depth < texture_sphere_radius);
assert(texture_pitch > 2 * texture_sphere_radius);

function texture_inside_face(x, z) =
    abs(x) <= stand_face_width / 2 - texture_edge_border
    && z >= texture_edge_border
    && (z <= texture_top_axis_z
        || x*x + pow(z - texture_top_axis_z, 2)
            <= pow(stand_end_radius - texture_edge_border, 2))
    // Leave room for a bolt head/nut on the outer fork face.
    && x*x + pow(z - texture_top_axis_z, 2)
        >= pow(texture_bolt_keepout_radius, 2)
    // Preserve the Y-directed stud and the entire attachment transition.
    && x*x + pow(z - texture_stud_axis_z, 2)
        >= pow(texture_stud_keepout_radius, 2);

module satin_dimple_cutters() {
    for (side = [-1, 1])
        for (row = [0 : floor(texture_top_z / texture_row_pitch)])
            for (column = [-8 : 8])
                let(
                    x = column * texture_pitch
                        + (row % 2) * texture_pitch / 2,
                    z = texture_edge_border + row * texture_row_pitch
                )
                    if (texture_inside_face(x, z))
                        translate([
                            x,
                            side * (stand_outer_thickness / 2
                                + texture_sphere_radius - texture_depth),
                            z
                        ])
                            sphere(r = texture_sphere_radius, $fn = 20);

    // The X-facing narrow walls end where the rounded upper ear begins.
    // Above the fork root, texture only the two arm edges, never the gap.
    for (side = [-1, 1])
        for (row = [0 : floor(texture_top_axis_z / texture_row_pitch)])
            for (column = [-10 : 10])
                let(
                    y = column * texture_pitch
                        + (row % 2) * texture_pitch / 2,
                    z = texture_edge_border + row * texture_row_pitch
                )
                    if (
                        abs(y) <= stand_outer_thickness / 2 - texture_edge_border
                        && z <= texture_top_axis_z - texture_edge_border
                        && (z <= texture_fork_root_z - texture_edge_border
                            || abs(y) >= stand_upper_gap / 2 + texture_edge_border)
                        && y*y + pow(z - texture_stud_axis_z, 2)
                            >= pow(texture_stud_keepout_radius, 2)
                    )
                        translate([
                            side * (stand_face_width / 2
                                + texture_sphere_radius - texture_depth),
                            y,
                            z
                        ])
                            sphere(r = texture_sphere_radius, $fn = 20);
}

module support_shortened_textured() {
    color(stand_color)
        difference() {
            detail_support();
            satin_dimple_cutters();
        }
}

support_shortened_textured();

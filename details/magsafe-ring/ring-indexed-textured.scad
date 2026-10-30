// Latest indexed ring, with outer-only dimples and R1 outer rim roundovers.
// Never cut the MagSafe seat, clamp arms, alignment collar, or indexing teeth.
include <shared/ring_geometry.scad>

ring_outer_edge_radius = 1;
ring_texture_pitch = 1.6;
ring_texture_cutter_radius = 0.6;
ring_texture_depth = 0.25;
ring_texture_join_keepout_angle = 22;

module ring_outer_dimple_cutters() {
    outer = ring_outer_diameter/2;
    bottom = magsafe_protrusion;
    top = magsafe_edge_thickness+flange_thickness;
    row_pitch = ring_texture_pitch*sqrt(3)/2;
    count = round(2*PI*outer/ring_texture_pitch);
    // Complete cutters remain clear of both flat annular faces.
    for (row = [0:floor((top-bottom)/row_pitch)])
        for (column = [0:count-1])
            let(z = bottom+0.9+row*row_pitch,
                a = (column+(row%2)/2)*360/count,
                radial = outer+ring_texture_cutter_radius-ring_texture_depth)
                if (z+ring_texture_cutter_radius < top-0.2
                    && a > ring_texture_join_keepout_angle
                    && a < 360-ring_texture_join_keepout_angle)
                    translate([radial*cos(a),radial*sin(a),z])
                        sphere(r = ring_texture_cutter_radius,$fn = 16);
}

module ring_indexed_textured() {
    color(holder_color)
        difference() {
            holder_with_index_inserts(outer_edge_radius = ring_outer_edge_radius);
            ring_outer_dimple_cutters();
        }
}

ring_indexed_textured();

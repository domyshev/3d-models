// Shared geometry for the plain-recess and indexed ring experiments.
// Derived from the indexed-ring component experiment.
$fn = 96;





// Parameters required by the imported, physically tested holder modules.
magsafe_diameter = 56;
magsafe_edge_thickness = 5.5;
magsafe_protrusion = 0.8;

ring_wall = 4;
pocket_depth = magsafe_edge_thickness - magsafe_protrusion;
flange_radial_width = 4;
flange_thickness = 2;
ring_outer_diameter = magsafe_diameter + 2 * ring_wall;
flange_opening_diameter = magsafe_diameter - 2 * flange_radial_width;
ring_inner_radius = magsafe_diameter / 2;
flange_relief_base_width = 4;
flange_relief_angles = [-90, 90, 180];

block_face_scale = 1.6;
block_radial_width = 20 * block_face_scale;
block_height_z = 22 * block_face_scale;
block_thickness = 6;
block_gap = 5;
block_corner_radius = 16;
removed_ring_width = 2 * block_thickness + block_gap;
block_join_overlap = 0.2;
flange_opening_radius = flange_opening_diameter / 2;
block_outer_y = removed_ring_width / 2 + block_join_overlap;
block_inner_x = sqrt(
    flange_opening_radius * flange_opening_radius
        - block_outer_y * block_outer_y
);
block_front_z = magsafe_protrusion;
block_hole_center_x = block_inner_x + block_radial_width / 2;
block_hole_center_z = block_front_z + block_height_z / 2;

block_hole_diameter = 13;
clamp_alignment_collar_depth = 3;
clamp_alignment_collar_radial_wall = 3;
clamp_alignment_collar_outer_diameter = block_hole_diameter
    + 2 * clamp_alignment_collar_radial_wall;

epsilon = 0.05;
holder_color = "#4F86C6";
insert_color = "#D88932";

// The holder receives only two plain cylindrical recesses. There are no
// teeth, tooth grooves, or insert geometry in the holder itself.
index_recess_diameter = 21;
index_recess_depth = 0.8;

// The loose insert is exactly 1 mm smaller than the recess diameter.
index_insert_diameter = index_recess_diameter - 1; // 20 mm.
index_insert_hole_diameter = block_hole_diameter; // 13 mm.
index_insert_body_thickness = index_recess_depth; // 0.8 mm.

index_tooth_count = 48;
index_tooth_height = 0.7;
index_tooth_valley_height = 0.1;
index_tooth_root_overlap = 0.05;
index_tooth_edge_inset = 0.05;
index_tooth_angular_fill = 0.9;
index_tooth_step_angle = 360 / index_tooth_count;

assert(
    index_insert_diameter == index_recess_diameter - 1,
    "The toothed insert must be 1 mm smaller than the cylindrical recess"
);
assert(
    index_insert_diameter > index_insert_hole_diameter,
    "The toothed insert needs material around the M12 clearance hole"
);
assert(
    index_recess_depth < block_thickness,
    "The cylindrical recess must not cut through a clamp arm"
);

function polar3(radius, angle, normal_position) = [
    radius * cos(angle),
    radius * sin(angle),
    normal_position
];

module cylindrical_recess_positive_y() {
    outer_face_y = block_gap / 2
        + block_thickness
        + block_join_overlap;

    translate([
        block_hole_center_x,
        outer_face_y + epsilon,
        block_hole_center_z
    ])
        rotate([90, 0, 0])
            cylinder(
                d = index_recess_diameter,
                h = index_recess_depth + 2 * epsilon
            );
}

module cylindrical_recesses() {
    cylindrical_recess_positive_y();
    mirror([0, 1, 0])
        cylindrical_recess_positive_y();
}

module holder_with_plain_recesses(outer_edge_radius = 0) {
    color(holder_color)
        difference() {
            circle_holder(outer_edge_radius);
            cylindrical_recesses();
        }
}

module index_tooth(tooth_index) {
    // Keep every tooth fully inside the annular body's inner and outer edges,
    // and leave a narrow angular valley between neighbours. This eliminates
    // coincident walls while the root still overlaps the body vertically.
    inner_radius = index_insert_hole_diameter / 2
        + index_tooth_edge_inset;
    outer_radius = index_insert_diameter / 2
        - index_tooth_edge_inset;
    center_angle = tooth_index * index_tooth_step_angle;
    half_step = index_tooth_step_angle
        * index_tooth_angular_fill / 2;
    left_angle = center_angle - half_step;
    right_angle = center_angle + half_step;
    root_height = index_insert_body_thickness
        - index_tooth_root_overlap;
    valley_height = index_insert_body_thickness
        + index_tooth_valley_height;
    peak_height = index_insert_body_thickness
        + index_tooth_height;

    points = [
        // Six-point planar root embedded in the flat insert body.
        polar3(inner_radius, left_angle, root_height),
        polar3(outer_radius, left_angle, root_height),
        polar3(outer_radius, center_angle, root_height),
        polar3(outer_radius, right_angle, root_height),
        polar3(inner_radius, right_angle, root_height),
        polar3(inner_radius, center_angle, root_height),

        // Two sloped roof facets meeting at the tooth ridge.
        polar3(inner_radius, left_angle, valley_height),
        polar3(outer_radius, left_angle, valley_height),
        polar3(outer_radius, center_angle, peak_height),
        polar3(outer_radius, right_angle, valley_height),
        polar3(inner_radius, right_angle, valley_height),
        polar3(inner_radius, center_angle, peak_height)
    ];

    faces = [
        [6, 7, 8], [6, 8, 11],
        [11, 8, 9], [11, 9, 10],
        [0, 2, 1], [0, 5, 2],
        [5, 3, 2], [5, 4, 3],
        [0, 1, 7], [0, 7, 6],
        [1, 2, 8], [1, 8, 7],
        [2, 3, 9], [2, 9, 8],
        [3, 4, 10], [3, 10, 9],
        [4, 5, 11], [4, 11, 10],
        [5, 0, 6], [5, 6, 11]
    ];

    polyhedron(points = points, faces = faces, convexity = 2);
}

module index_insert() {
    color(insert_color)
        render(convexity = 4)
            union() {
                difference() {
                    cylinder(
                        d = index_insert_diameter,
                        h = index_insert_body_thickness
                    );
                    translate([0, 0, -epsilon])
                        cylinder(
                            d = index_insert_hole_diameter,
                            h = index_insert_body_thickness
                                + 2 * epsilon
                        );
                }

                for (tooth_index = [0 : index_tooth_count - 1])
                    index_tooth(tooth_index);
            }
}

module positive_y_positioned_index_insert() {
    outer_face_y = block_gap / 2
        + block_thickness
        + block_join_overlap;
    recess_floor_y = outer_face_y - index_recess_depth;

    translate([
        block_hole_center_x,
        recess_floor_y,
        block_hole_center_z
    ])
        rotate([-90, 0, 0])
            index_insert();
}

module positioned_index_inserts() {
    positive_y_positioned_index_insert();
    mirror([0, 1, 0])
        positive_y_positioned_index_insert();
}

module holder_with_index_inserts(outer_edge_radius = 0) {
    union() {
        holder_with_plain_recesses(outer_edge_radius);
        positioned_index_inserts();
    }
}


module annulus(outer_diameter, inner_diameter, height) {
    difference() {
        cylinder(d = outer_diameter, h = height);
        translate([0, 0, -epsilon])
            cylinder(
                d = inner_diameter,
                h = height + 2 * epsilon
            );
    }
}

module ring_with_flange_raw() {
    union() {
        // The puck projects 0.8 mm above the front edge of this wall.
        translate([0, 0, magsafe_protrusion])
            annulus(
                ring_outer_diameter,
                magsafe_diameter,
                pocket_depth
            );

        // Bottom support: 2 mm thick and projecting 4 mm inward.
        translate([0, 0, magsafe_edge_thickness])
            annulus(
                ring_outer_diameter,
                flange_opening_diameter,
                flange_thickness
            );
    }
}

module ring_outer_rounding_envelope(radius) {
    bottom = magsafe_protrusion;
    top = magsafe_edge_thickness+flange_thickness;
    outer = ring_outer_diameter/2;
    steps = 16;
    assert(radius > 0 && 2*radius < top-bottom);
    assert(radius < ring_wall);
    profile = concat([[0,bottom]], [
        for (i = [0:steps]) let(a = -90+i*90/steps)
            [outer-radius+radius*cos(a),bottom+radius+radius*sin(a)]
    ], [
        for (i = [0:steps]) let(a = i*90/steps)
            [outer-radius+radius*cos(a),top-radius+radius*sin(a)]
    ], [[0,top]]);
    rotate_extrude(convexity = 4) polygon(profile);
}

module closed_ring_with_flange(outer_edge_radius = 0) {
    if (outer_edge_radius > 0) {
        intersection() {
            ring_with_flange_raw();
            ring_outer_rounding_envelope(outer_edge_radius);
        }
    } else {
        ring_with_flange_raw();
    }
}

module flange_relief_cut() {
    translate([0, 0, magsafe_edge_thickness - epsilon])
        linear_extrude(height = flange_thickness + 2 * epsilon)
            polygon([
                [ring_inner_radius, 0],
                [flange_opening_radius, -flange_relief_base_width / 2],
                [flange_opening_radius, flange_relief_base_width / 2]
            ]);
}

module flange_relief_cuts() {
    for (relief_angle = flange_relief_angles)
        rotate([0, 0, relief_angle])
            flange_relief_cut();
}

module split_ring_with_flange(outer_edge_radius = 0) {
    difference() {
        closed_ring_with_flange(outer_edge_radius);

        // Remove a straight 17 mm section on the +X side of the ring.
        translate([
            0,
            -removed_ring_width / 2,
            -epsilon
        ])
            cube([
                ring_outer_diameter / 2 + epsilon,
                removed_ring_width,
                magsafe_edge_thickness
                    + flange_thickness
                    + 2 * epsilon
            ]);

        // Three triangular flex cuts in the lower retaining flange.
        flange_relief_cuts();
    }
}

module clamp_block_profile_2d() {
    radius = block_corner_radius;
    width = block_radial_width;
    height = block_height_z;

    union() {
        // Full middle strips shared by all four corners.
        translate([0, radius])
            square([width, height - 2 * radius]);
        translate([radius, 0])
            square([width - 2 * radius, height]);

        // Keep the inner/front corner square where the block meets the ring.
        square([radius, radius]);

        // Round the other three free corners.
        translate([width - radius, radius])
            circle(r = radius);
        translate([radius, height - radius])
            circle(r = radius);
        translate([width - radius, height - radius])
            circle(r = radius);
    }
}

module upper_clamp_block() {
    overlap_thickness = block_thickness + block_join_overlap;

    translate([
        block_inner_x,
        block_gap / 2 + overlap_thickness,
        block_front_z
    ])
        rotate([90, 0, 0])
            linear_extrude(height = overlap_thickness)
                clamp_block_profile_2d();
}

module clamp_blocks() {
    // The two blocks occupy 6 mm each inside the removed 17 mm section.
    upper_clamp_block();
    mirror([0, 1, 0])
        upper_clamp_block();
}

module holder_inner_envelope_cuts() {
    // Keep the front portion flush with the Ø56 MagSafe circumference.
    translate([0, 0, -epsilon])
        cylinder(
            d = magsafe_diameter,
            h = magsafe_edge_thickness + 2 * epsilon
        );

    // Continue the blocks exactly to the cylindrical Ø48 boundary of the
    // retaining flange throughout their rearward extension.
    translate([0, 0, magsafe_edge_thickness - epsilon])
        cylinder(
            d = flange_opening_diameter,
            h = block_front_z
                + block_height_z
                - magsafe_edge_thickness
                + 2 * epsilon
        );
}

module clamp_bolt_hole() {
    translate([
        block_hole_center_x,
        -removed_ring_width / 2 - block_join_overlap - epsilon,
        block_hole_center_z
    ])
        rotate([-90, 0, 0])
            cylinder(
                d = block_hole_diameter,
                h = removed_ring_width
                    + 2 * block_join_overlap
                    + 2 * epsilon
            );
}

module clamp_alignment_collar() {
    // A single annular guide projects from the +Y clamp arm into the gap.
    // The common bolt-hole subtraction supplies its 13 mm inner diameter.
    translate([
        block_hole_center_x,
        block_gap / 2 + epsilon,
        block_hole_center_z
    ])
        rotate([90, 0, 0])
            cylinder(
                d = clamp_alignment_collar_outer_diameter,
                h = clamp_alignment_collar_depth + epsilon
            );
}

module circle_holder(outer_edge_radius = 0) {
    color(holder_color)
        difference() {
            union() {
                split_ring_with_flange(outer_edge_radius);
                clamp_blocks();
                clamp_alignment_collar();
            }

            clamp_bolt_hole();
            holder_inner_envelope_cuts();
        }
}

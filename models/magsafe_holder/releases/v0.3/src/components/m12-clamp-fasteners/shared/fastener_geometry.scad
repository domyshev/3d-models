// M12 geometry copied from the model's existing tested fastener dimensions.
// The only functional addition is recessed texture on non-bearing surfaces.
$fn = 96;
use <../../shared/vendor/dan-kirshner-threads/2.7/threads.scad>

clamp_bolt_diameter = 12;
clamp_bolt_pitch = 1.75;
clamp_hex_across_flats = 19;
clamp_head_height = 7.5;
clamp_nut_height = 7.5;
clamp_nut_thread_diameter = 12.7;
clamp_bolt_useful_length = 37.5;
clamp_bolt_thread_length = 16;
clamp_bolt_smooth_length = clamp_bolt_useful_length-clamp_bolt_thread_length;
clamp_texture_pitch = 1.6;
clamp_texture_radius = 0.6;
clamp_texture_depth = 0.25;
clamp_epsilon = 0.05;

module clamp_bolt_raw() {
    union() {
        cylinder(d = clamp_hex_across_flats/cos(30),h = clamp_head_height,$fn = 6);
        translate([0,0,clamp_head_height-clamp_epsilon])
            cylinder(d = clamp_bolt_diameter,
                h = clamp_bolt_smooth_length+2*clamp_epsilon);
        translate([0,0,clamp_head_height+clamp_bolt_smooth_length-clamp_epsilon])
            metric_thread(diameter = clamp_bolt_diameter,pitch = clamp_bolt_pitch,
                length = clamp_bolt_thread_length+clamp_epsilon,
                internal = false,leadin = 2,test = $preview);
    }
}

module clamp_nut_raw() {
    difference() {
        cylinder(d = clamp_hex_across_flats/cos(30),h = clamp_nut_height,$fn = 6);
        translate([0,0,-clamp_epsilon])
            metric_thread(diameter = clamp_nut_thread_diameter,pitch = clamp_bolt_pitch,
                length = clamp_nut_height+2*clamp_epsilon,
                internal = true,leadin = 2,test = $preview);
    }
}

function inside_clamp_hex(x,y,border) = max([
    for (face = [0:5]) x*cos(30+60*face)+y*sin(30+60*face)
]) <= clamp_hex_across_flats/2-border;

module clamp_hex_side_dimples(height) {
    a = clamp_hex_across_flats/2;
    row_pitch = clamp_texture_pitch*sqrt(3)/2;
    for (face = [0:5])
        for (row = [0:floor(height/row_pitch)])
            for (column = [-3:3])
                let(z = 0.9+row*row_pitch,
                    s = column*clamp_texture_pitch+(row%2)*clamp_texture_pitch/2,
                    angle = 30+60*face,
                    offset = a+clamp_texture_radius-clamp_texture_depth)
                    if (z+clamp_texture_radius < height-0.2
                        && abs(s)+clamp_texture_radius < a*tan(30)-0.4)
                        translate([offset*cos(angle)-s*sin(angle),
                            offset*sin(angle)+s*cos(angle),z])
                            sphere(r = clamp_texture_radius,$fn = 16);
}

module clamp_hex_end_dimples(z,normal_sign,inner_keepout = 0) {
    row_pitch = clamp_texture_pitch*sqrt(3)/2;
    for (row = [-8:8])
        for (column = [-8:8])
            let(x = column*clamp_texture_pitch+(row%2)*clamp_texture_pitch/2,
                y = row*row_pitch)
                if (inside_clamp_hex(x,y,0.9)
                    && (inner_keepout == 0 || x*x+y*y >= inner_keepout*inner_keepout))
                    translate([x,y,z+normal_sign*(clamp_texture_radius-clamp_texture_depth)])
                        sphere(r = clamp_texture_radius,$fn = 16);
}

module clamp_bolt_textured() {
    color("#E07A3F")
        difference() {
            clamp_bolt_raw();
            clamp_hex_side_dimples(clamp_head_height);
            // Z=0 is the exposed head end; the Z=7.5 bearing face stays smooth.
            clamp_hex_end_dimples(0,-1);
        }
}

module clamp_nut_textured() {
    color("#7E57C2")
        difference() {
            clamp_nut_raw();
            clamp_hex_side_dimples(clamp_nut_height);
            // Protect both the internal thread and the Z=0 clamping face.
            clamp_hex_end_dimples(clamp_nut_height,1,
                clamp_nut_thread_diameter/2+0.9);
        }
}


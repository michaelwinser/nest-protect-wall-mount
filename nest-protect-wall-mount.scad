SHOW_NEST = false;
SHOW_RIDGES = true;
SHOW_BASE = true;
SHOW_LIP = true;
SHOW_CUTOUT = true;
SHOW_STOPPER = true;



OUTER_DIAMETER = 117.6;
OUTER_RADIUS = OUTER_DIAMETER / 2;
HOLE_DIAMETER = 49.5;
HOLE_RADIUS = HOLE_DIAMETER / 2;
UNDER_RIDGE_RADIUS = HOLE_RADIUS + (OUTER_RADIUS - HOLE_RADIUS) * 0.66;


SCREW_HOLE_OFFSET = HOLE_RADIUS + (OUTER_RADIUS - HOLE_RADIUS) * 0.25;
SCREW_HOLE_RADIUS = 2;
SCREW_HOLE_BEVEL_RADIUS = 3.5;
SCREW_HOLE_SUPPORT_RADIUS = 4;

LIP_SIZE = 1.9;

MAIN_RADIUS = OUTER_RADIUS - LIP_SIZE;
MAIN_CIRCUMFERANCE = MAIN_RADIUS * 2 * PI;



OUTER_RIDGE_SIZE = 4.5;

RIDGE_SIZE = 1.7;

FIRST_RIDGE_RADIUS = HOLE_RADIUS;
LAST_RIDGE_RADIUS = MAIN_RADIUS - OUTER_RIDGE_SIZE; 

RIDGE_COUNT = 5;
RIDGE_SPACE = (LAST_RIDGE_RADIUS - FIRST_RIDGE_RADIUS) / (RIDGE_COUNT - 1);

INNER_RIDGE_RADIUS = HOLE_RADIUS + RIDGE_SIZE;

UPPER_ARROW_OFFSET = SCREW_HOLE_OFFSET + SCREW_HOLE_SUPPORT_RADIUS;
LOWER_ARROW_OFFSET = SCREW_HOLE_OFFSET + SCREW_HOLE_BEVEL_RADIUS;
ARROW_WIDTH = SCREW_HOLE_SUPPORT_RADIUS / 3 * 2;
UPPER_ARROW_DEPTH = LAST_RIDGE_RADIUS - UPPER_ARROW_OFFSET;
LOWER_ARROW_DEPTH = UNDER_RIDGE_RADIUS - LOWER_ARROW_OFFSET;




THICKNESS = 3.9;
RIDGE_THICKNESS = 1.5;
LIP_THICKNESS = 1;
BASE_THICKNESS = THICKNESS - RIDGE_THICKNESS - LIP_THICKNESS;
BEVEL_THICKNESS = LIP_THICKNESS + BASE_THICKNESS;

NEST_NOTCH_WIDTH = 9.2;

STOPPER_WIDTH = 1;
STOPPER_HEIGHT = THICKNESS;
STOPPER_DEPTH = LIP_SIZE;
STOPPER_ANGLE_OFFSET = - (NEST_NOTCH_WIDTH / 2 + SCREW_HOLE_RADIUS)  / MAIN_CIRCUMFERANCE  * 360;


CUTOUT_WIDTH = 20;
CUTOUT_CORNER_RADIUS = 3;
CUTOUT_DEPTH = LIP_SIZE * 2;
CUTOUT_ANGLE_OFFSET = STOPPER_ANGLE_OFFSET - CUTOUT_WIDTH / 2 / MAIN_CIRCUMFERANCE * 360;


$fn = 90;

nest_protect_mount_plate();
if (SHOW_NEST) nest_protect_mounting();


module nest_protect_mounting() {
    radius = 118.4 / 2;
    width = 135;
    depth = 135;
    height = 32;
    notch_width = 10;
    notch_depth = LIP_SIZE * 0.7;
    notch_height = 0.9;
    
     {
        difference() {
            translate([-width / 2, -depth / 2, -height]) cube([width, depth, height]);
            translate([0, 0, - LIP_THICKNESS * 2]) {
                cylinder(LIP_THICKNESS * 4, radius, radius);
            }
        }
    }
    
    for (angle = [0:120:240]) rotate([0, 0, angle]) {
        
        translate([-notch_width/2, radius - notch_depth, -notch_height]) cube([notch_width, notch_depth, notch_height]);
        
    }
        
    
}
module nest_protect_mount_plate() {
    difference() {
        union() {
            
            // The lip
            color("green") ring(LIP_THICKNESS, OUTER_RADIUS, HOLE_RADIUS);

            // The base
            translate([0, 0, LIP_THICKNESS]) {
                color("blue") ring(BASE_THICKNESS, MAIN_RADIUS, HOLE_RADIUS);
            }

            // Ridges
            translate([0, 0, LIP_THICKNESS + BASE_THICKNESS]) {
                color("red") ring(RIDGE_THICKNESS, MAIN_RADIUS, MAIN_RADIUS - OUTER_RIDGE_SIZE);
                for (r = [FIRST_RIDGE_RADIUS:RIDGE_SPACE:LAST_RIDGE_RADIUS]) {
                    color("red") ring(RIDGE_THICKNESS, r + RIDGE_SIZE, r);
                }
            }
            
            // Arrow
            translate([-ARROW_WIDTH / 2, UPPER_ARROW_OFFSET, LIP_THICKNESS + BASE_THICKNESS]) arrow(ARROW_WIDTH, UPPER_ARROW_DEPTH, RIDGE_THICKNESS);

            
            // stopper
            for (angle = [0:120:240]) rotate([0, 0, angle - STOPPER_ANGLE_OFFSET ] ) {
                translate([STOPPER_WIDTH / 2, MAIN_RADIUS, 0]) color("orange") cube([STOPPER_WIDTH, STOPPER_DEPTH, STOPPER_HEIGHT]);
            }
            
            for (angle = [0:90:270]) rotate([0, 0, angle]) {
                translate([0, SCREW_HOLE_OFFSET, 0]) {
                    cylinder(THICKNESS, SCREW_HOLE_SUPPORT_RADIUS, SCREW_HOLE_SUPPORT_RADIUS);
                }
            }
        } 
        union() {
            
            // cutouts
            for (angle = [0:120:240]) rotate([0, 0, angle - CUTOUT_ANGLE_OFFSET]) {
                translate([-CUTOUT_WIDTH / 2, OUTER_RADIUS - CUTOUT_DEPTH, -THICKNESS]) {
                    rounded_cube(CUTOUT_WIDTH, CUTOUT_DEPTH * 2, THICKNESS * 3, CUTOUT_CORNER_RADIUS);
                    
                }
            }

            // Arrow
            translate([-ARROW_WIDTH / 2, LOWER_ARROW_OFFSET, 0]) arrow(ARROW_WIDTH, LOWER_ARROW_DEPTH, RIDGE_THICKNESS);
            
            // Screw holes
            for (angle = [0:90:270]) rotate([0, 0, angle]) {
                translate([0, SCREW_HOLE_OFFSET, -THICKNESS]) {
                    cylinder(THICKNESS * 3, SCREW_HOLE_RADIUS);
                }
                translate([0, SCREW_HOLE_OFFSET, -0.1]) color("pink") cylinder(BEVEL_THICKNESS + 0.1, SCREW_HOLE_BEVEL_RADIUS, SCREW_HOLE_RADIUS);
            }
            
            translate([0, 0, -RIDGE_THICKNESS]) {
                ring(RIDGE_THICKNESS * 2, UNDER_RIDGE_RADIUS + RIDGE_SIZE, UNDER_RIDGE_RADIUS);
            }
                            
        }
    }    
}

module ring(height, outer_radius, inner_radius) {
    difference() {
        cylinder(height, outer_radius, outer_radius);
        color("blue") translate([0, 0, -height]) cylinder(height * 3, inner_radius, inner_radius);
    }
}


module rounded_cube(width, depth, height, corner_radius) {

    difference() {
        cube([width, depth, height]);
        union() {
            rounded_edge(corner_radius, height);
            translate([ width, 0, 0]) rotate([0, 0, 90]) rounded_edge(corner_radius, height);
            translate([width, depth, 0]) rotate([0, 0, 180]) rounded_edge(corner_radius, height);
            translate([0, depth, 0]) rotate([0, 0, 270]) rounded_edge(corner_radius, height);
        }
    }

    module rounded_edge(radius, height) {
        difference() {
            cube([radius, radius, height]);
            translate([radius, radius, -height]) {
                cylinder(height * 3, radius, radius);
            }
        }
    }
}


module arrow(width, depth, height, point_width = 0, point_depth = 0) {
    point_width = point_width == 0 ? width + width * 2 / 3 : point_width;
    point_depth = point_depth == 0 ? width  : point_depth;
    
    rect_depth = depth - point_depth;
        
    linear_extrude(height) polygon(
        points = [[0, 0], [width, 0], [width, rect_depth], [width / 2 + point_width /2, rect_depth], [width / 2, depth], [width/2 - point_width /2, rect_depth], [0, rect_depth]],
        paths = [[0, 1, 2, 3, 4, 5, 6]]
    );
}
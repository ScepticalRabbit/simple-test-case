//==============================================================================
// Gmsh 3D simple test case divertor armour mock-up
// author: Lloyd Fletcher (scepticalrabbit)
//==============================================================================
// Always set to OpenCASCADE - circles and boolean opts are much easier!
SetFactory("OpenCASCADE");

// Allows gmsh to print to terminal in vscode - easier debugging
General.Terminal = 0;

// View options - not required when
Geometry.PointLabels = 1;
Geometry.CurveLabels = 1;
Geometry.SurfaceLabels = 0;
Geometry.VolumeLabels = 0;

//-------------------------------------------------------------------------
//_* MOOSEHERDER VARIABLES - START
file_name = "stc.msh";

// Geometric variables
block_width = 25e-3;
block_leng = 50e-3;
block_armour = 8e-3;
block_height_square = 12.5e-3;
block_height_above_pipe = 12.5e-3+block_armour;
block_height_tot = block_height_square+block_height_above_pipe;

// Block half width must be greater than the sum of:
// block_width/2 >= pipe_rad_in+pipe_thick_fillet_rad
fillet_rad = 3e-3;
pipe_rad_in = 6e-3;
pipe_thick = 1.5e-3;
pipe_leng = 100e-3;

// Must be an integer
mesh_size = 2e-3;
num_threads = 4;
mesh_ref = 3;
//** MOOSEHERDER VARIABLES - END
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Calculated / Fixed Variables
pipe_loc_x = 0.0;
pipe_loc_y = block_height_square;

pipe_rad_out = pipe_rad_in + pipe_thick;
pipe_circ_in = 2*Pi*pipe_rad_in;

pipe_in_sect_nodes = 2*mesh_ref+1; // Must be odd
block_rad_nodes = 2*mesh_ref+1;
block_diff_nodes = 2*mesh_ref+1; // numbers of nodes along the rectangular extension
block_halfdepth_divs = 3*mesh_ref;

block_edge_nodes = Floor((pipe_in_sect_nodes-1)/2)+1;
elem_size = pipe_circ_in/(4*(pipe_in_sect_nodes-1));
tol = elem_size/4; // Used for bounding box selection tolerance

//------------------------------------------------------------------------------
// Geometry Definition

// Create the block and the outer pipe diam as solid cylinders
v1 = newv;
Box(v1) = {-block_width/2,0,0,
            block_width,block_height_tot,block_leng/2};
v2 = newv;
Box(v2) = {-block_width/2,0.0,-block_leng/2,
            block_width,block_height_tot,block_leng/2};

v3 = newv;
Cylinder(v3) = {pipe_loc_x,pipe_loc_y,block_leng/2,
                0.0,0.0,(pipe_leng/2-block_leng/2),pipe_rad_out,2*Pi};
v4 = newv;
Cylinder(v4) = {pipe_loc_x,pipe_loc_y,-block_leng/2,
                0.0,0.0,-(pipe_leng/2-block_leng/2),pipe_rad_out,2*Pi};

// Need to join the cylinder to the block to create a fillet
BooleanUnion{ Volume{v1}; Delete; }{ Volume{v3}; Delete; }
BooleanUnion{ Volume{v2}; Delete; }{ Volume{v4}; Delete; }

// Grab the curves between the pipe outer edge and the block to fillet
cf1() = Curve In BoundingBox{
    pipe_loc_x-pipe_rad_out-tol,pipe_loc_y-pipe_rad_out-tol,block_leng/2-tol,
    pipe_loc_x+pipe_rad_out+tol,pipe_loc_y+pipe_rad_out+tol,block_leng/2+tol};

cf2() = Curve In BoundingBox{
    pipe_loc_x-pipe_rad_out-tol,pipe_loc_y-pipe_rad_out-tol,-block_leng/2-tol,
    pipe_loc_x+pipe_rad_out+tol,pipe_loc_y+pipe_rad_out+tol,-block_leng/2+tol};

all_vols = Volume{:};
Fillet{all_vols(0)}{cf1(0)}{fillet_rad}
Fillet{all_vols(1)}{cf2(0)}{fillet_rad}

// Join the two halves of the block but maintain the dividing line
all_vols = Volume{:};
BooleanFragments{Volume{all_vols(0)}; Delete;}{Volume{all_vols(1)}; Delete;}

// Create the pipe bore
all_vols = Volume{:};
v5 = newv;
Cylinder(v5) = {pipe_loc_x,pipe_loc_y,-pipe_leng/2,
                0.0,0.0,pipe_leng,pipe_rad_in,2*Pi};
BooleanDifference{Volume{all_vols(0),all_vols(1)}; Delete;}
                {Volume{v5}; Delete;}
all_vols = Volume{:};

// Actual geometry complete - remainder are points for mech BCs
// For mech BCs on the base of the block
p1 = newp; Point(p1) = {0,0,0};
p2 = newp; Point(p2) = {0,0,block_leng/2};
p3 = newp; Point(p3) = {0,0,-block_leng/2};

// For mech BCs on the pipe
p4 = newp; Point(p4) = {pipe_loc_x+pipe_rad_in,pipe_loc_y+0.0,pipe_leng/2};
p5 = newp; Point(p5) = {pipe_loc_x+0.0,pipe_loc_y+pipe_rad_in,pipe_leng/2};
p6 = newp; Point(p6) = {pipe_loc_x-pipe_rad_in,pipe_loc_y+0.0,pipe_leng/2};
p7 = newp; Point(p7) = {pipe_loc_x-0.0,pipe_loc_y-pipe_rad_in,pipe_leng/2};

p8 = newp; Point(p8) = {pipe_loc_x+pipe_rad_in,pipe_loc_y+0.0,-pipe_leng/2};
p9 = newp; Point(p9) = {pipe_loc_x+0.0,pipe_loc_y+pipe_rad_in,-pipe_leng/2};
p10 = newp; Point(p10) = {pipe_loc_x-pipe_rad_in,pipe_loc_y+0.0,-pipe_leng/2};
p11 = newp; Point(p11) = {pipe_loc_x-0.0,pipe_loc_y-pipe_rad_in,-pipe_leng/2};

p12 = newp; Point(p12) = {pipe_loc_x+pipe_rad_out,pipe_loc_y+0.0,pipe_leng/2};
p13 = newp; Point(p13) = {pipe_loc_x+0.0,pipe_loc_y+pipe_rad_out,pipe_leng/2};
p14 = newp; Point(p14) = {pipe_loc_x-pipe_rad_out,pipe_loc_y+0.0,pipe_leng/2};
p15 = newp; Point(p15) = {pipe_loc_x-0.0,pipe_loc_y-pipe_rad_out,pipe_leng/2};

p16 = newp; Point(p16) = {pipe_loc_x+pipe_rad_out,pipe_loc_y+0.0,-pipe_leng/2};
p17 = newp; Point(p17) = {pipe_loc_x+0.0,pipe_loc_y+pipe_rad_out,-pipe_leng/2};
p18 = newp; Point(p18) = {pipe_loc_x-pipe_rad_out,pipe_loc_y+0.0,-pipe_leng/2};
p19 = newp; Point(p19) = {pipe_loc_x-0.0,pipe_loc_y-pipe_rad_out,-pipe_leng/2};

BooleanFragments{Volume{:}; Delete;}
{Point{p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18}; Delete;}

//------------------------------------------------------------------------------
// Physical surfaces and volumes for export/BCs
/*
Physical Volume("stc-vol") = {Volume{:}};

// Physical surface for mechanical BC for dispy - like sitting on a flat surface
ps1() = Surface In BoundingBox{
    -block_width/2-tol,0.0-tol,-block_leng/2-tol,
    block_width/2+tol,0.0+tol,block_leng/2+tol};
Physical Surface("bc-base-disp") = {ps1(0),ps1(1)};

// thermal BCs for top surface heat flux and pipe htc
ps2() = Surface In BoundingBox{
    -block_width/2-tol,block_height_tot-tol,-block_leng/2-tol,
    block_width/2+tol,block_height_tot+tol,block_leng/2+tol};
Physical Surface("bc-top-heatflux") = {ps2(0),ps2(1)};

ps3() = Surface In BoundingBox{
    pipe_loc_x-pipe_rad_in-tol,pipe_loc_y-pipe_rad_in-tol,-pipe_leng/2-tol,
    pipe_loc_x+pipe_rad_in+tol,pipe_loc_y+pipe_rad_in+tol,pipe_leng/2+tol};
Physical Surface("bc-pipe-htc") = {ps3(0),ps3(1)};
*/

/*
// Physical points for applying mechanical BCs - Lines don't work in 3D
// Center of the base of the block - lock all DOFs
pp0() = Point In BoundingBox{
    -tol,-tol,block_depth/2-tol,
    +tol,+tol,block_depth/2+tol};
Physical Point("bc-c-point-xyz-mech") = {pp0(0)};

// Left and right on the base center line
pp1() = Point In BoundingBox{
    -block_width/2-tol,-tol,block_depth/2-tol,
    -block_width/2+tol,+tol,block_depth/2+tol};
Physical Point("bc-l-point-yz-mech") = {pp1(0)};

pp2() = Point In BoundingBox{
    block_width/2-tol,-tol,block_depth/2-tol,
    block_width/2+tol,+tol,block_depth/2+tol};
Physical Point("bc-r-point-yz-mech") = {pp2(0)};

// Front and back on the base center line
pp3() = Point In BoundingBox{
    -tol,-tol,block_depth-tol,
    +tol,+tol,block_depth+tol};
Physical Point("bc-f-point-xy-mech") = {pp3(0)};

pp4() = Point In BoundingBox{
    -tol,-tol,0.0-tol,
    +tol,+tol,0.0+tol};
Physical Point("bc-b-point-xy-mech") = {pp4(0)};
*/
//------------------------------------------------------------------------------
// Mesh Sizing
MeshSize{ PointsOf{ Volume{:}; } } = mesh_size;

//------------------------------------------------------------------------------
// Global meshing
Mesh.Algorithm = 6;
Mesh.Algorithm3D = 10;

General.NumThreads = num_threads;
Mesh.MaxNumThreads1D = num_threads;
Mesh.MaxNumThreads2D = num_threads;
Mesh.MaxNumThreads3D = num_threads;

Mesh.ElementOrder = 2;
//Mesh 3;

//------------------------------------------------------------------------------
// Save and exit
//Save Str(file_name);
//Exit;

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

BooleanUnion{ Volume{v1}; Delete; }{ Volume{v3}; Delete; }

all_volumes = Volume{:};


/*
v5 = newv;
Cylinder(v5) = {pipe_loc_x,pipe_loc_y,0.0,
                0.0,0.0,pipe_leng/2,pipe_rad_in,2*Pi};
v6 = newv;
Cylinder(v6) = {pipe_loc_x,pipe_loc_y,0.0,
                0.0,0.0,-pipe_leng/2,pipe_rad_in,2*Pi};

BooleanDifference{Volume{all_volumes()}; Delete;}
                 {Volume{v5,v6}; Delete;}
*/

Fillet{29}{40}{fillet_rad}
//Fillet{6,3}{25}{fillet_rad}

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
Mesh 3;

//------------------------------------------------------------------------------
// Save and exit
//Save Str(file_name);
//Exit;
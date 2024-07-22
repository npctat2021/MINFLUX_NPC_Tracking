# MINFLUX_NPC_Tracking
The codes are specifically designed for analyzing two-color data obtained through 3D-MINFLUX. The 'Red' color corresponds to the nuclear pore complex (NPC), while the 'Green/Yellow' color represents the 3D second color used for tracking cargo moving through the NPC.

A model dataset named "Nuclear Pore Model Data.mat" contains the raw data exported from the MINFLUX microscope. Users can filter and isolate the tracks based on EFO, CFR, and track length parameters using the "filterMinfluxData.m" script. The extracted data can then be used for further analysis.

Additionally, four other model datasets are provided for running the two-color colocalization scripts:

"Nuclear Pore Model Data.txt" contains filtered 3D MINFLUX localizations from permeabilized functional NPCs.
"Tracks Model Data.txt" contains track data with five columns: 'Track Id', 'Time stamp (second)', x (meter), y (meter), and z (meter).
Typically, MINFLUX data output is in seconds and meters. The following scripts will convert these to milliseconds and nanometers. Data for bead localization in two channels is also attached (Bead loc_Red.txt and Bead loc_Yellow.txt) as model data, which will help generate an alignment matrix to correct the optical aberration between the two colors.

The pore data must be analyzed first to obtain the pore centers and other relevant information. Second, the alignment matrix is required to align the second color, and then the track data must be analyzed to yield individual tracks with respect to each individual pore. Detailed explanations are provided at the top of each script and in the README sections.

Note: 19 scripts are attached, requiring specific input files:

1. "Nuclear Pore Model Data.mat" for Program 1.
2. "Nuclear Pore Model Data.txt" for Program 2.
3. "Bead loc_Red.txt" and "Bead loc_Yellow.txt" for Program 14.
4. "Tracks Model Data.txt" for Program 15.

Common errors may occur from not changing the folder name or not applying the correct pore/cluster numbers.
## System Requirements
The analysis requires MATLAB software to run the codes.
MATLAB>R2021b with Add-On:
1. Statistics and Machine Learning Toolbox
2. Signal Processing Toolbox
3. Optimization Toolbox
4. Mapping Toolbox
5. Image Processing Toolbox
6. Curve Fitting Toolbox
Any standard computer with sufficient RAM to meet MATLAB's requirements can be used for this purpose. The analysis was conducted using a Windows 11 Home version 10.0.22631.

## Installation Guide
MATLAB software can be installed from [mathworks website](https://www.mathworks.com/help/install/install-products.html). A typical installation time is ~15-30 min.

## Instructions for use
Detailed explanations are provided at the top of each script and in the following README sections.
#### Filter MINFLUX data
1. **Program Name** :filterMinfluxData.m
(a) **Input file(s)**:Matlab version (.mat) of MINFLUX raw data file for pore scaffold and cargo. As model data "Nuclear Pore Model Data.mat".
(b) **Output file(s)**:	Track_data_array, Track_ID, Time, Coordinates
(c) **What it does**: Refine MINFLUX data by applying filters for EFO, CFR, DCR, and track length parameters to separate individual localizations or tracks whose localizations meet the average criteria for EFO, CFR, and DCR. Include track ID, timestamp, and XYZ coordinates for valid tracks. The following window will pop up, allowing the user to select their filtering criteria.

<a href="https://imgbb.com/"><img src="https://i.ibb.co/L5qS5rB/Filter-tracks.png" alt="Filter-tracks" border="0"></a>

Note: Place the following command in the command box after running this script to obtain the track ID, timestamp, and XYZ coordinates of the filtered tracks as output in "track_data_array".
length = cellfun(@(x) size(x, 1), ans.tracks);
track_data_array = double (repelem(ans.track_ID, length));
track_data_array(:, 2:5) = vertcat(ans.tracks{:});

Create a text file of pore/track localizations containing 5 columns: track ID, timestamp, and XYZ coordinates. For a trial, use the model data "Nuclear Pore Model Data.txt" for pores and "Tracks Model Data.txt" for tracks. Use these text files as input for Script 2 (separate_cluster_MINFLUX.m) for pores or Script 15 (green_localization_in_red_channel_MINFLUX.m) for tracks.

#### Fitting Nuclear Pore localizations
2. **Program Name** :separate_cluster_MINFLUX.m
(a) **Input file(s)**:Scaffold localization.txt.(should contain track ID, timestamp, and XYZ coordinates)
(b) **Output file(s)**:	Invidual cluster with cluster number
(c) **What it does**:Extracts the ID, timestamp, and coordinates of individual cluster into separate text files.
The cluster should be manually selected. Upon running the program, a window with scatter plots will open. One need to draw a rectangle around the cluster and double-clicking inside the rectangle will save a cluster. This process should be repeated until all pores are selected. Once done, the clusters should be saved, and then the figure can be closed. An error message will appear at the end, but it can be ignored. An image for cluster selection for the "Nuclear Pore Model Data" is attached.

<a href="https://ibb.co/1zNS9ZY"><img src="https://i.ibb.co/NTq4Lxg/Cluster-fitting-for-model-pore.png" alt="Cluster-fitting-for-model-pore" border="0"></a>

4. **Program Name** :estimate_cylinder_MINFLUX.m
(a) **Input file(s)**:It takes input of clusters information from the output of Program 2
(b) **Output file(s)**:	Coordrinates of centers of the clusters from double circle fit of two rings and diamters and separation distance between tworings.(Ex- 
clusterx_center.txt, clustery_center.txt, clusterz_center.txt, clusterdiameter.txt, clusterheight.txt)
(c) **What it does**:Double circle fitting of  two rings from individual cluster. Image attached.
<a href="https://ibb.co/T4wDBpY"><img src="https://i.ibb.co/qNDLMX7/Double-circle-Fitting-of-cluster.png" alt="Double-circle-Fitting-of-cluster" border="0"></a>

6. **Program Name** :select_pores_MINFLUX.m
(a) **Input file(s)**:It takes input from fitting parameters (x, y, z coordrinates,diameter, height)from the output of Program 3
(b) **Output file(s)**:	Selected clusters which qualify as pores. ( 1pore.txt, 2pore.txt....porex_center.txt, porey_center.txt, porez_center.txt, porediameter.txt, poreheight.txt)
(c) **What it does**:Selects those clusters having at least 20 localizations with a fit diameter. For example of diameter of70-150 nm, a height of 25-100 nm, and z-center of 0±200 nm.

7. **Program Name** :circlefit_bisquare_MINFLUX.m
(a) **Input file(s)**:x, y, z coordrinates from pores, the output of Program 4
(b) **Output file(s)**:	1porebisquare.txt, 2porebisquare.txt...
(c) **What it does**:Fits pore localizations to a circle projected into the xy-plane and eliminates localizations whose residual was more than two standard deviations away from the circle.

#### Rotation of NPC Scaffold Localization
6. **Program Name** :pore_rotation_MINFLUX_step1.m
(a) **Input file(s)**:porebisquare.txt porex_center.txt porey_center.txt, outputs of Program 5
(b) **Output file(s)**:	1pore_ninety_normalized.txt 2pore_ninety_normalized.txt etc.
(c) **What it does**:Finds the angle (0-90º) of each localization in a cluster relative to the centroid.

7. **Program Name** :pore_rotation_MINFLUX _step2.m
(a) **Input file(s)**:1pore_ninety_normalized.txt 2pore_ninety_normalized.txt..,outputs of Program 6
(b) **Output file(s)**:	1pore_fortyfive.txt, 2pore_fortyfive.txt etc.
(c) **What it does**:Finds the angle (0-45º) of each point in a pore in a cluster relative to the centroid.

8. **Program Name** :pore_rotation_MINFLUX _step3.m
(a) **Input file(s)**:1pore_fortyfive.txt, 2pore_fortyfive.txt etc.,outputs of Program 7
(b) **Output file(s)**:1phase_norm.txt, 2phase_norm.txt, etc.
(c) **What it does**:Determines the angle distribution histogram (0-45º) of the localizations in each cluster with a bin of 5º

9. **Program Name** :pore_rotation_MINFLUX_step4_fitting.m
(a) **Input file(s)**:1phase_norm.txt, 2phase_norm.txt etc.,outputs of Program 8
(b) **Output file(s)**:rot_angle.txt
(c) **What it does**:Determines the angle of rotation for the cluster by fitting the angle distribution histogram to a sinusoidal function with a period of 45° and a variable phase. Image attached.

<a href="https://ibb.co/7bXV0Rj"><img src="https://i.ibb.co/Ws6FRPG/Angle-fit.png" alt="Angle-fit" border="0"></a>

11. **Program Name** :centering_pore_MINFLUX _step5.m
(a) **Input file(s)**:porex_center.txt, porey_center.txt, porez_center.txt ,1porebisquare.txt, 2porebisquare.txt etc, outputs from Program 4
(b) **Output file(s)**:1pore_centered.txt, 2pore_centered.txt, etc.
(c) **What it does**:Translates the center of all clusters to (x, y, z) = (0, 0, 0)

12. **Program Name** :pore_rotation_MINFLUX _step6.m
(a) **Input file(s)**:rot_angle.txt, 1pore_centered.txt, 2pore_centered.txt, etc. outputs from Program 10
(b) **Output file(s)**:1pore_centered.txt, 2pore_centered.txt, etc.
(c) **What it does**:Rotates every point in a cluster by its phase angle.

#### Merging Pore localizations after rotation.
12. **Program Name** :merge_after_rotation_MINFLUX _step7.m
(a) **Input file(s)**:1pore_centered.txt, 2pore_centered.txt, etc. outputs from Program 11.
(b) **Output file(s)**:pore_merged_rotated.txt
(c) **What it does**:Merges all the localizations from all clusters.

13. **Program Name** :pore_rotate_back_MINFLUX_step8.m
(a) **Input file(s)**:pore_merged_rotated.txt, output from Program 12.
(b) **Output file(s)**:pore_merged_rotated back.txt
(c) **What it does**:There is always a 8.4 degree inherent rotation of pore. This step compensates for that inherent rotation of pore.

#### Creating alignment Matrix for two colors.
14. **Program Name** :green2red_transfer_matrix_MINFLUX.m
(a) **Input file(s)**: Separate text files for gold/ fluorescent beads localized in two colors containing  three columns for x, y,z obtained from beads localization.( use model input , Bead loc_Red.txt" and "Bead loc_Yellow.txt)
(b) **Output file(s)**:g2r_transfer_matrix.txt
(c) **What it does**:Calculates the image alignment matrix to transform green channel coordinates into the red channel coordinate system. Image attached.

<a href="https://ibb.co/bHn1mcz"><img src="https://i.ibb.co/KNH6hTF/Alignment-Matrix.png" alt="Alignment-Matrix" border="0"></a>

#### Alignment of track localization relative to the NPC scaffold.
15. **Program Name** :green_localization_in_red_channel_MINFLUX.m
(a) **Input file(s)**: The text file from track localization includes track ID, timestamp, and x, y, z coordinates in the second color obtained from cargo tracking (use model data 'Tracks Model Data.txt') , as well as the 'g2r_transfer_matrix.txt' file, which contains the alignment matrix for the two colors.
(b) **Output file(s)**: Optical abberation corrected track localizations.(file_name 'Tracks Model Data_calib.txt')
(c) **What it does**:Transforms the green/yellow channel coordinates of tracks into the red channel coordinate system to correct for chromatic aberration between the two colors.

16. **Program Name** :track_localize_whole_roi_MINFLUX.m
(a) **Input file(s)**: Track localizations in red color which is used for NPC scaffold localizations (Tracks Model Data_calib.txt'). 
(b) **Output file(s)**: Tracks associated to each pore.(track to whole1.txt, track to whole2.txt etc.)
(c) **What it does**:Identifies tracks localizations within a 200 nm cube centered on an NPC centroid.

17. **Program Name** :centering_tracks_wrt_whole_MINFLUX.m
(a) **Input file(s)**: porex_center.txt; porey_center.txt; porez_center.txt;track to whole1.txt;track to whole2.txt etc. 
(b) **Output file(s)**: track_cen_wrt_whole1.txt; track_cen_wrt_whole2.txt;etc. 
(c) **What it does**:Translates cargo complex localizations to the averaged NPC scaffold.

18. **Program Name** :track_rotation_in_whole_MINFLUX.m
(a) **Input file(s)**: rot_angle.txt; track_cen_wrt_whole1.txt; track_cen_wrt_whole2.txt etc. 
(b) **Output file(s)**: track to whole rotated1.txt; track to whole rotated2.txt etc. 
(c) **What it does**:Rotates track localizations according to the phase angle of their associated pore cluster.

19. **Program Name** :merge_after_rotation_whole_MINFLUX.m
(a) **Input file(s)**: track to whole rotated1.txt; track to whole rotated2.txt etc.
(b) **Output file(s)**: track_merged_rotated_whole.txt
(c) **What it does**: Merge MINFLUX tracks after rotation.

20. **Program Name** :merge_after_rotation_whole_MINFLUX.m
(a) **Input file(s)**: track to whole rotated1.txt; track to whole rotated2.txt etc.
(b) **Output file(s)**: track_merged_rotated_whole.txt
(c) **What it does**: Merge MINFLUX tracks after rotation.

## Demo
Sample data has been uploaded on Github. 
1. "Nuclear Pore Model Data.mat"
2. "Nuclear Pore Model Data.txt"
3. "Bead loc_Red.txt" and "Bead loc_Yellow.txt"
4. "Tracks Model Data.txt"  


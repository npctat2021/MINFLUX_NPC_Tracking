# MINFLUX_NPC_Tracking
The codes are specifically tailored for analyzing two-color data obtained through 3D-MINFLUX. The first color corresponds to the nuclear pore complex (NPC), while the second color represents the 3D tracks of cargo moving through the NPC. For detailed information about the scripts, please consult "Code_Description.pdf". This document offers a thorough explanation of the script order.
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
Please refer to "Code_Description.pdf" for explanation and expected output from each script.
#### Filter MINFLUX data
1. **Program Name** :filterMinfluxData.m
(a) **Input file(s)**:Matlab version (.mat) of MINFLUX raw data file for pore scaffold and cargo.
(b) **Output file(s)**:	Track_data_array, Track_ID, Time, Coordinates
(c) **What it does**: Refine MINFLUX data by applying filters for EFO, CFR, DCR, and track length parameters to separate individual localizations or tracks whose localizations meet the average criteria for EFO, CFR, and DCR. Include track ID, timestamp, and XYZ coordinates for valid tracks.
#### Fitting Nuclear Pore localizations
2. **Program Name** :separate_cluster_MINFLUX.m
(a) **Input file(s)**:Scaffold localization.txt.(should contain track ID, timestamp, and XYZ coordinates)
(b) **Output file(s)**:	Invidual cluster with cluster number
(c) **What it does**:Extracts the ID, timestamp, and coordinates of individual cluster into separate text files.

3. **Program Name** :estimate_cylinder_MINFLUX.m
(a) **Input file(s)**:It takes input of clusters information from the output of Program 2
(b) **Output file(s)**:	Coordrinates of centers of the clusters from double circle fit of two rings and diamters and separation distance between tworings.(Ex- 
clusterx_center.txt, clustery_center.txt, clusterz_center.txt, clusterdiameter.txt, clusterheight.txt)
(c) **What it does**:Double circle fitting of  two rings from individual cluster.

4. **Program Name** :select_pores_MINFLUX.m
(a) **Input file(s)**:It takes input from fitting parameters (x, y, z coordrinates,diameter, height)from the output of Program 3
(b) **Output file(s)**:	Selected clusters which qualify as pores. ( 1pore.txt, 2pore.txt....porex_center.txt, porey_center.txt, porez_center.txt, porediameter.txt, poreheight.txt)
(c) **What it does**:Selects those clusters having at least 20 localizations with a fit diameter of 80-135 nm, a height of 40-65 nm, and z-center of 0±200 nm.

5. **Program Name** :circlefit_bisquare_MINFLUX.m
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
(c) **What it does**:Determines the angle of rotation for the cluster by fitting the angle distribution histogram to a sinusoidal function with a period of 45° and a variable phase.

10. **Program Name** :centering_pore_MINFLUX _step5.m
(a) **Input file(s)**:porex_center.txt, porey_center.txt, porez_center.txt ,1porebisquare.txt, 2porebisquare.txt etc, outputs from Program 4
(b) **Output file(s)**:1pore_centered.txt, 2pore_centered.txt, etc.
(c) **What it does**:Translates the center of all clusters to (x, y, z) = (0, 0, 0)

11. **Program Name** :pore_rotation_MINFLUX _step6.m
(a) **Input file(s)**:rot_angle.txt, 1pore_centered.txt, 2pore_centered.txt, etc. outputs from Program 10
(b) **Output file(s)**:1pore_centered.txt, 2pore_centered.txt, etc.
(c) **What it does**:Rotates every point in a cluster by its phase angle.

#### Reconstruction of Pore localizations.
12. **Program Name** :merge_after_rotation_MINFLUX _step7.m
(a) **Input file(s)**:1pore_centered.txt, 2pore_centered.txt, etc. outputs from Program 11.
(b) **Output file(s)**:pore_merged_rotated.txt
(c) **What it does**:Merges all the localizations from all clusters.

13. **Program Name** :pore_rotate_back_MINFLUX_step8.m
(a) **Input file(s)**:pore_merged_rotated.txt, output from Program 12.
(b) **Output file(s)**:pore_merged_rotated back.txt
(c) **What it does**:There is always a 8.4 degree inherent rotation of pore. This step compensates for that inherent rotation of pore.


## Demo
Sample data has been uploaded on Github. Please refer to "Model NPC Scaffold Data.txt" and "Model Track Data.txt". Detailed explanation on output files has been described in "Code_Description.pdf".  



# MINFLUX_NPC_Tracking
The codes are specifically designed for analyzing two-color data obtained through 3D-MINFLUX. The 'Red' color corresponds to the nuclear pore complex (NPC), while the 'Green/Yellow' color represents the 3D second color used for tracking cargo moving through the NPC.

A model dataset named "Nuclear Pore Model Data.mat" contains the raw data exported from the MINFLUX microscope. Users can filter and isolate the tracks based on EFO, CFR, and track length parameters using the "filterMinfluxData.m" script. The extracted data can then be used for further analysis.

Additionally, four other model datasets are provided for running the two-color colocalization scripts:

"Nuclear Pore Model Data.txt" contains filtered 3D MINFLUX localizations from permeabilized functional NPCs.
"Tracks Model Data.txt" contains track data with five columns: 'Track Id', 'Time stamp (second)', x (meter), y (meter), and z (meter).
Typically, MINFLUX data output is in seconds and meters. The following scripts will convert these to milliseconds and nanometers. Data for bead localization in two channels is also attached (Bead loc_Red.txt and Bead loc_Yellow.txt) as model data, which will help generate an alignment matrix to correct the optical aberration between the two colors.

The pore data must be analyzed first to obtain the pore centers and other relevant information. Second, the alignment matrix is required to align the second color. The track data must then be analyzed to yield individual tracks with respect to the corresponding pore. Detailed explanations are provided at the top of each script and in the respective README sections.

Note: 20 scripts are attached, requiring specific input files:

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
1. **Program Name** : filterMinfluxData.m



-  
note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/filterMInfluxData.png" width="400" height=auto>
    </p>
 <br />

 
**What it does**: Refine MINFLUX data by applying filters for EFO, CFR, DCR, and track length parameters to separate individual localizations or tracks whose localizations meet the average criteria for EFO, CFR, and DCR. Include track ID, timestamp, and XYZ coordinates for valid tracks. The following window will pop up, allowing the user to select their filtering criteria.

 **Input file(s)**: Matlab version (.mat) of MINFLUX raw data file for pore scaffold and cargo. As model data "Nuclear Pore Model Data.mat".
 
 **Output file(s)**:	Track_data_array, Track_ID, Time, Coordinates

Note: Place the following command in the command box after running this script to obtain the track ID, timestamp, and XYZ coordinates of the filtered tracks as output in "track_data_array".
length = cellfun(@(x) size(x, 1), ans.tracks);
track_data_array = double (repelem(ans.track_ID, length));
track_data_array(:, 2:5) = vertcat(ans.tracks{:});

Create a text file of pore/track localizations containing 5 columns: track ID, timestamp, and XYZ coordinates. For a trial, use the model data "Nuclear Pore Model Data.txt" for pores and "Tracks Model Data.txt" for tracks. Use these text files as input for Script 2 (separate_cluster_MINFLUX.m) for pores or Script 15 (green_localization_in_red_channel_MINFLUX.m) for tracks.

#### Fitting Nuclear Pore localizations
2. **Program Name** : separate_cluster_MINFLUX.m
   
**What it does**: Extracts the ID, timestamp, and coordinates of individual cluster into separate text files.
The cluster should be manually selected. Upon running the program, a window with scatter plots will open. User will need to draw a rectangular selection box around each cluster.  Once selected, double-clicking the rectangle will save the cluster. Repeat this process until all pore clusters are selected.  Once complete, save clusters and the figure can be closed. An error message will appear at the end, but it can be ignored. An image for cluster selection for the "Nuclear Pore Model Data" is attached.

    <p align="left">
    <img src="/img/doubleRingFitting.png" width="400" height=auto>
    </p>
**Input file(s)**: Scaffold localization.txt.(should contain track ID, timestamp, and XYZ coordinates)

**Output file(s)**:	Invidual cluster with cluster number


3.  **Program Name** : estimate_cylinder_MINFLUX.m
   
**What it does**: Double circle fitting of  two rings from individual cluster. Image attached.

<a href="https://ibb.co/T4wDBpY"><img src="https://i.ibb.co/qNDLMX7/Double-circle-Fitting-of-cluster.png" alt="Double-circle-Fitting-of-cluster" border="0"></a>

**Input file(s)**: It takes input of clusters information from the output of Program 2

**Output file(s)**:	Coordrinates of centers of the clusters from double circle fit of two rings and diamters and separation distance between two rings.
(Ex:clusterx_center.txt, clustery_center.txt, clusterz_center.txt, clusterdiameter.txt, clusterheight.txt)


4. **Program Name** : select_pores_MINFLUX.m
   
**What it does**: Selects those clusters having at least 20 localizations with a fit diameter. For example of diameter: 70-150 nm, height: 25-100 nm, and z-center: 0±200 nm. User can change these parameters as per their interest.
 

**Input file(s)**: It takes input from fitting parameters (x, y, z coordrinates,diameter, height)from the output of Program 3 

**Output file(s)**:	Selected clusters which qualify as pores. ( 1pore.txt, 2pore.txt....porex_center.txt, porey_center.txt, porez_center.txt, porediameter.txt, poreheight.txt)


5. **Program Name** : circlefit_bisquare_MINFLUX.m
   
**What it does**: Fits pore localizations to a circle projected into the xy-plane and eliminates localizations whose residual was more than two standard deviations away from the circle.

**Input file(s)**: x, y, z coordrinates from pores, the output of Program 4

**Output file(s)**:	1porebisquare.txt, 2porebisquare.txt...

#### Rotation of NPC Scaffold Localization

6. **Program Name** : pore_rotation_MINFLUX_step1.m
   
**What it does**: Finds the angle (0-90º) of each localization in a cluster relative to the centroid.

**Input file(s)**: porebisquare.txt porex_center.txt porey_center.txt, outputs of Program 5

**Output file(s)**:	1pore_ninety_normalized.txt 2pore_ninety_normalized.txt etc.


7. **Program Name** : pore_rotation_MINFLUX _step2.m
   
**What it does**: Finds the angle (0-45º) of each point in a pore in a cluster relative to the centroid.

**Input file(s)**: 1pore_ninety_normalized.txt 2pore_ninety_normalized.txt..,outputs of Program 6

**Output file(s)**:	1pore_fortyfive.txt, 2pore_fortyfive.txt etc.

8. **Program Name** : pore_rotation_MINFLUX _step3.m
   
**What it does**: Determines the angle distribution histogram (0-45º) of the localizations in each cluster with a bin of 5º

**Input file(s)**: 1pore_fortyfive.txt, 2pore_fortyfive.txt etc.,outputs of Program 7

**Output file(s)**: 1phase_norm.txt, 2phase_norm.txt, etc.


9. **Program Name** : pore_rotation_MINFLUX_step4_fitting.m
    
**What it does**: Determines the angle of rotation for the cluster by fitting the angle distribution histogram to a sinusoidal function with a period of 45° and a variable phase. Image attached.

<a href="https://ibb.co/7bXV0Rj"><img src="https://i.ibb.co/Ws6FRPG/Angle-fit.png" alt="Angle-fit" border="0"></a>

**Input file(s)**: 1phase_norm.txt, 2phase_norm.txt etc.,outputs of Program 8

**Output file(s)**: rot_angle.txt


10. **Program Name** :centering_pore_MINFLUX _step5.m
    
 **What it does**: Translates the center of all clusters to (x, y, z) = (0, 0, 0)

 **Input file(s)**: porex_center.txt, porey_center.txt, porez_center.txt ,1porebisquare.txt, 2porebisquare.txt etc, outputs from Program 4
 
 **Output file(s)**: 1pore_centered.txt, 2pore_centered.txt, etc.

11. **Program Name** : pore_rotation_MINFLUX _step6.m
    
**What it does**: Rotates every point in a cluster by its phase angle.

**Input file(s)**: rot_angle.txt, 1pore_centered.txt, 2pore_centered.txt, etc. outputs from Program 10

**Output file(s)**: 1pore_centered.txt, 2pore_centered.txt, etc.


#### Merging Pore localizations after rotation.
12. **Program Name** : merge_after_rotation_MINFLUX _step7.m
    
**What it does**: Merges all the localizations from all clusters.

**Input file(s)**: 1pore_centered.txt, 2pore_centered.txt, etc. outputs from Program 11.

**Output file(s)**: pore_merged_rotated.txt


13. **Program Name** : pore_rotate_back_MINFLUX_step8.m
    
**What it does**: There is always a 8.4 degree inherent rotation of pore. This step compensates for that inherent rotation of pore.

**Input file(s)**: pore_merged_rotated.txt, output from Program 12.

**Output file(s)**: pore_merged_rotated back.txt


#### Creating alignment Matrix for two colors.
14. **Program Name** : green2red_transfer_matrix_MINFLUX.

**What it does**: Calculates the image alignment matrix to transform green channel coordinates into the red channel coordinate system. Image attached.

<a href="https://ibb.co/bHn1mcz"><img src="https://i.ibb.co/KNH6hTF/Alignment-Matrix.png" alt="Alignment-Matrix" border="0"></a>


**Input file(s)**: Separate text files for gold/ fluorescent beads localized in two colors containing  three columns for x, y,z obtained from beads localization.( use model input , Bead loc_Red.txt" and "Bead loc_Yellow.txt)

**Output file(s)**: g2r_transfer_matrix.txt


#### Alignment of track localization relative to the NPC scaffold.
15. **Program Name** : green_localization_in_red_channel_MINFLUX.m
    
**What it does**: Transforms the green/yellow channel coordinates of tracks into the red channel coordinate system to correct for chromatic aberration between the two colors.    

**Input file(s)**: The text file from track localization includes track ID, timestamp, and x, y, z coordinates in the second color obtained from cargo tracking (use model data 'Tracks Model Data.txt') , as well as the 'g2r_transfer_matrix.txt' file, which contains the alignment matrix for the two colors.

**Output file(s)**: Optical abberation corrected track localizations.(file_name 'Tracks Model Data_calib.txt')


16. **Program Name** : track_localize_whole_roi_MINFLUX.m
    
**What it does**: Identifies track localizations within a 200 nm cube centered on an NPC centroid.

**Input file(s)**: Track localizations in red color which is used for NPC scaffold localizations (Tracks Model Data_calib.txt'). 

**Output file(s)**: Tracks associated to each pore.(track to whole1.txt, track to whole2.txt etc.)


17. **Program Name** : centering_tracks_wrt_whole_MINFLUX.m

**What it does**: Translates cargo complex localizations to the averaged NPC scaffold.

**Input file(s)**: porex_center.txt; porey_center.txt; porez_center.txt; track to whole1.txt; track to whole2.txt etc. 

**Output file(s)**: track_cen_wrt_whole1.txt; track_cen_wrt_whole2.txt; etc. 


18. **Program Name** : track_rotation_in_whole_MINFLUX.m
    
**What it does**: Rotates track localizations according to the phase angle of their associated pore cluster.

**Input file(s)**: rot_angle.txt; track_cen_wrt_whole1.txt; track_cen_wrt_whole2.txt etc.

**Output file(s)**: track to whole rotated1.txt; track to whole rotated2.txt etc. 

19. **Program Name** : merge_after_rotation_whole_MINFLUX.m
    
**What it does**: Merge MINFLUX tracks after rotation.

**Input file(s)**: track to whole rotated1.txt; track to whole rotated2.txt etc.

**Output file(s)**: track_merged_rotated_whole.txt


20. **Program Name** : Track_rotate_back_MINFLUX_step8.m
    
 **What it does**: There is always a 8.4 degree inherent rotation of pore. This script rotate MINFLUX tracks to compensates for that inherent rotation of pore.
 
 **Input file(s)**: track_merged_rotated_whole.txt
 
**Output file(s)**: track_merged_rotated_back.txt

**Note**: The text file "track_merged_rotated_back.txt" contains the track ID, timestamp, and x, y, and z coordinates of tracks that pass or touch the nuclear pore. To isolate individual tracks, it is recommended to place this text file into any plotting software or Excel. It is recommended that the second column of the worksheet be formatted to accommodate up to 9 significant digits after the decimal point, as the timestamps are large. Additionally, it is important to arrange the timestamp column in ascending order to isolate individual tracks with their track IDs.

## Demo
Sample data has been uploaded on Github. 
1. "Nuclear Pore Model Data.mat"
2. "Nuclear Pore Model Data.txt"
3. "Bead loc_Red.txt" and "Bead loc_Yellow.txt"
4. "Tracks Model Data.txt"  


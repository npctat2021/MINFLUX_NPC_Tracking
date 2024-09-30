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

note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/doubleRingFitting.png" width="400" height=auto>
    </p>
 <br />

 
**Input file(s)**: Scaffold localization.txt.(should contain track ID, timestamp, and XYZ coordinates)

**Output file(s)**:	Invidual cluster with cluster number


3.  **Program Name** : estimate_cylinder_MINFLUX.m
   
**What it does**: Double circle fitting of  two rings from individual cluster. Image attached.


note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/lsqCircleFitting.png" width="400" height=auto>
    </p>
 <br />

**Input file(s)**: It takes input of clusters information from the output of Program 2

**Output file(s)**:	Coordrinates of centers of the clusters from double circle fit of two rings and diamters and separation distance between two rings.
(Ex:clusterx_center.txt, clustery_center.txt, clusterz_center.txt, clusterdiameter.txt, clusterheight.txt)


4. **Program Name** : select_pores_MINFLUX.m
   
**What it does**: Selects those clusters having at least 20 localizations with a fit diameter. For example of diameter: 70-150 nm, height: 25-100 nm, and z-center: 0±200 nm. User can change these parameters as per their interest.


 note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/sinusoidalFit.png" width="600" height=auto>
    </p>
 <br />



 5. **Program Name** : select_pores_MINFLUX.m
   
**What it does**: Selects those clusters having at least 20 localizations with a fit diameter. For example of diameter: 70-150 nm, height: 25-100 nm, and z-center: 0±200 nm. User can change these parameters as per their interest.


 note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/mergedClusterScatterPlott.png" width="600" height=auto>
    </p>
 <br />


6. **Program Name** : select_pores_MINFLUX.m
   
**What it does**: Selects those clusters having at least 20 localizations with a fit diameter. For example of diameter: 70-150 nm, height: 25-100 nm, and z-center: 0±200 nm. User can change these parameters as per their interest.


 note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/beads_alignment.png" width="800" height=auto>
    </p>
 <br />

7. **Program Name** : select_pores_MINFLUX.m
   
**What it does**: Selects those clusters having at least 20 localizations with a fit diameter. For example of diameter: 70-150 nm, height: 25-100 nm, and z-center: 0±200 nm. User can change these parameters as per their interest.


 note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/visualizationUI.png" width="800" height=auto>
    </p>
 <br />




## Demo
Sample data has been uploaded on Github. 
1. "Nuclear Pore Model Data.mat"
2. "Nuclear Pore Model Data.txt"
3. "Bead loc_Red.txt" and "Bead loc_Yellow.txt"
4. "Tracks Model Data.txt"  


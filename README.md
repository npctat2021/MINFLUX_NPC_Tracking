# MINFLUX_NPC_Tracking
Study of nuclear transport with two-color MINFLUX

This workflow reconstruct nuclear pore complex (NPC) and associated cargo transport trajectories from two-color MINFLUX data. 

An example dataset can be found inside the data folder, and can be used for demo purposes. it consist of the following files:
 - Nuclear Pore Model Data.mat : MINFLUX raw data of NPC in MATLAB data format;
 - Nuclear Pore Model Data.txt : filtered and converted NPC data with 5 columns: trace-ID, time stamp, x, y, and z coordinates;
 - Tracks Model Data.txt : coverted MINFLUX data of cargo trajectories;
 - Bead NPC.txt : beads coordinates from the NPC dataset, each row is a different bead, and columns are x, y, and z coordinates (in nm);
 - Bead Cargo.txt : beads coordinates from the Cargo dataset, each row is the same bead as corresponding row in the bead NPC.txt file;

(note: The time stamp is values with unit second, and localizations are values with unit meter. This is how MINFLUX raw data is being recorded, and kept the same in this workflow if not specified otherwise)

The pore data must be analyzed first to obtain the pore centers and other relevant information. Second, the alignment transformation is calculated from the beads datasets and used to align the track data to the NPC data. The track data must then be analyzed to yield individual tracks with respect to the corresponding pore. Detailed explanations are provided in the respective README sections and in the comments of the code.


## System Requirements
MATLAB 2021b and newer. with toolboxes:
- Statistics and Machine Learning
- Signal Processing
- Optimization
- Image processing
- Curve fitting

This workflow doesn't have high computation requirement nor special hardwares. it should work just fine on a laptop PC with nowadays regular CPU and RAM. It developed with Win 10, but should work also on other OS with MATLAB and toolboxes installed. 

This workflow was developed with Windows 10 Pro 22H2 Version and tested on Windows 11 Home version 10.0.22631.

## Instructions for use
Detailed explanations are provided at the top of each script and in the following README sections.
#### Filter MINFLUX data
1. **Program Name** : load_minflux_raw_data.m

**What it does**: Load MINFLUX MATLAB format raw data, and applying filters on EFO, CFR, DCR, and track length parameters to separate individual localizations or tracks whose localizations meet the filtering criteria for EFO, CFR, and DCR. Prepare data as tab-separated values with 5 columns: track ID, timestamp, X, Y, and Z coordinates. The following window will pop up, allowing the user to select their filtering criteria.
    <p align="left">
    <img src="/img/filterMInfluxData.png" width="400" height=auto>
    </p>
 <br />
 
 **Input file(s)**: MATLAB format (.mat) of MINFLUX raw data file for pore scaffold and cargo. e.g.: model data "Nuclear Pore Model Data.mat".
 
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
    <img src="/img/doubleRingFitting.png" width="600" height=auto>
    </p>
 <br />

 
**Input file(s)**: Scaffold localization.txt.(should contain track ID, timestamp, and XYZ coordinates)

**Output file(s)**:	Invidual cluster with cluster number


3.  **Program Name** : estimate_cylinder_MINFLUX.m
   
**What it does**: Double circle fitting of  two rings from individual cluster. Image attached.


note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/lsqCircleFitting.png" width="600" height=auto>
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
    <img src="/img/beads_alignment.png" width="600" height=auto>
    </p>
 <br />

7. **Program Name** : select_pores_MINFLUX.m
   
**What it does**: Selects those clusters having at least 20 localizations with a fit diameter. For example of diameter: 70-150 nm, height: 25-100 nm, and z-center: 0±200 nm. User can change these parameters as per their interest.


 note: this preview image was coverted to PNG format to be visible on Webpage. To run the script, both TIFF and PNG format works but we always use TIFF format as our input.  
    <p align="left">
    <img src="/img/visualizationUI.png" width="600" height=auto>
    </p>
 <br />




## Demo
Sample data has been uploaded on Github. 
1. "Nuclear Pore Model Data.mat"
2. "Nuclear Pore Model Data.txt"
3. "Bead loc_Red.txt" and "Bead loc_Yellow.txt"
4. "Tracks Model Data.txt"  

Note: The "Nuclear Pore Model Data.txt/.mat" represents experimental measurements of Anti-GFP Nanobody HMSiR from a permeabilized cell. In contrast, "Tracks Model Data.txt" consists of example tracks derived from multiple experimental datasets, artificially aligned to the nuclear pore model for illustrative purposes, demonstrating the functionality of the fitting and alignment routine. "Bead loc_Red/NPC" provides synthetic coordinates from two channels, based on the average positional differences obtained in bead measurements. While efforts were made to preserve experimental resemblance during artificial alignment, these model tracks should not be used for drawing biological conclusions.

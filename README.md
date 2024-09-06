# MINFLUX NPC Trafficking data processing and visualization
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
All MATLAB functions and scripts are commented and explained.
For a quick demo of the workflow, run the demo.m script and follow the instruction below:

The script will ask to load the sample NPC scaffold data. The data can be either the .mat format which can be the MINFLUX exported raw data, or alternatively it can be the .txt format data that being pre-processed with filterMinfluxData.m script. The pre-processing can filter the MINFLUX raw data by several attributes, and correct for refractive index mismatch-factor (RIMF).

When the NPC data is successfully loaded. The demo script will perform a semi-automated clustering based on density-based scan. This is implemented via a MATLAB figure. Several buttons are created to facilitate additional functions such as manaul draw cluster that not correctly detected by density-based scan. It is essential to save the clustering result to MATLAB base workspace (by clicking on the "SAVE" button) for further steps.

Then for each cluster, we run a set of the following steps:
 - fit cylinder;
 - fitler cluster;
 - fit circle and remove outlier;
 - analyzing corner angles and rotate clusters to reference axis;
 - merge the clusters together, to create a final NPC template;
A visualization UI is also implemented to faciliate quick inspection on the result and quality check.


## Demo
Sample data has been uploaded on Github. 
1. "Nuclear Pore Model Data.mat"
2. "Nuclear Pore Model Data.txt"
3. "Bead NPC.txt" and "Bead Track.txt"
4. "Tracks Model Data.txt"  


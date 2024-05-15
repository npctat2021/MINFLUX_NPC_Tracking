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
## Filter MINFLUX data
1. **Program Name** :filterMinfluxData.m
(a) **Input file(s)**:Matlab version (.mat) of MINFLUX raw data file for pore scaffold and cargo.
(b) **Output file(s)**:	Track_data_array, Track_ID, Time, Coordinates
(c) **What it does**: Refine MINFLUX data by applying filters for EFO, CFR, DCR, and track length parameters to separate individual localizations or tracks whose localizations meet the average criteria for EFO, CFR, and DCR. Include track ID, timestamp, and XYZ coordinates for valid tracks.

2. **Program Name** :separate_cluster_MINFLUX.m
(a) **Input file(s)**:Scaffold localization.txt.(should contain track ID, timestamp, and XYZ coordinates)
(b) **Output file(s)**:	Invidual cluster with cluster number
(c) **What it does**:Extracts the ID, timestamp, and coordinates of individual cluster into separate text files.

3. **Program Name** :estimate_cylinder_MINFLUX.m
(a) **Input file(s)**:Its take input of clusters information from the output of Program 2
(b) **Output file(s)**:	Coordrinates of centers of the clusters from double circle fit of two rings and diamters and separation distance between tworings.(Ex- 
clusterx_center.txt, clustery_center.txt, clusterz_center.txt, clusterdiameter.txt, clusterheight.txt)
(c) **What it does**:Double circle fitting of  two rings from individual cluster.

   
## Demo
Sample data has been uploaded on Github. Please refer to "Model NPC Scaffold Data.txt" and "Model Track Data.txt". Detailed explanation on output files has been described in "Code_Description.pdf".  



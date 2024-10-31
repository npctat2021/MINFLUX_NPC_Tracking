# MINFLUX_NPC_Tracking
Study of nuclear transport with two-color MINFLUX

This workflow reconstruct nuclear pore complex (NPC) and associated cargo transport trajectories from two-color MINFLUX data. 

An example dataset can be found inside the data folder, and can be used for demo purposes. it consist of the following files:
 - **Nuclear Pore Raw Data.mat** : MINFLUX raw data of NPC in MATLAB data format;
 - **Nuclear Pore Model Data.txt** : filtered and converted NPC data with 5 columns: trace-ID, time stamp, X, Y, and Z coordinates;
 - **Tracks Model Data.txt** : coverted MINFLUX data of cargo trajectories;
 - **Bead NPC.txt** : beads coordinates from the NPC dataset, each row is a different bead, and columns are X, Y, and Z coordinates (in nm);
 - **Bead Cargo.txt** : beads coordinates from the Cargo dataset, each row is the same bead as corresponding row in the bead NPC.txt file;

The time stamp's value is in second (**s**), and localization's value is in meters (**m**). This is how MINFLUX raw data is being recorded. After loading and arragement of the raw data, this workflow will convert the localization data to values in milliseconds (**ms**) and nanometers (**nm**), if not specified otherwise.

The pore data must be analyzed first to obtain the pore centers and other relevant information. Then, the alignment transformation is calculated from the beads datasets and used to align the track data to the NPC data. The track data must then be analyzed to yield individual tracks with respect to the corresponding pore. Detailed explanations are provided in the respective README sections and in the comments of the code.

##### Note: The "Nuclear Pore Model Data.txt/.mat" represents experimental measurements of Anti-GFP Nanobody HMSiR from a permeabilized cell. In contrast, "Tracks Model Data.txt" consists of example tracks derived from multiple experimental datasets, artificially aligned to the nuclear pore model for illustrative purposes, demonstrating the functionality of the fitting and alignment routine. "Bead loc_Red/NPC" provides synthetic coordinates from two channels, based on the average positional differences obtained in bead measurements. While efforts were made to preserve experimental resemblance during artificial alignment, these model tracks should not be used for drawing biological conclusions.

## System Requirements
MATLAB 2021b and newer. with toolboxes:
- Statistics and Machine Learning
- Signal Processing
- Optimization
- Image Processing
- Curve Fitting
- Computer Vision

This workflow doesn't require high computation power or special hardwares. It should work even with a laptop PC with OKish CPU and RAM. It developed with Windows system, but should also work on other OS with MATLAB and toolboxes readily installed. 

The codes was developed with Windows 10 Pro 22H2 Version and tested on Windows 11 Home version 10.0.22631.

## Instructions for use

### Load and Pre-processing of MINFLUX raw data

#### 1. Program: load_minflux_raw_data.m

Load MINFLUX MATLAB (.mat) format raw data. Apply filters on localizations so that noise and low quality data can be removed. It requires the MATLAB format (.mat) of MINFLUX raw data file for pore scaffold or cargo, e.g.: [Nuclear Pore Model Data.mat](/data/Nuclear%20Pore%20Model%20Data.mat). The filtered result will be saved to MATLAB base workspace. And a tab-separated value format result stores trace ID, time stamp, X, Y, and Z coordinate in nm of the filtered data, will be saved to a text file on disk next to the input raw data, e.g.: [Nuclear Pore Model Data.txt](/data/Nuclear%20Pore%20Model%20Data.txt).
    
It requires the filtering criterion on several properties of the data: **cfr, efo, dcr**, trace length, whether to filter with trace-level mean value. For more detailed explanation on these parameters, please refer to the manuscript, or the comment section in the code. If one or more input is not provided as function inputs, a dialog window will pop up, allowing the user to set up the filtering parameters on the run.

<p align="center">
<img src="/img/filterMInfluxData.png" width="500" height=auto>
</p>
    
**Usage:**

    filter_result = load_minflux_raw_data (minfluxRawDataPath, cfr_range, efo_range, dcr_range, length_range, do_trace_mean, save_to_file);

**Input:** 
 - **minfluxRawDataPath** (string) - System path of the MINFLUX (.mat) data file.
 - **cfr_range** (1-by-2 numeric) - the minimum and maximum values of **cfr** attribute that accepted by the filter
 - **efo_range** (1-by-2 numeric) - the minimum and maximum values of **efo** attribute that accepted by the filter
 - **dcr_range** (1-by-2 numeric) - the minimum and maximum values of **dcr** attribute that accepted by the filter
 - **length_range** (1-by-2 numeric) - the minimum and maximum number of localizations in a trace that accepted by the filter 
 - **do_trace_mean** (boolean) - whether to filter with trace-level mean value
 - **save_to_file** (boolean) - whether to save conveted model data, in the data array, to a tab-separated value text file on disk 
     

**Output:**
 - **filter_result** (structure array) – stores attribute(s) values from the filtered data:
    - **trace_ID** (N-by-1 numeric) - array of trace ID (**tid** attribute of the MINFLUX raw data)
    - **tim_ms** (N-by-1 numeric) - array of time stamp, in milliseconds
    - **loc_nm** (N-by-3 numeric) - X, Y, and Z values of the 3D localization coordinates, in nanometer
    - **trace_txyz** (N-by-4 numeric) array of filtered data with 4 columns: time stamp, X, Y, and Z coordinates. The units are the same as raw data, i.e.: seconds and meters. This format can be used in diffusion behavior analysis, e.g.: [msdanalyzer](https://tinevez.github.io/msdanalyzer/)
    - **data_array** (N-by-5 numeric) array of filtered data with 5 columns: trace ID, time stamp, X, Y, and Z coordinates. The units are the same as raw data, i.e.: seconds and meters. This is the same as [Nuclear Pore Model Data.txt](/data/Nuclear%20Pore%20Model%20Data.txt), which is the format of data mainly used in this workflow. For instance: It can be used as input for program 2 [clustering of NPC](#2-program-semi_automated_clusteringm). Or if the input is the cargo tracking data, it can be used in program 8 and 9, [align](#8-program-align_track_to_npcm) and [assign tracks to NPC](#9-program-assign_track_to_clusterm).

<br>

### Selection of Nuclear Pore Localization Data

#### 2. Program: semi_automated_clustering.m

Automated and manual selection of NPCs from localization data. Upon running the program, a 2D scatter plot of the XY view of the localizations will show. An initial spatial clustering will be performed with density-based scan (DBSCAN). The resulted clusters will be show with different colors of the scatter plot, and highlighted with rectangle boxes that surround each cluster. Based on this rough initial clustering, user can modify, add, or remove NPC selections. This is enabled through modify these rectangular selection boxes, or manual drawing of new boxes. Whenever certain progress made, user can click the **Save** button to save the current clustering result to a struct array ***cluster_data*** in the MATLAB base workspace.

<p align="center">
<img src="/img/semiAutomatedClustering.png" width="700" height=auto>
</p>

**Usage:**
    
    semi_automated_clustering(data, RIMF, dbscan_eps, dbscan_minPts);
    
**Input:** 
 - **data** (N-by-5 numeric) - *data_array* as output of [program 1](#1-program-load_minflux_raw_datam)
 - **RIMF** (numeric) - refractive index mismatch factor. A value between 0 and 1, to be applied to the z-axis localization values to correct for refractive mismatch. This value should ideally be measured from the imaging system, and for each experiment. It is typically around 0.66 from our measurments in this project. Here in this program, it will be used to calibrate the cargo data that could be potentially loaded at this stage.
 - **dbscan_eps** (numeric) - neighborhood search radius of density-based scan, use estimated radius of the NPC to start with. 
 - **dbscan_minPts** (numeric) - minimum number of points in cluster, of the density-based scan. 

**Output:**
 - **cluster_data** (struct array) stores data of the resulted NPC clusters, with the following fields:
    - **Rectangle** - 2D rectangle that defines the XY bounds of each cluster 
    - **Cluster_ID** - unique numeric ID of each cluster
    - **loc_nm** (N-by-3 array) - X, Y, and Z coordinates of localizations of each cluster, in nm
    - **tid** - trace ID associated with each localization
    - **tim** - time stamp associated with each localization

<br>

### Fitting Nuclear Pore localizations

#### 3. Program: fit_cylinder_to_cluster.m

Double circle (cylinder) fitting of two rings of NPC onto selected cluster.

<p align="center">
<img src="/img/doubleRingFitting.png" width="600" height=auto>
</p>

**Usage:**

    fit_cylinder_to_cluster (cluster_data, showFitting, save_mode);
    
**Input:** 
 - **cluster_data** (struct array) - output of [NPC selection](#2-program-semi_automated_clusteringm)
 - **showFitting** (boolean) - whether to show the fitting result or not
 - **save_mode** (string):
    - **'overwrite'**: overwrite on base workspace variable ***cluster_data***
    - **'new'**: create new variable ***cluster_data_cylinderFitted***

**Output:**
 - **cluster_data** (or **cluster_data_cylinderFitted**) - append new fields **center**, **diameter**, **height**, **fittingError**
    - **center** - X, Y, Z center of the fitted cylinder
    - **diameter** - diameter of the fitted cylinder
    - **height** - height  of the fitted cylinder
    - **fittingError** - sum of XY and Z fitting error of all localizations in a cluster to the fitted double-ring model


#### 4. Program: filter_NPC_cluster.m

Filter clusters based on the measurement and fitting reuslt so far. For instance, we can select those clusters having at least 20 localizations with a fit diameter. For example of diameter: 70-150 nm, height: 25-100 nm, and z-center: -300-100 nm. Users can change these parameters as per their interest.

**Usage:**

    filter_NPC_cluster (cluster_data, save_mode, Name, Value);
    
**Input:**
 - **cluster_data** (struct array) - output of [double ring fitting](#3-program-fit_cylinder_to_clusterm)
 - **save_mode** (string):
    - **'overwrite'**: overwrite on base workspace variable *cluster_data*
    - **'new'**: create new variable *cluster_data_filtered*
 - **Name-Value Arguments:**
    - 'heightMin', minimum inter-ring height, e.g.: 25
    - 'heightMax', maximum inter-ring height, e.g.: 100
    - 'diameterMin', minimum ring diameter, e.g.: 70
    - 'diameterMax', maximum ring diameter, e.g.: 150
    - 'zCenterMin', lowest z center location, e.g.: -300
    - 'zCenterMax', highest z center location, e.g.: 100
    - 'nLocMin', minimum data point in cluster, e.g.: 20

**Output:**
 - **cluster_data**  (struct array) - filtered


#### 5. Program: fit_circle_to_cluster.m
   
Fits pore localizations to a circle projected into the XY-plane and eliminates localizations whose residual was more than two standard deviations away from the circle.

<p align="left">
<img src="/img/lsqCircleFitting.png" width="600" height=auto>
</p>

**Usage:**

    fit_circle_to_cluster (cluster_data, showFitting, save_mode);

**Input:**
 - **cluster_data** (struct array) - output of [program 3](#3-program-fit_cylinder_to_clusterm) or [4](#4-program-filter_NPC_clusterm)
 - **showFitting** (boolean) - whether to show the fitting result or not
 - **save_mode** (string):
    - **'overwrite'**: overwrite on base workspace variable *cluster_data*
    - **'new'**: create new variable *cluster_data_circleFitted*

**Output:**
 - **cluster_data** - updated fields **loc_nm**, **tid**, **tim**, appended new field **loc_norm**
    - further filter on data, so that localizations located 2 standard deviation away from the fitted circle are removed. loc_nm, tid, and tim are updated accordingly. 
    - **loc_norm** (N-by-3 data array) <br> normalized localizations of each cluster, by translate the center of the fitted circle to coordinate origin.


### Transform and merge clustered data to reconstruct NPC

#### 6. Program: rotate_cluster.m

Compute rotation angle in XY plane in the range between [-180°, 180°] of each localization. Then remaps the angles into range between [0°, 45°], to account for the 8-fold symmetry structure of NPC. It then fit a full cycle of sinusoidal function to the histogram of the remapped polar angles, that from localizations belonging to a cluster. We obtain the phase angle, as the peak position from the fitted sinusoidal function. We then rotates every point in a cluster by the cluster's phase angle, to prepare for align and merge of multiple NPC clusters.

<p align="left">
<img src="/img/sinusoidalFit.png" width="600" height=auto>
</p>


**Usage:**

    rotate_cluster (cluster_data, angel_bin_size, angle_to_base, showFitting, save_mode);
    
**Input:**
 - **cluster_data** (structure array) - output of [least square circle fit](#5-program-fit_circle_to_clusterm)
 - **angel_bin_size** (numeric) - phase angle histogram bin size
 - **angle_to_base** (numeric) - the angle of NPC scaffold to the cartesian axes. 0 means the subunits will lie onto the X and Y axis (and also on the 45 degree lines to account for all 8 subunits). We used 22.5 degree to favor the demo on X-Z view. This parameter won't change the result, as the tracks will be rotated with the same angle as the NPCs.
 - **showFitting** (boolean) - whether to show the fitting result or not
 - **save_mode** (string):
    - **'overwrite'**: overwrite on base workspace variable *cluster_data*
    - **'new'**: create new variable *cluster_data_rotated* 
 

**Output:**
 - **cluster_data** (struct array) - append new field **rotation**
    - **rotation** (numeric value between 0 and 45) <br> the phase angle (in degree) computed from the sinusoidal fit, as the rotation angle of the current cluster to the template.


#### 7. Program: merge_cluster.m
   
Merges all the localizations from all clusters.

<p align="left">
<img src="/img/mergedCluster.png" width="600" height=auto>
</p>

**Usage:**

    merge_cluster (cluster_data, showResult, save_mode);

**Input:**
 - **cluster_data** (structure array) - output of [rotate cluster](#6-program-rotate_clusterm)
 - **showResult** (boolean) - whether to show the XY and XZ view of the merged cluster (as rendered 2D density map), or not
 - **save_mode** (string):
    - **'overwrite'**: overwrite on base workspace variable *cluster_data*
    - **'new'**: create new variable *cluster_data_merged*

**Output:**
 - **cluster_data** (struct array) - field **loc_norm** updated
    - **loc_norm** - the normalized localizations are now rotated by the angle computed from [rotate cluster](#6-program-rotate_clusterm)
 - **merged NPC** (N-by-5 data array) saved as tab-separated values to a text file ***pore_merged.txt*** in the root folder 

### Align and assign cargo data to NPC data

#### 8. Program: align_track_to_NPC.m
   
Calculate transformation from beads localization information, that belongs to NPC and Cargo data respectively. Then use this to transform the localization coordinates of Cargo data, to align to the NPC data.

<p align="left">
<img src="/img/beads_alignment.png" width="600" height=auto>
</p>

**Usage:**

     result = align_track_to_NPC (file_track , beads_track, beads_npc, RIMF);
     
**Input:**
 - **file_track** (string) - System path of the data file that exported from ***data_array*** of the Cargo MINFLUX data. e.g.: [Tracks Model Data.txt](/data/Tracks%20Model%20Data.txt)
 - **beads_track** (string) - System path of the beads coordinates file of the Cargo data. It is also in tab-separated value format, and stores N-by-3 numeric values. The 3 columns are the X, Y, and Z coordinates of bead. And each row is a bead that well located in both NPC and Cargo dataset. e.g.: [Bead Track.txt
](/data/Bead%20Track.txt)
 - **beads_npc** (string) - System path of the beads coordinates file of the NPC data. e.g.: [Bead NPC.txt](/data/Bead%20NPC.txt)
 - **RIMF** (numeric) - refractive index mismatch factor, need to be the save as the paired NPC data to scale correctly the z axis values of the Cargo data.

**Output:**
 - **alignment figure** (figure) - A figure showing the location of the detected beads in both channel, and also the transformed beads location of the Cargo data.
 - **track_data** (struct array) – stores attribute(s) values from the filtered Cargo data. It is formatted the same as **'filter_result'** of the [filtered NPC data](#1-program-load_minflux_raw_datam).

#### 9. Program: assign_track_to_cluster.m

Locate the NPC that associated with the Cargo (track) data, and apply the NPC specified rotation transformation to its associated Cargo (track) data coordinates.

**Usage:**

    result = assign_track_to_cluster (track_data, npc_cluster_data);
    
**Input:**
 - **track_data** - output of [aligned track result](#8-program-align_track_to_NPCm)
 - **npc_cluster_data** - output of [merged NPC cluster result](#7-program-merge_clusterm)

**Output:**
 - **track_data** (struct array) – same as [program 8](#8-program-align_track_to_NPCm), removed data that not associated with any NPC cluster, and appended new field **cluster_ID**
    - **cluster_ID** - the numeric ID of the associated NPC cluster, from the [NPC data clustering result](#2-program-semi_automated_clusteringm).

### Visualize Reconstructed NPC and Cargo data

#### 10. Program: NPC_trafficking_visualizationUI.m
   
Display an interactive visualziation UI that shows the recontructed and merged NPC cluster, and overlay the associated Cargo data onto it. The merged NPC raw data are plotted as 3D scatter points, but colored by the local density, to give similar look to the 2D histogram rendering. With the fitted NPC parameter, the ring diameter, inter-ring distance and so on, the NPC can be also displayed as geometry model: either as point cloud, or as sphere surfaces. The point cloud will be colored the same way as the raw data, and the surface will be simply displayed as light pink color. The Cargo data will be plotted as connected line, and the movement can be shown by a playable star head in magenta color, that mimic the displacement of the Cargo (track) over time. Different tracks are selectable with a menu entry, that denote by the Cargo data's trace ID.

<p align="left">
<img src="/img/visualizationUI.png" width="800" height=auto>
</p>

**Usage:**

    NPC_trafficking_visualizationUI(npc_cluster_data_merged, track_data_aligned);
    
**Input:**
 - **npc_cluster_data_merged** - output of [program 7](#7-program-merge_clusterm)
 - **track_data_aligned** - output of [program 9](#9-program-assign_track_to_clusterm)



## Demo
We made a script that demo the whole workflow on the sample dataset (in the data folder) and with default parameters.

**Usage:** In MATLAB, change the working directory to root directory of this repository, and run the demo.m script, or alternatively type 'demo.m' and enter to run the demo script.

**Description:**
    
The demo will first ask user for the input NPC model data file, or the NPC MINFLUX raw data file. In case the user provided the MATLAB (.mat) format raw data type, the demo will call [the load function](#1-program-load_minflux_raw_datam) to load and pre-process the data. This load and filtering will run silently and use the following criterions: cfr_range [0, 0.8], efo_range [1e4, 1e7], dcr_range [0, 1], trace length range [1, 350], and filter with trace-wise mean value.

The demo will then call up the [clustering program](#2-program-semi_automated_clusteringm) and display the interactive clustering figure, for user to verify and modify the NPC clusters. Some message will prompt up in MATLAB console winodw to facilitate the user. Upon an acceptable cluster selections in the figure, the user is expected to click on the '**Save**' button. and hit **Enter** in the console window to continue the demo workflow. As also supported by the clustering program, the user can load, align and assign the Cargo data at this stage, by clicking onto the '**Load track data**' button. A multiple file selection window will prompt up, and the user are expected to multi-select (by holding down the **SHIFT** key while clicking onto the files) 3 files: as the 3 inputs of [program 8](#8-program-align_track_to_NPCm): [Tracks Model Data.txt](/data/Tracks%20Model%20Data.txt), [Bead Track.txt
](/data/Bead%20Track.txt), and [Bead NPC.txt](/data/Bead%20NPC.txt).

The demo will by default save and display all the intermediate step and results. And also reporting the status and progress to MATLAB consoles. More information of the default parameters taken for each program can be found in the comment section in the demo script. Upon completion, the demo will display the final reconstructed NPC and recognized Cargo tracks with the [visualization UI](#10-program-NPC_trafficking_visualizationUIm). If the Cargo (track) data is not loaded or not available, the UI will still display the reconstructed NPC, but showing an empty Track selection menu. If a certain track is loaded but no NPC cluster can be assigned to it, it will still appear in the menu. But there will be no Cargo plot when selecting it, and a error message will report to MATLAB console.








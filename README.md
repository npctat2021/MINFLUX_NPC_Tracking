# MINFLUX_NPC_Tracking
Study of nuclear transport with two-color MINFLUX

This workflow reconstruct nuclear pore complex (NPC) and associated cargo transport trajectories from two-color MINFLUX data. 

An example dataset can be found inside the data folder, and can be used for demo purposes. it consist of the following files:
 - Nuclear Pore Model Data.mat : MINFLUX raw data of NPC in MATLAB data format;
 - Nuclear Pore Model Data.txt : filtered and converted NPC data with 5 columns: trace-ID, time stamp, x, y, and z coordinates;
 - Tracks Model Data.txt : coverted MINFLUX data of cargo trajectories;
 - Bead NPC.txt : beads coordinates from the NPC dataset, each row is a different bead, and columns are x, y, and z coordinates (in nm);
 - Bead Cargo.txt : beads coordinates from the Cargo dataset, each row is the same bead as corresponding row in the bead NPC.txt file;

The time stamp is in the unit of second, and localizations are in the unit meter. This is how MINFLUX raw data is being recorded. After loading and arragement of data, this workflow will convert the localization data in the unit of nanometers, if not specified otherwise.

The pore data must be analyzed first to obtain the pore centers and other relevant information. Second, the alignment transformation is calculated from the beads datasets and used to align the track data to the NPC data. The track data must then be analyzed to yield individual tracks with respect to the corresponding pore. Detailed explanations are provided in the respective README sections and in the comments of the code.

##### Note: The "Nuclear Pore Model Data.txt/.mat" represents experimental measurements of Anti-GFP Nanobody HMSiR from a permeabilized cell. In contrast, "Tracks Model Data.txt" consists of example tracks derived from multiple experimental datasets, artificially aligned to the nuclear pore model for illustrative purposes, demonstrating the functionality of the fitting and alignment routine. "Bead loc_Red/NPC" provides synthetic coordinates from two channels, based on the average positional differences obtained in bead measurements. While efforts were made to preserve experimental resemblance during artificial alignment, these model tracks should not be used for drawing biological conclusions.

## System Requirements
MATLAB 2021b and newer. with toolboxes:
- Statistics and Machine Learning
- Signal Processing
- Optimization
- Image processing
- Curve fitting

This workflow doesn't require high computation power or special hardwares. It should work even with a laptop PC with OKish CPU and RAM. It developed with Windows system, but should also work on other OS with MATLAB and toolboxes readily installed. 

The codes was developed with Windows 10 Pro 22H2 Version and tested on Windows 11 Home version 10.0.22631.

## Instructions for use
Detailed explanations are provided at the top of each script and in the following README sections.

### Load and Pre-processing of MINFLUX data

#### 1. Program: load_minflux_raw_data.m

Load MINFLUX MATLAB (.mat) format raw data. Apply filters on localizations so that noise and low quality data can be removed. It requires the MATLAB format (.mat) of MINFLUX raw data file for pore scaffold or cargo, e.g.: [Nuclear Pore Model Data.mat](/data/Nuclear%20Pore%20Model%20Data.mat). The filtered result will be saved to MATLAB base workspace. And a tab-separated value format result stores trace ID, time stamp, x, y, and z coordinate in nanometer of the filtered data, will be saved to a text file on disk next to the input raw data, e.g.: [Nuclear Pore Model Data.txt](/data/Nuclear%20Pore%20Model%20Data.txt).
    
It requires the filtering criterion on several properties of the data: cfr, efo, dcr, trace length and whether to filter with trace-level mean value, and refractive index mismatch factor (RIMF). For more detailed explanation on these parameters, please refer to the manuscript, or the comment section in the script. If one or more input is not provided as function inputs, a dialog window will pop up, allowing the user to set up the filtering parameters on the run.

<p align="center">
<img src="/img/filterMInfluxData.png" width="300" height=auto>
</p>
    
**Usage:**

    filter_result = load_minflux_raw_data (minfluxRawDataPath, cfr_range, efo_range, dcr_range, length_range, do_trace_mean, RIMF);

**Input:** 
 - **minfluxRawDataPath** - System path of the MINFLUX .mat format raw data.
 - **cfr_range** - the minimum and maximum values of **cfr** attribute that accepted by the filter
 - **efo_range** - the minimum and maximum values of **efo** attribute that accepted by the filter
 - **dcr_range** - the minimum and maximum values of **dcr** attribute that accepted by the filter
 - **length_range** - the minimum and maximum number of localizations in a trace that accepted by the filter 
 - **do_trace_mean** - boolean. whether to filter with trace-level mean value
 - **RIMF** - refractive index mismatch factor. A value between 0 and 1, which should be measured experimentally for each dataset, and applied to the z-axis localization values before quantitative analysis.
     

**Output:**
 - **filter_result** (structure array) – stores attribute(s) values from the filtered MINFLUX data:
    - **trace_ID** : array of trace ID (**tid** attribute of the MINFLUX raw data)
    - **time_stamp** : array of time stamp, in seconds
    - **loc_nm** : array of the 3D localization coordinates, in nanometer
    - **trace_txyz** : N by 4 array of filtered localization data with 4 columns: time stamp, x, y, and z coordinates. This format can be used in diffusion behavior analysis, e.g.: [msdanalyzer](https://tinevez.github.io/msdanalyzer/)
    - **data_array** : N-by-5 array of filtered data with 5 columns: trace ID, time stamp, x, y, and z coordinates. This is the same as [Nuclear Pore Model Data.txt](/data/Nuclear%20Pore%20Model%20Data.txt), which is the type of data mainly used in this workflow. For instance: It can be used as input for program 2 [semi_automated_clustering.m](#2-program-semi_automated_clusteringm). Or if the input is the cargo tracking data, it can be used in program 8 and 9, [align](#8-program-align_track_to_npcm) and [assign tracks to NPC](#9-program-assign_track_to_clusterm).
<br>
<br>

### Reconstruction of Nuclear Pore Localization Data

#### 2. Program: semi_automated_clustering.m

Spatial clustering of localization data. Upon running the program, a figure window with 2D scatter plot of the localizations will show. A initial User will need to draw a rectangular selection box around each cluster.  Once selected, double-clicking the rectangle will save the cluster. Repeat this process until all pore clusters are selected.  Once complete, save clusters and the figure can be closed. An error message will appear at the end, but it can be ignored. An image for cluster selection for the "Nuclear Pore Model Data" is attached.

<p align="center">
<img src="/img/semiAutomatedClustering.png" width="700" height=auto>
</p>

**Usage:**
    
    semi_automated_clustering(data, RIMF, dbscan_eps, dbscan_minPts);
    
**Input:** 
 - **data** (N-by-5 data array) - *data_array* as output of [program 1](#1-program-load_minflux_raw_datam)
 - **RIMF** (numeric) - refractive index mismatch factor
 - **dbscan_eps** (numeric) - neighborhood search radius  
 - **dbscan_minPts** (numeric) - minimum number of points in cluster 

**Output:**
 - **cluster_data** (struct array) stores data of the resulted NPC clusters:
    - **Rectangle** - 2D rectangle that defines the X-Y bounds of each cluster 
    - **Cluster_ID** - unique numeric ID of each cluster
    - **loc_nm** (N-by-3 array) - x, y, and z coordinates of localizations, in nanometer, of each cluster
    - **tid** - trace ID associated with each localization
    - **tim** - time stamp associated with each localization, in  second.

### Fitting Nuclear Pore localizations

#### 3. Program: fit_cylinder_to_cluster.m

Double circle fitting of  two rings from individual cluster.

<p align="center">
<img src="/img/doubleRingFitting.png" width="600" height=auto>
</p>

**Usage:**

    fit_cylinder_to_cluster (cluster_data, showFitting, save_mode);
    
**Input:** 
 - **cluster_data** - 
 - **showFitting** (boolean) - whether to show the fitting result or not
 - **save_mode** (string):
    - **overwrite:** overwrite on base workspace variable *cluster_data*
    - **new:** create new variable *cluster_data_cylinderFitted*

**Output:**
 - **cluster_data** appended field **center**, **diameter**, **height**, **fittingError**
    - **center** - x,y,z center of the fitted cylinder
    - **diameter** - diameter of the fitted cylinder
    - **height** - height  of the fitted cylinder
    - **fittingError** - sum of XY and Z fitting error of all localizations in a cluster to the fitted double-ring model

### Fitting Nuclear Pore localizations

#### 4. Program: filter_NPC_cluster.m
   
Selects those clusters having at least 20 localizations with a fit diameter. For example of diameter: 70-150 nm, height: 25-100 nm, and z-center: 0±200 nm. User can change these parameters as per their interest.

**Usage:**

    filter_NPC_cluster (cluster_data, save_mode, Name, Value);
    
**Input:**
 - **cluster_data**
 - **save_mode** (string):
    - **overwrite:** overwrite on base workspace variable *cluster_data*
    - **new:** create new variable *cluster_data_filtered*
 - **Name-Value Arguments:**
    - 'heightMin', minimum inter-ring height, e.g.: 25
    - 'heightMax', maximum inter-ring height, e.g.: 100
    - 'diameterMin', minimum ring diameter, e.g.: 70
    - 'diameterMax', maximum ring diameter, e.g.: 150
    - 'zCenterMin', lowest z center location, e.g.: -300
    - 'zCenterMax', highest z center location, e.g.: 100
    - 'nLocMin', minimum data point in cluster, e.g.: 20

**Output:**
 - **cluster_data** - filtered

### Fitting Nuclear Pore localizations

#### 5. Program: fit_circle_to_cluster.m
   
Fits pore localizations to a circle projected into the xy-plane and eliminates localizations whose residual was more than two standard deviations away from the circle.

<p align="left">
<img src="/img/lsqCircleFitting.png" width="600" height=auto>
</p>

**Usage:**

    fit_circle_to_cluster (cluster_data, showFitting, save_mode);

**Input:**
 - **cluster_data**
 - **showFitting** (boolean) - whether to show the fitting result or not
 - **save_mode** (string):
    - **overwrite:** overwrite on base workspace variable *cluster_data*
    - **new:** create new variable *cluster_data_circleFitted* 

**Output:**
 - **cluster_data** - updated fields **loc_nm**, **tid**, **tim**, appended field **loc_norm**
    - further filter on data, so that localizations located 2 standard deviation away from the fitted circle are removed. loc_nm, tid, and tim are updated accordingly. 
    - **loc_norm** (N-by-3 data array) <br> normalized localizations of each cluster, by translate the center of the fitted circle to coordinate origin.


### Fitting Nuclear Pore localizations

#### 6. Program: rotate_cluster.m
   
Rotates every point in a cluster by its phase angle.

<p align="left">
<img src="/img/sinusoidalFit.png" width="600" height=auto>
</p>


**Usage:**

    rotate_cluster (cluster_data, showFitting, save_mode);
    
**Input:**
 - **cluster_data** (structure array) - result from [least square circle fit](#5-program-fit_circle_to_clusterm)
 - **showFitting** (boolean) - whether to show the fitting result or not
 - **save_mode** (string):
    - **overwrite:** overwrite on base workspace variable *cluster_data*
    - **new:** create new variable *cluster_data_rotated* 
 

**Output:**
 - **cluster_data** (struct array) - append field **rotation**
    - **rotation** (numeric value between 0 and 45) <br> the phase angle (in degree) computed from the sinusoidal fit, as the rotation angle of the current cluster to the template.

### Fitting Nuclear Pore localizations

#### 7. Program: merge_cluster.m
   
Merges all the localizations from all clusters.

<p align="left">
<img src="/img/mergedCluster.png" width="600" height=auto>
</p>

**Usage:**

    merge_cluster (cluster_data, showResult, save_mode);

**Input:**
 - **cluster_data** (structure array) - result from [rotate cluster](#6-program-rotate_clusterm)
 - **showResult** (boolean) - whether to show the merged cluster or not
 - **save_mode** (string):
    - **overwrite:** overwrite on base workspace variable *cluster_data*
    - **new:** create new variable *cluster_data_merged*

**Output:**
 - **cluster_data** (struct array) - field **loc_norm** updated
    - **loc_norm** - the normalized localizations are now rotated by the angle computed from [rotate cluster](#6-program-rotate_clusterm)
 - **merged NPC** (N-by-5 data array) saved as tab-separated values to a text file ***pore_merged.txt*** in the root folder 

#### 8. Program: align_track_to_NPC.m
   
Description:

<p align="left">
<img src="/img/beads_alignment.png" width="600" height=auto>
</p>

**Usage:**

     result = align_track_to_NPC (file_track , beads_track, beads_npc, RIMF);
     
**Input:**
 - **file_track**
 - **beads_track**
 - **beads_npc**
 - **RIMF**

**Output:**

#### 9. Program: assign_track_to_cluster.m
 
Description: 

**Usage:**

    result = assign_track_to_cluster (track_data, npc_cluster_data);
    
**Input:**
 - **track_data**
 - **npc_cluster_data**

**Output:**

#### 10. Program: NPC_trafficking_visualizationUI.m
   
Description:

<p align="left">
<img src="/img/visualizationUI.png" width="600" height=auto>
</p>

**Usage:**

    NPC_trafficking_visualizationUI(npc_cluster_data_merged, track_data_aligned);
    
**Input:**
 - **npc_cluster_data_merged**
 - **track_data_aligned**

**Output:**


## Demo
We made a script that demo the whole workflow on the sample dataset (in the data folder) and with default parameters.

#### Program: demo.m

Description:


**Input:**

**Output:**



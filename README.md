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

This workflow doesn't require high computation power or special hardwares. It should work even with a laptop PC with OKish CPU and RAM. It developed with Windows system, but should also work on other OS with MATLAB and toolboxes readily installed. 

The codes was developed with Windows 10 Pro 22H2 Version and tested on Windows 11 Home version 10.0.22631.

## Instructions for use
Detailed explanations are provided at the top of each script and in the following README sections.
### Load and Pre-processing of MINFLUX data
1. **Program Name** : load_minflux_raw_data.m

   **What it does**: Load MINFLUX MATLAB format raw data, and applying filters on EFO, CFR, DCR, and track length parameters to separate individual localizations or traces whose localizations meet the filtering criteria for EFO, CFR, and DCR. Prepare data as tab-separated values with 5 columns: track ID, timestamp, X, Y, and Z coordinates. The following window will pop up, allowing the user to select their filtering criteria.
    <p align="left">
    <img src="/img/filterMInfluxData.png" width="400" height=auto>
    </p>
    
    **Input(s)**: It need the MATLAB format (.mat) of MINFLUX raw data file for pore scaffold and cargo. e.g.: model data "Nuclear Pore Model Data.mat". It will also ask for the filtering criterion on several properties of the data: cfr, efo, dcr, trace length and whether to filter with trace-level mean value, and refractive index mismatch factor (RIMF). For more detailed explanation on these parameters, please refer to the manuscript, or the comment section in the script. If one or more input is not yet defined during running, it will prompt a user input dialog to ask the user to provide them.
    
    **Output(s)**: A struct type variable with name "filterResult" in MATLAB base workspace. It contains the following fields:
    - trace_ID : array of trace ID (tid attribute of MINFLUX raw data)
    - time_stamp : array of time stamp, in seconds
    - loc_nm : array of the 3D localization coordinates, in nanometers
    - trace_txyz : N by 4 array of filtered localization data with 4 columns:time, x, y, and z coordinates, that can be used in other applications, e.g.: [msdanalyzer](https://tinevez.github.io/msdanalyzer/)
    - data_array : N by 5 array of filtered data with 5 columns: trace ID, time, x, y, and z coordinates. This is the type of data mainly used in our workflow. One can save it to a tabular format file onto disk, e.g.: tab-separated value as txt file 

    Note: This program is modified so that upon successful execution it will also export the data_array to a text file that saved to folder where the input file residue. The name will be the same as the MATLAB format data file, but with .txt extension. It stores the trace ID, time stamp, x, y, and z coordinates in nm as 5 column tab-separated values. This text file can be used as input for program 2 (semi_automated_clustering.m). Or if the input is the cargo tracking data, it can be used in program 8 and 9, align and assign tracks to NPC.

### Reconstruction of Nuclear Pore Localization Data
2. **Program Name** : semi_automated_clustering.m

    **What it does**: Spatial clustering of localization data. Upon running the program, a figure window with 2D scatter plot of the localizations will show. A initial User will need to draw a rectangular selection box around each cluster.  Once selected, double-clicking the rectangle will save the cluster. Repeat this process until all pore clusters are selected.  Once complete, save clusters and the figure can be closed. An error message will appear at the end, but it can be ignored. An image for cluster selection for the "Nuclear Pore Model Data" is attached.
    <p align="left">
    <img src="/img/semiAutomatedClustering.png" width="600" height=auto>
    </p>
    
    **Input(s)**: The N by 5 data array from filtered MINFLUX NPC data, containing in order values of: trace ID, time stamp, X, Y, and Z coordinates of localizations in nm. Optional paramters are the RIMF and epsilon and minPts of MATLAB density-base scan function.
    
    **Output(s)**: A struct type variable with name "cluster_data" in MATLAB base workspace. It contains the following fields:

### Fitting Nuclear Pore localizations
3. **Program Name** : fit_cylinder_to_cluster.m
   
**What it does**: Double circle fitting of  two rings from individual cluster. Image attached.
    <p align="left">
    <img src="/img/doubleRingFitting.png" width="600" height=auto>
    </p>
 <br />

 
**Input(s)**: 

**Output(s)**:

### Fitting Nuclear Pore localizations
4. **Program Name** : filter_NPC_cluster.m
   
**What it does**: .

 
**Input(s)**:

**Output(s)**:


### Fitting Nuclear Pore localizations
5. **Program Name** : fit_circle_to_cluster.m
   
**What it does**: .
    <p align="left">
    <img src="/img/lsqCircleFitting.png" width="600" height=auto>
    </p>
 <br />

 
**Input(s)**: 

**Output(s)**:



### Fitting Nuclear Pore localizations
6.  **Program Name** : rotate_cluster.m
   
**What it does**: 
    <p align="left">
    <img src="/img/sinusoidalFit.png" width="600" height=auto>
    </p>
 <br />

**Input(s)**: 

**Output(s)**:	


### Fitting Nuclear Pore localizations
7. **Program Name** : merge_cluster.m
   
**What it does**:
    <p align="left">
    <img src="/img/mergedCluster.png" width="600" height=auto>
    </p>
 <br />

**Input(s)**: 

**Output(s)**:	


 8. **Program Name** : align_track_to_NPC.m
   
**What it does**: 
    <p align="left">
    <img src="/img/beads_alignment.png" width="600" height=auto>
    </p>
 <br />

**Input(s)**: 

**Output(s)**:	

9. **Program Name** : assign_track_to_cluster.m
   
**What it does**: 

**Input(s)**: 

**Output(s)**:	

10. **Program Name** : NPC_trafficking_visualizationUI.m
   
**What it does**: 
    <p align="left">
    <img src="/img/visualizationUI.png" width="600" height=auto>
    </p>
 <br />

**Input(s)**: 

**Output(s)**:


## Demo
We made a script that demo the whole workflow with our uploaded sample data (in the data folder) and default parameters.

**Program Name** : demo.m
   
**What it does**: 

**Input(s)**: 

**Output(s)**:

Note: The "Nuclear Pore Model Data.txt/.mat" represents experimental measurements of Anti-GFP Nanobody HMSiR from a permeabilized cell. In contrast, "Tracks Model Data.txt" consists of example tracks derived from multiple experimental datasets, artificially aligned to the nuclear pore model for illustrative purposes, demonstrating the functionality of the fitting and alignment routine. "Bead loc_Red/NPC" provides synthetic coordinates from two channels, based on the average positional differences obtained in bead measurements. While efforts were made to preserve experimental resemblance during artificial alignment, these model tracks should not be used for drawing biological conclusions.

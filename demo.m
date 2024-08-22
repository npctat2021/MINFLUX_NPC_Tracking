% Script to load localization microscopy data from a .mat file
% 
% This script is designed to load a .mat file containing localization 
% microscopy data into a MATLAB workspace. The data is assumed to be in the 
% form of an N by 5 array where:
% - Column 1: Trace ID - An identifier for each trace that the localization 
%   belongs to
% - Column 2: Time Stamp - The time at which the localization event occurred,
%   measured in seconds
% - Columns 3, 4, and 5: Spatial Coordinates - The X, Y, and Z spatial
%   coordinates of the localization event, measured in meters
% 
% The loaded data will be stored in a variable called "data" for further
% analysis and processing.

addpath(genpath(pwd));
% Clear all variables from the workspace
%clear;
% Close all open figure windows
%close all;
% Clear the command window
%clc;

% Specify the path to the .csv file
% csvFilePath = 'path_to_your_csv_file/your_file_name.csv';
% Load the .csv file into the workspace
%data = readmatrix(csvFilePath);

%% Load MINFLUX .mat format raw data
% load MINFLUX NPC sample data
filePath = ".\data\Nuclear Pore Model Data.mat";
filterResult = filterMinfluxData( ...
    filePath,...
    [0, 0.8], ...   % cfr_range
    [1e4, 1e7], ... % efo_range
    [0, 1], ...     % dcr_range
    [1, 350], ...  % trace length range
    true,...        % compare with trace-wise mean value
    0.668 );        % referactive index mismatch factor: RIMF


%% perform the semi-automated clustering of NPC localization data
semiAutomatedClustering (filterResult.data_array); 

% from this point on, the cluster data should be stored in MATLAB base workspace
disp("result with name cluster_data should be saved to workspace for further processing, if confirmed, click Enter to continue");
pause;
% wait for user input;


%% fit double-ring model (cylinder) to each cluster
estimate_cylinder_MINFLUX (cluster_data, true);

%% filter clusters based on the cylinder fit results
filterCluster (cluster_data,...
    'new',...
    'heightMin', 25,...
    'heightMax', 100,...
    'diameterMin',70,...
    'diameterMax', 150,...
    'zCenterMin', -300,...
    'zCenterMax', 100,...
    'nLocMin', 20);

%% fit circle to 2D projection of clusters
circlefit_bisquare_MINFLUX (cluster_data_filtered, true, 'new');

%% compute 0-45 degree cluster rotation histogram, and align the clusters to same angle
pore_rotation_MINFLUX (cluster_data_bisquareCircleFitted, true, 'new')

%% merge the clusters together
pore_merge_MINFLUX (cluster_data_sineFit, true, 'new')


%% align track to NPC with beads calibration data
file_track = ".\data\Tracks Model Data.txt";
beads_track = ".\data\Bead Track.txt";
beads_npc = ".\data\Bead NPC.txt";
track_data = align_track_to_NPC (file_track , beads_track, beads_npc);
track_data = assign_track_to_cluster (track_data, cluster_data_merged);

%% The data is now ready for visualization
NPC_Trafficking_VisualizationUI(cluster_data_merged, track_data);

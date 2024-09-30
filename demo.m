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

%% Load MINFLUX NPC data

% load MINFLUX NPC sample data
%filePath = ".\data\Nuclear Pore Model Data.mat";
[file_npc, data_folder] = uigetfile('*.*',...
    'select nuclear pore data, either MINFLUX raw data in mat format, or sorted data in txt format.');
if ( file_npc == 0 )
    return;
end
npcFilePath = fullfile( data_folder, file_npc );

% referactive index mismatch factor, as measured experimentally
RIMF = 0.668;
% whether to save intermediate results or not
saveResultofEachStep = true;
%data_array = [];

% in case the loaded file is .mat format MINFLUX raw data, 
if endsWith(npcFilePath, ".mat")
    % load MINFLUX raw data, filter by cfr, efo, dcr, and trace length
    % arrange data into N by 5 data array, store to MATLAB base workspace
    % sort MINFLUX mat raw data into N by 5 data array
    % columns are: trace ID, time stamp, X, Y, and Z coordinates in nanometer
    filterResult = load_minflux_raw_data ( ...
        npcFilePath,...
        [0, 0.8], ...   % cfr_range
        [1e4, 1e7], ... % efo_range
        [0, 1], ...     % dcr_range
        [1, 350], ...   % trace length range
        true,...        % filter with trace-wise mean value
        RIMF );         % referactive index mismatch factor, to be applied on Z coordinates
    data_array = filterResult.data_array;
else
    % load 
    data_array = load (npcFilePath);
    % In case the data array loaded from txt file is not RIMF corrected
    data_array(:, 5) = data_array(:, 5) * RIMF;
end

%% perform the semi-automated clustering on NPC localization data (2D)
semi_automated_clustering (data_array, RIMF); 
disp("   Use 'Save' button on 'Interactive Clustering...' figure to save clustering result");
disp("   A variable with name 'cluster_data' should be saved to workspace for further processing");
disp("   Once finished, click 'Enter' in the Command Window to continue.");
pause; % wait for user press 'Enter' to continue;

%%
% from this point on, the cluster data should be stored in MATLAB base workspace
% each step will modify the result variable "cluster_data",
% if saveResultofEachStep is true, then a new result variable will be created
% instead. The intermediate results will be named with the operation and save
% to MATLAB base workspace next to "cluster_data"
%%

% parse save_mode for the following steps
save_mode = 'overwrite';    %#ok<NASGU>
if (saveResultofEachStep)
    save_mode = 'new';
end

%% fit double-ring model (cylinder) to each cluster
disp( "  - fitting cycliner to clusters..." );
fit_cylinder_to_cluster (cluster_data, true, save_mode);
if (saveResultofEachStep)
    cluster_data = cluster_data_cylinderFitted;
end

%% filter clusters based on the cylinder fit results
disp( "  - filtering clusters..." );
filter_NPC_cluster (cluster_data,...
    save_mode,...
    'heightMin', 25,...     % minimum inter-ring height
    'heightMax', 100,...    % maximum inter-ring height
    'diameterMin',70,...    % minimum ring diameter
    'diameterMax', 150,...  % maximum ring diameter
    'zCenterMin', -300,...  % z center location
    'zCenterMax', 100,...   %
    'nLocMin', 20);         % minimum data point in cluster
if (saveResultofEachStep)
    cluster_data = cluster_data_filtered;
end

%% fit circle to 2D projection of clusters
disp( "  - fitting circle to clusters..." );
fit_circle_to_cluster (cluster_data, true, save_mode);
if (saveResultofEachStep)
    cluster_data = cluster_data_circleFitted;                              
end

%% compute 0-45 degree cluster rotation histogram, and align the clusters to same angle
disp( "  - computing rotation phase angle of each cluster..." );
rotate_cluster (cluster_data, true, save_mode)
if (saveResultofEachStep)
    cluster_data = cluster_data_rotated;
end

%% merge the clusters together
disp( "  - transform and merging clusters together..." );
merge_cluster (cluster_data, true, save_mode);
if (saveResultofEachStep)
    cluster_data = cluster_data_merged;
end

%% align and assign track to NPC with beads calibration data
%  the alignment can also be done with semi-automated clustering step,
%  with button function 'Load track data', as a result, a variable
%  'track_data' would have been saved to MATLAB base Workspace.
%  In this case, the demo script will directly go to assignemnt step.
track_data_exist = evalin( 'base', 'exist(''track_data'',''var'') == 1' );
if ~track_data_exist
    file_track =    fullfile(data_folder, "Tracks Model Data.txt");
    beads_track =   fullfile(data_folder, "Bead Track.txt");
    beads_npc =     fullfile(data_folder, "Bead NPC.txt");
    if ( ~isfile(file_track) || ~isfile(beads_track) || ~isfile(beads_npc))
        track_data_exist = false;
    else
        track_data = align_track_to_NPC (file_track, beads_track, beads_npc, RIMF);
    end
end
if track_data_exist
    track_data = assign_track_to_cluster (track_data, cluster_data);
else
    track_data = [];
end

%% A visualziation UI which facilitate qualitative check on the result
disp( "  - display the final merged NPC cluster with NPC visualization GUI..." );
fprintf('\n');
NPC_trafficking_visualizationUI(cluster_data, track_data);


% This script is designed to demo the workflow of 
% MINFLUX Nuclear Pore transport data processing
%
% It sets several parameters with the default value, that specific to the 
% MINFLUX NPC transport project and data:
% e.g.: refractive index mismatch factor, RIMF; and the data filtering criterions

% <ziqiang.huang@embl.de>
% date: 2024.10.24
    
    %% add sub-folder to MATLAB path, refresh MATLAB working environment 
    addpath(genpath(pwd));
    % Clear all variables from the workspace
    %clear;
    % Close all open figure windows
    %close all;
    % Clear the command window
    %clc;
    
    %% Load MINFLUX NPC model data
    
    % load MINFLUX NPC sample data, could be .mat raw data or .txt model data
    %filePath = ".\data\Nuclear Pore Model Data.mat";
    [file_npc, data_folder] = uigetfile('*.*',...
        'select nuclear pore data, either MINFLUX raw data in mat format, or sorted data in txt format.');
    if ( file_npc == 0 )
        return;
    end
    npcFilePath = fullfile( data_folder, file_npc );
    
    % the referactive index mismatch factor, as measured experimentally
    % this value will be applied to Z-axis localization values prior to
    % 3d quantitative analysis
    RIMF = 0.67;    % assume to be 0.67 for demo, as of 2024.10.23
    
    % whether to show and save intermediate results or not
    showResultofEachStep = true;
    saveResultofEachStep = true;
    
    % in case the loaded file is .mat format MINFLUX raw data, 
    if endsWith(npcFilePath, ".mat")
        % load MINFLUX raw data, filter by cfr, efo, dcr, and trace length
        % arrange data into N by 5 data array, store to MATLAB base workspace
        % sort MINFLUX mat raw data into N by 5 data array:
        % trace ID, time stamp, X, Y, and Z coordinates
        % this function doesn't change parameter unit and values: i.e:
        % time will be in second, and coordinates will be in meters
        filterResult = load_minflux_raw_data ( ...
            npcFilePath,...
            [0, 0.8], ...   % cfr_range [0, 0.8]
            [1e4, 1e7], ... % efo_range [1e4, 1e7]
            [0, 1], ...     % dcr_range [0, 1]
            [1, 350], ...   % trace length range [1, 350]
            true, ...       % filter with trace-wise mean value
            false );        % do not save data array to .txt data file for demo
        data_array = filterResult.data_array; % RIMF not applied
    else
        % load data array from .txt file 
        % that prevously converted already with load_minflux_raw_data.m script
        data_array = load (npcFilePath); % RIMF not applied
    end
    
    %% perform the semi-automated clustering on NPC localization data (2D)
    semi_automated_clustering (data_array, RIMF, 55);  % RIMF correction applied here, for the NPC model data
    disp("   Use 'Save' button on 'Interactive Clustering...' figure to save clustering result");
    disp("   A variable with name 'cluster_data' should be saved to workspace for further processing");
    disp("   Once finished, click 'Enter' in the Command Window to continue.");
    pause; % wait for user press 'Enter' to continue;
    
    %%
    % From this point on, the cluster data should be stored in MATLAB base workspace.
    % Each step will then modify the result data stored in variable "cluster_data",
    % if 'saveResultofEachStep' is set to true, then a new result variable will be created
    % instead. The intermediate results will be named with the operation and save
    % to MATLAB base workspace next to "cluster_data"
    %%

    % parse save_mode for the following steps
    save_mode = 'overwrite';    %#ok<NASGU>
    if (saveResultofEachStep)
        save_mode = 'new';      % keep the intermediate results in base workspace
    end
    
    
    %% fit double-ring model (cylinder) to each cluster
    disp( "  - fitting cylinder to cluster..." );
    fit_cylinder_to_cluster (cluster_data, showResultofEachStep, save_mode);
    if (saveResultofEachStep)
        cluster_data = cluster_data_cylinderFitted;
    end
    
    %% filter clusters based on the cylinder fit results
    disp( "  - filtering cluster..." );
    filter_NPC_cluster (cluster_data, save_mode,...
        'heightMin', 25,...     % minimum inter-ring height
        'heightMax', 100,...    % maximum inter-ring height
        'diameterMin',70,...    % minimum ring diameter
        'diameterMax', 150,...  % maximum ring diameter
        'zCenterMin', -300,...  % lower z center location
        'zCenterMax', 100,...   % upper z center location
        'nLocMin', 20);         % minimum number of localizations in cluster
    if (saveResultofEachStep)
        cluster_data = cluster_data_filtered;
    end
    
    %% fit circle to 2D projection of clusters
    disp( "  - fitting circle to cluster..." );
    fit_circle_to_cluster (cluster_data, showResultofEachStep, save_mode);
    if (saveResultofEachStep)
        cluster_data = cluster_data_circleFitted;                              
    end
    
    %% compute 0-45 degree cluster rotation histogram, and align the clusters to same angle
    disp( "  - computing rotation phase angle of each cluster..." );
    rotate_cluster (cluster_data, 5, 22.5, showResultofEachStep, save_mode);
    if (saveResultofEachStep)
        cluster_data = cluster_data_rotated;
    end
    
    %% merge the clusters together
    disp( "  - transform and merge clusters together..." );
    merge_cluster (cluster_data, showResultofEachStep, save_mode);
    if (saveResultofEachStep)
        cluster_data = cluster_data_merged;
    end
    
    %% align and assign track to NPC with beads calibration data
    %  the alignment can also be done before with semi-automated 
    %  clustering step, with button function 'Load track data'.
    %  As a result, a variable with name 'track_data' would have been 
    %  saved to MATLAB base Workspace.
    %  In this case, the demo script will directly go to assignemnt step.
    track_data_exist = evalin( 'base', 'exist(''track_data'',''var'') == 1' );
    if ~track_data_exist || isempty(track_data)
        file_track =    fullfile(data_folder, "Tracks Model Data.txt");
        beads_track =   fullfile(data_folder, "Bead Track.txt");
        beads_npc =     fullfile(data_folder, "Bead NPC.txt");
        if ( ~isfile(file_track) || ~isfile(beads_track) || ~isfile(beads_npc))
            track_data_exist = false;
        else
            track_data = align_track_to_NPC (file_track, beads_track, beads_npc, RIMF); % RIMF correction for the Track data applied here
            if ~isempty(track_data)
                track_data_exist = true;
            end
        end
    end
    
    % assign the tracks to recognized NPC clusters
    % a track would be only recongnized if it located onto / next to a previsouly
    % segmented and processed NPC, so that the center of rotation angle of
    % the NPC can be extracted, and apply onto the localizations of the
    % track data
    if track_data_exist
        track_data = assign_track_to_cluster (track_data, cluster_data);
    else
        track_data = [];
    end
    
    %% Display reconstructed NPC and reconginzed tracks 
    %  with the visualziation UI that facilitate qualitative check on the result
    disp( "  - display the final merged NPC cluster with NPC visualization GUI..." );
    fprintf('\n');
    NPC_trafficking_visualizationUI(cluster_data, track_data);


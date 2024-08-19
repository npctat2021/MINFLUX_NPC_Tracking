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

% Clear all variables from the workspace
clear;
% Close all open figure windows
close all;
% Clear the command window
clc;

% Specify the path to the .csv file
%csvFilePath = 'path_to_your_csv_file/your_file_name.csv';
% Load the .csv file into the workspace
%data = readmatrix(csvFilePath);

% Specify the path to the .mat file
filePath = "C:\Users\zhuang\Workspace\MINFLUX\TAMU_tracking\MINFLUX_NPC_Tracking-main\Nuclear Pore Model Data.txt";

% Load the .mat file into the workspace
data = load(filePath);

% Assuming the data is stored under a specific variable name within the .mat file,
% replace 'variableName' with the actual name of the variable in the .mat file
%data = loadedData.variableName;

% Ensure that the loaded data is in the correct format
if ~isequal(size(data, 2), 5)
    error('Data format is incorrect. Expected a N by 5 array.');
end


% populate trace ID, time stamp, and localization coordinates
tid = data(:, 1);    % Trace ID
tim = data(:, 2);    % Time Stamp
loc = 1e9* data(:, 3:5);  % X, Y, Z coordinates in nm
uid = unique(tid);
trace_length = arrayfun(@(x) sum(tid==x), uid);

% get centroid coordinates of each trace
loc_trace = zeros(length(uid), 3);
loc_trace(:,1) = arrayfun(@(id) mean( loc(tid==id, 1) ), uid);
loc_trace(:,2) = arrayfun(@(id) mean( loc(tid==id, 2) ), uid);
loc_trace(:,3) = arrayfun(@(id) mean( loc(tid==id, 3) ), uid);

% Cluster loc_trace using DBSCAN, set epsilon to 100 and minPts to 30
cid = dbscan(loc_trace(:, 1:2), 2*50, 30);
% get unique cluster labels from cid
ulabel = unique(cid);
% reconstruct a cid array corresponding to each localization in loc
cid_all = repelem(cid, trace_length);


pointCloud = loc(cid_all==10,:);






% The data is now ready for further processing and analysis


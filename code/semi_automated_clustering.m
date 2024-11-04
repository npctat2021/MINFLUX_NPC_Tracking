function semi_automated_clustering(data, RIMF, dbscan_eps, dbscan_minPts)
    % semi_automated_clustering Performs semi-automated clustering 
    % on MINFLUX localization data with interactive UI controls in MATLAB
    % 
    % Inputs:
    %   data (Nx5 array) - An N by 5 numeric array of localization data, where
    %                       each row corresponds to a localization event with
    %                       the following columns: [ID, Time, X, Y, Z].
    %   RIMF (numeric) - refractive index mismatch factor, which will be used 
    %                     to scale Z axis value: z(physical) = z(data) * RIMF;
    %   dbscan_eps (numeric) - The epsilon parameter for density-based scanning,
    %                           which is the maximum distance between points to 
    %                           be reconginzed as belonging to one cluster, 
    %                           for the DBSCAN clustering.
    %   dbscan_minPts (numeric) - The minimum number of points required to form 
    %                               a cluster, for the DBSCAN clustering.
    %
    % Outputs:  not as function return argument, instead it is saved directly to 
    %           MATLAB base workspace with UI 'Save' button action.
    %           This is to adapt to the interactive UI design.
    %   cluster_data (struct array) - A structure array containing clustering 
    %                                   results with the following fields:
    %       - ROI: Coordinates defining the 2D rectangular ROI for the cluster.
    %       - cluster_ID: unique numeric identifier for the cluster.
    %       - loc_nm: Localization data in nanometers.
    %       - tid: Trace ID corresponding to the localizations.
    %       - tim: Time stamp associated with the localizations.
    %
    % Example:
    %       semi_automated_clustering (data_array, 0.67, 55, 5);
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04

    %% input argument control
    if nargin < 4
        dbscan_minPts = 5; % by default expect at least 5 traces in a NPC
    end
    if nargin < 3
        dbscan_eps = 55;   % by default expect NPC radius to be 55 nm
    end
    if nargin < 2
        RIMF = 0.67;
    end
    
    %% get MINFLUX data properties
    tid = data(:, 1);
    tim = data(:, 2);
    loc_nm = data(:, 3:5);
    if range(loc_nm(:,3)) < 1  % check if the localization unit has already been converted to nanometer
        loc_nm = loc_nm * 1e9;
    end
    loc_nm(:, 3) = loc_nm(:, 3) * RIMF;
    % get unique trace ID
    uid = unique(tid);
    trace_length = arrayfun(@(x) sum(tid==x), uid);
    % get centroid coordinates of each trace
    loc_trace = zeros(length(uid), 3);
    loc_trace(:,1) = arrayfun(@(id) mean( loc_nm(tid==id, 1) ), uid);
    loc_trace(:,2) = arrayfun(@(id) mean( loc_nm(tid==id, 2) ), uid);
    loc_trace(:,3) = arrayfun(@(id) mean( loc_nm(tid==id, 3) ), uid);
    %% perform an initial DBSCAN clustering on centroid of traces
    cid = dbscan(loc_trace(:, 1:2), dbscan_eps, dbscan_minPts);
    cid_all = repelem(cid, trace_length);
    % get unique cluster ID
    unique_cid = unique(cid);
    cluster_length = arrayfun(@(x) sum(cid_all==x), unique_cid);
    %% Create figure to visualize and enable interactive ROI selection
    if ~ishandle(900)
        fig = figure(900);
        fig.NumberTitle = 'off';
        fig.Name = 'Interactive Clustering of NPC localization data';
        fig.Position = [100, 100, 1200, 800];
    else
        fig = findobj( 'Type', 'Figure', 'Number', 900);
    end

    %ax = findall(fig,'type','axes');
    %cla(ax);
    ax = gca;
    
    % Plot initial clustering
    scatter3(ax, loc_nm(:, 1), loc_nm(:, 2), loc_nm(:, 3), [], cid_all, '.');
    axis equal;
    view(2);    % display as X-Y view
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('scatter plot of NPC Loc data');
    hold on;
    
    % Initialize cluster data
    cluster_data = struct('ROI', {}, 'cluster_ID', {}, 'loc_nm', {});

    % plot rectangle ROI around dbscan generated clusters
    for i = 1 : length(unique_cid) 
        cluster_id = unique_cid(i);
        if (cluster_id == -1 || cluster_length(i) <= 5 ) 
            continue; % cluster ID = -1 for noise from dbscan
        end
        loc_min = min( loc_nm(cid_all==cluster_id, 1:2) );
        loc_max = max( loc_nm(cid_all==cluster_id, 1:2) );
        margin = 10; % create ROI with a 10 nm margin on all sides
        xmin = loc_min(1) - margin; ymin = loc_min(2) - margin;
        xmax = loc_max(1) + margin; ymax = loc_max(2) + margin;
        

        roi_auto = drawrectangle(ax, 'Position',[xmin, ymin, xmax-xmin, ymax-ymin],...
            'LineWidth', 1, 'MarkerSize', 5, ...
            'edgecolor','g', 'StripeColor','g', 'FaceAlpha', 0.1,...
            'Label', ""+cluster_id, 'LabelTextColor', 'r');

        if isempty(cluster_data)
            new_cluster_ID = 1;
        else
            new_cluster_ID = max([cluster_data.cluster_ID]) + 1;
        end

        cluster_data(end+1).cluster_ID = new_cluster_ID;   %#ok<AGROW>
        cluster_data(end).ROI = roi_auto; 
        cluster_data(end).loc_nm = loc_nm(cid_all==cluster_id, :);
        
    end


    %% UI control elements
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Load track data', 'Position', [220 10 120 30], 'Callback', @loadTrackData);
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Manual draw new cluster', 'Position', [370 10 150 30], 'Callback', @drawRectangle);
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Show / Hide clusters', 'Position', [550 10 120 30], 'Callback', @showClusters);
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Save', 'Position', [700 10 70 30], 'Callback', @saveClusters);
    
    %% call back functions of UI component
    % Callback function for load track data onto the scatter plot
    function loadTrackData(~, ~)
        [files, dir] = uigetfile('*.txt', 'select track data, together with the beads data for alignment.', 'MultiSelect', 'on');
        if ( isempty(files) || length(files) ~= 3)
            return;
        end
        file_track = []; beads_npc = []; beads_track = [];
        for f = 1 : 3
            filename = files{f};
            switch filename
                case "Tracks Model Data.txt"
                    file_track = fullfile(dir, filename);
                case "Bead Cargo.txt"
                    beads_track = fullfile(dir, filename);
                case "Bead NPC.txt"
                    beads_npc = fullfile(dir, filename);
            end    
        end
        track_data = align_track_to_NPC (file_track , beads_track, beads_npc, RIMF);
        
        loc_nm_track = track_data.data_array(:, 3:5);
        if range(loc_nm_track(:,3)) < 1  % check if the localization unit has already been converted to nanometer
            loc_nm_track = loc_nm_track * 1e9;
        end
        loc_nm_track(:, 3) = loc_nm_track(:, 3) * RIMF;
        scatter3(ax, loc_nm_track(:, 1), loc_nm_track(:, 2), loc_nm_track(:, 3), 'r.');

    end

    % Callback function for drawing rectangles
    function drawRectangle(~, ~)
        % get current cluster count
        if isempty(cluster_data)
            new_cluster_ID = 1;
        else
            new_cluster_ID = max([cluster_data.cluster_ID]) + 1;
        end
        roi_manual = drawrectangle(ax,...
            'LineWidth', 1, 'MarkerSize', 5, ...
            'edgecolor','g', 'StripeColor','g', 'FaceAlpha', 0.1,...
            'Label', ""+new_cluster_ID, 'LabelTextColor', 'r');
        % Append new cluster data
        cluster_data(end+1).cluster_ID = new_cluster_ID; 
        cluster_data(end).ROI = roi_manual;
        % Append loc inside the drawn ROI to form a new cluster
        tf = inROI( roi_manual, loc_nm(:,1), loc_nm(:,2) );
        cluster_data(end).loc_nm = loc_nm(tf, :);              
        % ignore tid and tim for now
    end

    % Callback function to toggle show/hide cluster rectangles
    function showClusters(~, ~)
        for k = 1:length(cluster_data)
            roi = cluster_data(k).ROI;
            if isgraphics(roi) && isvalid(roi)
                roi.Visible = ~roi.Visible;
            end
        end
    end

    % Callback function to save clusters to workspace
    function saveClusters(~, ~)
        num_clusters = length(cluster_data);
        empty_cluster = false(num_clusters, 1);

        for idx = 1:num_clusters
            roi = cluster_data(idx).ROI;
            if ~isgraphics(roi)
                empty_cluster(idx) = true;
                continue;
            end            
            tf = inROI( roi, loc_nm(:,1), loc_nm(:,2) );
            tf = tf & loc_nm(:,3)<=100;
            cluster_data(idx).loc_nm = loc_nm(tf, :);       
            cluster_data(idx).tid = tid(tf, :);
            cluster_data(idx).tim = tim(tf, :);
        end
        cluster_data(empty_cluster) = [];
        
        assignin('base', 'cluster_data', cluster_data);
        disp('   Clusters saved to workspace as "cluster_data".');
    end
    fprintf('\n');
end

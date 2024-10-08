function semi_automated_clustering(data, RIMF, dbscan_eps, dbscan_minPts)
    % Semi-automated clustering with interactive UI controls in MATLAB
    % 
    % Inputs:
    %   data - Nx5 matrix of input localization data: ID, tim, x,y,z
    %   RIMF - refractive index mismatch factor, as to scale Z axis value: z(physical) = z(data) * RIMF;
    %   dbscan_eps - maximum distance between points to be reconginzed as belonging to one cluster, for the DBSCAN clustering.
    %   dbscan_minPts - minimum number of points in a DBSCAN cluster

    
    %% input argument control
    if nargin < 4
        dbscan_minPts = 5; % by default expect at least 5 traces in a NPC
    end
    if nargin < 3
        dbscan_eps = 110;   % by default expect NPC radius to be 55 nm
    end
    if nargin < 2
        RIMF = 0.668;
    end
    
    %% get MINFLUX data properties
    tid = data(:, 1);
    tim = data(:, 2);
    loc = data(:, 3:5);
    if (range(data(:,5)) ) < 1  % check if the localization unit has already been converted to nanometer
        loc = loc * 1e9;
    end
    % get unique trace ID
    uid = unique(tid);
    trace_length = arrayfun(@(x) sum(tid==x), uid);
    % get centroid coordinates of each trace
    loc_trace = zeros(length(uid), 3);
    loc_trace(:,1) = arrayfun(@(id) mean( loc(tid==id, 1) ), uid);
    loc_trace(:,2) = arrayfun(@(id) mean( loc(tid==id, 2) ), uid);
    loc_trace(:,3) = arrayfun(@(id) mean( loc(tid==id, 3) ), uid);
    %% perform an initial DBSCAN clustering on centroid of traces
    cid = dbscan(loc_trace(:, 1:2), dbscan_eps, dbscan_minPts);
    cid_all = repelem(cid, trace_length);
    % get unique cluster ID
    unique_ids = unique(cid);
 
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
    scatter3(ax, loc(:, 1), loc(:, 2), loc(:, 3), [], cid_all, '.');
    axis equal;
    view(2);    % display as X-Y view
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('scatter plot of NPC Loc data');
    hold on;
    
    % Initialize cluster data
    cluster_data = struct('Rectangle', {}, 'ClusterID', {}, 'loc_nm', {});

    % plot rectangle ROI around dbscan generated clusters
    for i = 1: length(unique_ids) 
        cluster_id = unique_ids(i);
        if (cluster_id == -1) 
            continue; % cluster ID = -1 for noise from dbscan
        end
        loc_min = min( loc(cid_all==cluster_id, 1:2) );
        loc_max = max( loc(cid_all==cluster_id, 1:2) );
        margin = 10; % create ROI with a 10 nm margin on all sides
        xmin = loc_min(1) - margin; ymin = loc_min(2) - margin;
        xmax = loc_max(1) + margin; ymax = loc_max(2) + margin;
        

        roi_auto = drawrectangle(ax, 'Position',[xmin, ymin, xmax-xmin, ymax-ymin],...
            'LineWidth', 1, 'MarkerSize', 5, ...
            'edgecolor','g', 'StripeColor','g', 'FaceAlpha', 0.1,...
            'Label', ""+cluster_id, 'LabelTextColor', 'r');

        if isempty(cluster_data)
            newClusterID = 1;
        else
            newClusterID = max([cluster_data.ClusterID]) + 1;
        end

        cluster_data(end+1).ClusterID = newClusterID;   %#ok<AGROW>
        cluster_data(end).Rectangle = roi_auto; 
        cluster_data(end).loc_nm = loc(cid_all==cluster_id, :);
        
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
                case "Bead Track.txt"
                    beads_track = fullfile(dir, filename);
                case "Bead NPC.txt"
                    beads_npc = fullfile(dir, filename);
            end    
        end
        track_data = align_track_to_NPC (file_track , beads_track, beads_npc, RIMF);
        scatter3(ax, track_data.data_array(:, 3), track_data.data_array(:, 4), track_data.data_array(:, 5), 'r.');

    end

    % Callback function for drawing rectangles
    function drawRectangle(~, ~)
        % get current cluster count
        if isempty(cluster_data)
            newClusterID = 1;
        else
            newClusterID = max([cluster_data.ClusterID]) + 1;
        end
        roi_manual = drawrectangle(ax,...
            'LineWidth', 1, 'MarkerSize', 5, ...
            'edgecolor','g', 'StripeColor','g', 'FaceAlpha', 0.1,...
            'Label', ""+newClusterID, 'LabelTextColor', 'r');
        % Append new cluster data
        cluster_data(end+1).ClusterID = newClusterID; 
        cluster_data(end).Rectangle = roi_manual;
        % Append loc inside the drawn ROI to form a new cluster
        tf = inROI( roi_manual, loc(:,1), loc(:,2) );
        cluster_data(end).loc_nm = loc(tf, :);              
        % ignore tid and tim for now
    end

    % Callback function to toggle show/hide cluster rectangles
    function showClusters(~, ~)
        for k = 1:length(cluster_data)
            roi = cluster_data(k).Rectangle;
            roi.Visible = ~roi.Visible;
        end
    end

    % Callback function to save clusters to workspace
    function saveClusters(~, ~)
        num_clusters = length(cluster_data);
        empty_cluster = false(num_clusters, 1);

        for idx = 1:num_clusters
            roi = cluster_data(idx).Rectangle;
            if ~isgraphics(roi)
                empty_cluster(idx) = true;
                continue;
            end            
            tf = inROI( roi, loc(:,1), loc(:,2) );
            tf = tf & loc(:,3)<=100;
            cluster_data(idx).loc_nm = loc(tf, :);       
            cluster_data(idx).tid = tid(tf, :);
            cluster_data(idx).tim = tim(tf, :);
        end
        cluster_data(empty_cluster) = [];
        
        assignin('base', 'cluster_data', cluster_data);
        disp('   Clusters saved to workspace as "cluster_data".');
    end
    fprintf('\n');
end

function NPC_trafficking_visualizationUI(npc_cluster_data_merged, track_data_aligned)
    % NPC_trafficking_visualizationUI display the reconstructed NPC
    % scaffold in together with the aligned Cargo data for a quick quality
    % check on the NPC reconstruction and Cargo tranportation
    %
    % Inputs:
    %   npc_cluster_data_merged (struct array) - Structure array containing merged cluster data
    %                                            of the nuclear pore complexes, which need to include
    %                                            fields: loc_norm
    %   track_data_aligned (struct array) - Structure array containing aligned tracking data of 
    %                                        NPC localizations, including time and spatial information.
    %
    % Outputs:
    %   This function does not return any outputs; it creates a graphical user interface for visualization.
    %
    % Example:
    %   NPC_trafficking_visualizationUI(cluster_data_merged, track_data);
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04

    % debug mode to visualize only NPC cluster without tracks
    if ( nargin < 2 || isempty(track_data_aligned) )
        track_data_aligned = struct();
        track_data_aligned.trace_ID = 0;
        track_data_aligned.tim_ms = {0};
        track_data_aligned.loc_nm = {[0, 0, 0]};
        track_data_aligned.trace_txyz = {[0, 0, 0, 0]};
        track_data_aligned.cluster_ID = -1;
    end

    % Create a new figure for the UI
    if ishandle(905)
        fig = findobj( 'Type', 'Figure', 'Number', 905);
        close (fig);
    end
    fig = figure(905);
    fig.NumberTitle = 'off';
    fig.Name = 'NPC Visualization';
    fig.Position = [100, 100, 800, 600];

    % Axes for displaying the visualization
    ax = axes('Parent', fig, 'Position', [0.05, 0.3, 0.9, 0.65]);
    hold(ax, 'on');
    axis(ax, 'equal');
    xlabel(ax, 'X');
    ylabel(ax, 'Y');
    zlabel(ax, 'Z');
    title(ax, 'NPC Visualization');
    grid(ax, 'on');
    
    % parse NPC geometry parameters
    diameter = vertcat(npc_cluster_data_merged.diameter);   % NPC diameter
    height = vertcat(npc_cluster_data_merged.height);       % NPC inter-ring distance
    loc_npc = vertcat(npc_cluster_data_merged.loc_norm);
    tid = vertcat(npc_cluster_data_merged.tid);
    uid = unique(tid);
    trace_length = arrayfun(@(x) sum(tid==x), uid);
    uid( trace_length<=3, : ) = [];
    range_trace_npc = arrayfun(@(x) range(loc_npc(tid==x, 1:2)), uid, 'UniformOutput', false);
    range_trace_npc = cell2mat(range_trace_npc);
    subunitSize = mean( mean(range_trace_npc) );           % NPC sub-unit size
    
    % parse tracks
    nTracks = length(track_data_aligned.trace_ID);
    track_list = cell(nTracks, 1);
    for i = 1 : nTracks
        track_list{i} = string( track_data_aligned.trace_ID(i) );
    end

    % Create placeholders for graphics objects
    plotNPCRaw = [];
    plotPtCloud = [];
    plotSurface = cell(16, 1);
    scatterTrack = [];
    plotTrackHead = [];
    loc_norm = [];
    nLoc = 100;

    % Parameters for the NPC and visualization
    interRingDistance = mean(height);
    clusterDiameter = subunitSize; % diameter of subunit cluster

    % Initial display of NPC as surface
    plotNPC(ax, loc_npc, mean(diameter)/2, interRingDistance, clusterDiameter); % create NPC rendering of: raw data, point cloud, and surface
    plotTrack(1);

    % UI components
    % First row of checkboxes
    uicontrol('Style', 'checkbox', 'String', 'NPC Raw Data', ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'Position', [200, 100, 140, 20], 'Value', 1, ...
        'Callback', @(src, evt) toggleNPCRawData(src));

    uicontrol('Style', 'checkbox', 'String', 'NPC Model as Point Cloud', ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'Position', [340, 100, 200, 20], 'Value', 0, ...
        'Callback', @(src, evt) toggleNPCPointCloud(src));

    uicontrol('Style', 'checkbox', 'String', 'NPC Model as Surface', ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'Position', [560, 100, 160, 20], 'Value', 0, ...
        'Callback', @(src, evt) toggleNPCSurface(src));

    % Second row: dropdown, text field, toggle button, slider
    uicontrol('Style', 'text', 'String', 'Track', ...
        'FontSize', 10, 'FontWeight', 'bold',...
        'Position', [70, 60, 100, 20]);
    
    uicontrol('Style', 'popupmenu', 'String', track_list, ...
        'Position', [150, 60, 60, 20], 'Callback', @(src, evt) trackSelection(src));

    playButton = uicontrol('Style', 'togglebutton', 'String', '▶', ...
        'Position', [220, 60, 30, 20], 'Callback', @(src, evt) playTracks(src));

    slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', 0, ...
        'Position', [260, 60, 500, 20], 'Callback', @(src, evt) adjustTimeSlider(src));

    function toggleNPCRawData(checkbox)
        if checkbox.Value
            if ~isempty(plotNPCRaw)
                set(plotNPCRaw, 'Visible', 'on');
            end
        else
            set(plotNPCRaw, 'Visible', 'off');
        end
    end

    function toggleNPCPointCloud(checkbox)
        if checkbox.Value
            set(plotPtCloud, 'Visible', 'on');
        else
            set(plotPtCloud, 'Visible', 'off');
        end
    end

    function toggleNPCSurface(checkbox)
        visibleState = 'off';
        if checkbox.Value
            visibleState = 'on';
        end
        for n = 1 : length(plotSurface)
            set(plotSurface{n}, 'Visible', visibleState);
        end
    end

    function trackSelection(src)
        % Handle track selection; for now, just display in the console
        plotTrack( src.Value );

    end
    
    function plotTrack (idx_trk)
        loc_norm = [];
        delete( scatterTrack);
        slider.Value = 0;
        if (track_data_aligned.cluster_ID(idx_trk) == -1)
            disp( strcat('    selected track: ',  num2str(track_data_aligned.trace_ID(idx_trk)), ', is not assigned to any NPC cluster!') );
            return;
        end
        loc_norm = track_data_aligned.loc_norm{idx_trk};
        nLoc = size(loc_norm, 1);
        scatterTrack = plot3(ax, loc_norm(:,1), loc_norm(:,2), loc_norm(:,3), '-b', 'LineWidth', 2);
        if ~isempty(plotTrackHead)
            plotTrackHead.XData = loc_norm(1, 1);
            plotTrackHead.YData = loc_norm(1, 2);
            plotTrackHead.ZData = loc_norm(1, 3);
            plotTrackHead.Visible = 'off';
        end
    end


    function playTracks(toggleButton)
        if toggleButton.Value
            toggleButton.String = '⏸'; % Change to pause symbol
        else
            toggleButton.String = '▶'; % Change to play symbol
        end
        if isempty(loc_norm)
            return;
        end
        while slider.Value <= 0.99 % auto-play the time slider to the right
            if ~playButton.Value %|| count>maxCount
                break;
            end
            slider.Value = slider.Value + 0.01;
            plotHead(slider.Value);
            java.lang.Thread.sleep(50); % by default pause for 50 ms betweem every 1% increment
            drawnow;
        end
    end

    function adjustTimeSlider(slider)
        plotHead(slider.Value)
    end
    
    function plotHead (percentage)
        if isempty(loc_norm)
            return;
        end
        idx = round( percentage * nLoc );
        idx = max (1, idx);
        idx = min( idx, nLoc);
        if isempty(plotTrackHead)
            plotTrackHead = plot3(ax, loc_norm(idx, 1), loc_norm(idx, 2), loc_norm(idx, 3),...
                'Marker', 'pentagram', 'MarkerSize', 18, 'MarkerEdgeColor', 'magenta', 'MarkerFaceColor', 'magenta');
        else
            plotTrackHead.Visible = 'on';
            plotTrackHead.XData = loc_norm(idx, 1);
            plotTrackHead.YData = loc_norm(idx, 2);
            plotTrackHead.ZData = loc_norm(idx, 3);
        end
    end

    function plotNPC(ax, loc_nm, radius, interRingDistance, clusterDiameter)        
        % Plot the NPC as both point cloud and surface, controlling visibility via the UI
        plotNPCRaw = [];
        plotPtCloud = [];
        plotSurface = cell(16, 1);

        % Create 2-ring 8-fold sub-unit geometry model for NPC
        numSubunitPerRing = 8;
        angleIncrement = 360 / numSubunitPerRing;
        clusterCenters = zeros(numSubunitPerRing * 2, 3);
        for n = 1 : numSubunitPerRing
            angleRad = deg2rad(angleIncrement * (n - 1) + 22.5);
            clusterCenters(n, :) = [radius * cos(angleRad), radius * sin(angleRad), -interRingDistance/2];
            clusterCenters(n + numSubunitPerRing, :) = ...
                [radius * cos(angleRad), radius * sin(angleRad), interRingDistance/2];
        end

        % Make a 3D histogram rendering of the Localization, 
        % calculate local density map for coloring the scatter points
        xnm = loc_nm(:,1); ynm = loc_nm(:,2); znm = loc_nm(:,3);
        binSize = 1; %round(clusterSigma);
        xedge = min(xnm) : binSize : max(xnm);
        yedge = min(ynm) : binSize : max(ynm);
        zedge = min(znm) : binSize : max(znm);
        %binCount3d = histcnd(xnm,ynm,znm, xedge,yedge,zedge);
        binCount3d = histcounts3 (xnm, ynm, znm, binSize);
        density_map_smoothed = imgaussfilt3(binCount3d, 1);
        [~, ~, xbin] = histcounts(xnm, xedge);
        [~, ~, ybin] = histcounts(ynm, yedge);
        [~, ~, zbin] = histcounts(znm, zedge);
        xbin(xbin==0) = 1;
        ybin(ybin==0) = 1;
        zbin(zbin==0) = 1;
        density = arrayfun(@(idx) density_map_smoothed(xbin(idx), ybin(idx), zbin(idx)), 1:length(loc_nm));
        
        % Get plot parameters from the calculated result:
        numPoints = length(loc_nm) / 16;    % number of points per sub-unit
        cData = rescale(density);           % rescale color data to [0, 1]
        
        %alphaData = nthroot(cData, 3);      % create transparency data for scatter points
        %alphaData( alphaData<0.55 ) = 0;    % make low-density points transparent
        
        alphaData = log(1+cData);
        alphaData = alphaData / max(alphaData);
        %alphaData( alphaData<mean(alphaData) ) = 0;
        sizeData = 10 - log(numPoints);     % create size data, as reverse logrithmic of total number of data points
        sizeData = max(1, sizeData);        % control minimum size to be 1
        
        % Create Gaussian distributed point clouds
        allPoints = [];
        for m = 1:size(clusterCenters, 1)
            points = generateGaussianPoints(clusterCenters(m, :), clusterDiameter/4, round(numPoints));
            allPoints = [allPoints; points]; %#ok<AGROW>
        end
        % NPCpointCloud = pointCloud(allPoints(:,1:3), 'Intensity', allPoints(:,4));
        % %pointCloudPlot = scatter3(ax, allPoints(:,1), allPoints(:,2), allPoints(:,3), ...
        % %     20, [0.5 0.5 0.5], 'filled', 'Visible', 'off');
        % pcshow(NPCpointCloud, 'ColorSource', 'Intensity', 'MarkerSize', 1.0, 'BackgroundColor', [1 1 1]);
        % plotPtCloud = findobj('Tag', 'pcviewer');
        plotPtCloud = scatter3 (ax, allPoints(:,1), allPoints(:,2), allPoints(:,3), sizeData, ...
            'MarkerEdgeAlpha', 'flat', 'MarkerEdgeAlpha', 'flat', ...
            'MarkerFaceColor', 'flat', 'MarkerFaceAlpha', 'flat', ...
            'AlphaData', allPoints(:,4), 'CData', allPoints(:,4));
        plotPtCloud.Visible = 'off';

        % Create spherical surface
        [X, Y, Z] = sphere(100);  % Create a base sphere
        for k = 1 : size(clusterCenters, 1)
            Xs = clusterDiameter/2 * X + clusterCenters(k, 1);
            Ys = clusterDiameter/2 * Y + clusterCenters(k, 2);
            Zs = clusterDiameter/2 * Z + clusterCenters(k, 3);
            plotSurface{k} = surf(ax, Xs, Ys, Zs, 'FaceColor', [1.0, 0.75, 0.8], ... % uniform surface color: light pink
                'EdgeColor', 'none', 'FaceAlpha', 0.5, 'Visible', 'off');
        end
        
        % Create scatter plot of the raw NPC data
        plotNPCRaw = scatter3 (ax, loc_nm(:,1), loc_nm(:,2), loc_nm(:,3), sizeData, ...
            'MarkerEdgeAlpha', 'flat', 'MarkerEdgeAlpha', 'flat', ...
            'MarkerFaceColor', 'flat', 'MarkerFaceAlpha', 'flat', ...
            'AlphaData', alphaData, 'CData', cData);
        plotNPCRaw.Visible = 'on';
        
        % Add axis label, adjust view, and colormap
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        view(3);
        axis equal;
        colormap(ax, hot);

    end
end


function N = histcounts3 (x, y, z, binSize)
    loc = [x, y, z];
    size_map = [1 1 1];
    num_pixel_dimension = 1;
    bin_count_1d = 1;
    % loop through dimensions: X, Y, Z
    for dim = 1 : 3
        data = loc(:, dim); % localization data along current dimension
        if range(data) < 1 
            data = data * 1e9; % in case the input localization is with unit meter
        end
        % compute histogram edge
        edge = min(data) : binSize : max(data);   % edge of the current localization data
        % update size of the final rendered histogram map
        size_map(dim) = length(edge);
        % generate 1D array of (M) edges and (N) data, and also M '1' and N
        % '0' array, to compute the histogram bin counts, and the bin index
        % of input localization data
        cd = zeros(numel(data), 1);     % N by 1 data with 0
        ce = ones(size_map(dim), 1);     % M by 1 edge with 1
        ed = [ edge(:); data];          % edge and data vertically combined
        [~, edi] = sort(ed);            % sort combined edge, return index of sorted array corresponding to unsorted 'ed'
        ced=[ce; cd];                   % M times '1', and N times '0' vertically combined
        csum = cumsum(ced(edi));        % computing bin counts
        csum(edi) = csum;               % bin counts of the unsorted 'ed'
        bin_index_data = csum(ced==0);  % bin index of original coordinate data, identified by '0' value in ced
        %XI(XI<1) = nan;                % data cannot be assigned to any bin
        % update bin counts 1D array with the current axis bin counts
        bin_count_1d = bin_count_1d + (bin_index_data-1) * num_pixel_dimension;
        % update bin counts offset, as the total number of pixels in previous dimension
        num_pixel_dimension = num_pixel_dimension * size_map(dim);
    end
    bin_count_nd = histcounts( bin_count_1d, 1 : prod(size_map) ); % generate histogram counts for all bins of all dimensions
    N = [bin_count_nd, 0];
    N = reshape(N, size_map); % reshape the final bin counts into the N-D histogram
end

function points = generateGaussianPoints(center, sigma, numPoints)
    % Generate Gaussian-distributed points around the cluster center
    x = randn(numPoints, 1) * sigma + center(1);
    y = randn(numPoints, 1) * sigma + center(2);
    z = randn(numPoints, 1) * sigma + center(3);
    gaussValues = exp(-((x-center(1)).^2 + (y-center(2)).^2 + (z-center(3)).^2) / (2 * sigma^2));
    %probability = gaussValues / max(gaussValues);
    %mask = rand(numPoints, 1) < probability;
    points = [x, y, z, gaussValues];
end



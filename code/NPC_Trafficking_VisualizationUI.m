function NPC_Trafficking_VisualizationUI(npc_cluster_data_merged, track_data_aligned)

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
    subunitSize = mean( mean(range_trace_npc) );           % NPC 8-fold symmetry sub-unit size
    

    % parse tracks
    nTracks = length(track_data_aligned.track_ID);
    track_list = cell(nTracks, 1);
    for i = 1 : nTracks
        track_list{i} = string( track_data_aligned.track_ID(i) );
    end


    % Create placeholders for graphics objects
    plotNPCRaw = [];
    plotPtCloud = [];
    plotSurface = cell(16, 1);
    %plotTracks = cell(nTracks, 1);
    
    scatterTrack = [];
    splineTrack = [];
    plotTrackHead = [];
    loc_norm = [];
    nLoc = 100;

    % Parameters for the NPC and visualization
    %diameter = 100;
    interRingDistance = mean(height);
    clusterSigma = subunitSize;
    numPoints = 1e4;

    % Initial display of NPC as surface
    plotNPC(ax, loc_npc, mean(diameter), interRingDistance, clusterSigma, numPoints); % create NPC rendering of: raw data, point cloud, and surface
    plotTrack(1);
    %plotTrack(ax, track_data_aligned, selected_track);

    % UI components
    % First row of checkboxes
    uicontrol('Style', 'checkbox', 'String', 'Display NPC Raw Data', ...
        'Position', [220, 100, 140, 20], 'Value', 0, ...
        'Callback', @(src, evt) toggleNPCRawData(src));

    uicontrol('Style', 'checkbox', 'String', 'Display as Point Cloud', ...
        'Position', [400, 100, 140, 20], 'Value', 0, ...
        'Callback', @(src, evt) toggleNPCPointCloud(src));

    uicontrol('Style', 'checkbox', 'String', 'Display as Surface', ...
        'Position', [580, 100, 140, 20], 'Value', 1, ...
        'Callback', @(src, evt) toggleNPCSurface(src));

    % Second row: dropdown, text field, toggle button, slider
    uicontrol('Style', 'text', 'String', 'Track', 'FontWeight', 'bold',...
        'Position', [60, 60, 100, 20], 'BackgroundColor', 'white');
    
    uicontrol('Style', 'popupmenu', 'String', track_list, ...
        'Position', [150, 60, 60, 20], 'Callback', @(src, evt) trackSelection(src));

    %uicontrol('Style', 'edit', 'String', '100', ...
    %    'Position', [130, 60, 60, 20], 'Callback', @(src, evt) resizeTrack(src));

    playButton = uicontrol('Style', 'togglebutton', 'String', '▶', ...
        'Position', [220, 60, 30, 20], 'Callback', @(src, evt) playTracks(src));

    slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', 0, ...
        'Position', [260, 60, 500, 20], 'Callback', @(src, evt) adjustTimeSlider(src));


    function toggleNPCRawData(checkbox)
        if checkbox.Value
            if isempty(plotNPCRaw)
                plotNPCRaw = plot(ax, rand(100, 1) * diameter, rand(100, 1) * diameter, 'ko'); % Example data
            else
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
        delete( [scatterTrack, splineTrack] );
        

        loc_norm = track_data_aligned.loc_norm{idx_trk};
        %tim = txyz(:,1);
        nLoc = size(loc_norm, 1);
        
        points = fnplt( cscvn( loc_norm' ) );

        scatterTrack = scatter3(ax, loc_norm(:,1), loc_norm(:,2), loc_norm(:,3), 'b.')';
        splineTrack = plot3(ax, points(1, :), points(2, :), points(3, :), '-m');
        %app.highlight_head = plot3(app.ax_scatter, app.xyz_trace(1,1), app.xyz_trace(1,2), app.xyz_trace(1,3), '-pentagram');
        
        if ~isempty(plotTrackHead)
            plotTrackHead.XData = loc_norm(1, 1);
            plotTrackHead.YData = loc_norm(1, 2);
            plotTrackHead.ZData = loc_norm(1, 3);
            plotTrackHead.Visible = 'off';
        end

        %globalVar.gui_result.highlight_head = plot3(globalVar.gui_result.ax1, points(1, end), points(2, end), '-pentagram');
    end


    function playTracks(toggleButton)
        if toggleButton.Value
            toggleButton.String = '⏸'; % Change to pause symbol
            % Implement playing logic here
            %disp('Playing tracks. Implementation details pending...');
        else
            toggleButton.String = '▶'; % Change to play symbol
        end
        
        if isempty(loc_norm)
            return;
        end
        %nLoc = size(loc_norm, 1);

        while slider.Value <= 0.99 % auto-play the time slider to the right
            if ~playButton.Value %|| count>maxCount
                break;
            end

            slider.Value = slider.Value + 0.01;
            plotHead(slider.Value);
            
            drawnow;
            %count = count + 1;
        end



    end

    function adjustTimeSlider(slider)
        % Use the slider value to adjust the animation timing
        %disp(['Time slider adjusted to: ', num2str(slider.Value)]);
        plotHead(slider.Value)
    end
    
    function plotHead (percentage)
        if isempty(loc_norm)
            return;
        end
        %disp(percentage);
        %nLoc = size(loc_norm, 1);
        idx = round( percentage * nLoc );
        idx = max (1, idx);
        idx = min( idx, nLoc);

        if isempty(plotTrackHead)
            plotTrackHead = plot3(ax, loc_norm(idx, 1), loc_norm(idx, 2), loc_norm(idx, 3),...
                'Marker', 'pentagram', 'MarkerSize', 12, 'MarkerEdgeColor', 'yellow', 'MarkerFaceColor', 'yellow');
        else
            plotTrackHead.Visible = 'on';
            plotTrackHead.XData = loc_norm(idx, 1);
            plotTrackHead.YData = loc_norm(idx, 2);
            plotTrackHead.ZData = loc_norm(idx, 3);
        end
    end


    function plotNPC(ax, loc, diameter, interRingDistance, clusterSigma, numPoints)        
        % Plot the NPC as both point cloud and surface, controlling visibility via the UI
        plotNPCRaw = [];
        plotPtCloud = [];
        plotSurface = cell(16, 1);

        % Define colors
        renderColor = [1.0, 0.75, 0.8];  % light pink for spheres

        % Plot Spheres for NPC
        numSubunitPerRing = 8;
        angleIncrement = 360 / numSubunitPerRing;
        clusterCenters = zeros(numSubunitPerRing * 2, 3);

        for n = 1 : numSubunitPerRing
            angleRad = deg2rad(angleIncrement * (n - 1) + 22.5);
            clusterCenters(n, :) = [diameter / 2 * cos(angleRad), diameter / 2 * sin(angleRad), -interRingDistance/2];
            clusterCenters(n + numSubunitPerRing, :) = ...
                [diameter / 2 * cos(angleRad), diameter / 2 * sin(angleRad), interRingDistance/2];
        end

        % Plot point cloud
        allPoints = [];
        for m = 1:size(clusterCenters, 1)
            points = generateGaussianPoints(clusterCenters(m, :), clusterSigma/2, numPoints);
            allPoints = [allPoints; points]; %#ok<AGROW>
        end
        NPCpointCloud = pointCloud(allPoints(:,1:3), 'Intensity', 1e2*allPoints(:,4));
        %pointCloudPlot = scatter3(ax, allPoints(:,1), allPoints(:,2), allPoints(:,3), ...
        %     20, [0.5 0.5 0.5], 'filled', 'Visible', 'off');
        axes_pcshow = pcshow(NPCpointCloud, 'ColorSource', 'Intensity', 'MarkerSize', 0.55, 'BackgroundColor', [1 1 1]);
        plotPtCloud = findobj('Tag', 'pcviewer');
        plotPtCloud.Visible = 'off';
        colormap(flipud(hot));
        %colormap("hot");
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        %title('Nuclear Pore Complex with Gaussian Point Cloud');
        axis equal;
        view(3);

        % Plot spherical surface
        [X, Y, Z] = sphere(100);  % Create a base sphere
        
        %surfacePlot = cell(numSubunitPerRing * 2, 1);
        for k = 1 : size(clusterCenters, 1)
            Xs = clusterSigma * X + clusterCenters(k, 1);
            Ys = clusterSigma * Y + clusterCenters(k, 2);
            Zs = clusterSigma * Z + clusterCenters(k, 3);
            plotSurface{k} = surf(ax, Xs, Ys, Zs, 'FaceColor', renderColor, ...
                'EdgeColor', 'none', 'FaceAlpha', 0.5, 'Visible', 'on');
        end

        plotNPCRaw = scatter3 (ax, loc(:,1), loc(:,2), loc(:,3), 'ro',...
            'SizeData', 5.5,'MarkerEdgeAlpha', 0.1, 'MarkerFaceColor', renderColor, 'MarkerFaceAlpha', 0.55);
        plotNPCRaw.Visible = 'off';
        
        %dark red [.35, 0, 0]
        

    end
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



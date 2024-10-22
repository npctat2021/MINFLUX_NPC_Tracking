function rotate_cluster (cluster_data, angel_bin_size, angle_to_base, showFitting, save_mode)
    
    if nargin < 5
        save_mode = 'overwrite';
    end
    if nargin < 4
        showFitting = false;
    end
    if nargin < 3
        angle_to_base = 0;
    end
    if nargin < 2
        angel_bin_size = 5;     % default phase angle bin size is 5 degree
    end

    
    global fig tg; %#ok<GVMIS>
    num_cluster = length(cluster_data);

    progress = 0;
    fprintf(1,'       progress: %3d%%\n', progress);
    for i = 1 : 1:num_cluster
        % report progress
        progress = ( 100*(i/num_cluster) );
        fprintf(1,'\b\b\b\b%3.0f%%', progress); % Deleting 4 characters (The three digits and the % symbol)

        % get current cluster data
        cluster = cluster_data(i);
        % get loclization coordinates of XY and XY center
        loc_nm = cluster.loc_nm;
        %nLoc = size(loc_nm, 1);
        center = cluster.center;
        x = loc_nm(:, 1);
        y = loc_nm(:, 2);
        % translate origin to the center of this cluster
        xnorm = x - center(1);
        ynorm = y - center(2);
        
        % STEP 1
        % compute rotation angle in XY plane in the range between
        % [-180°, 180°] of each localization
        rot = atan2d(ynorm, xnorm);
        
        % STEP 2
        % mapping rotation angle to the range of [0°, 45°] to account for 8-fold symmetry of the NPC sub-unit
        rot_45 = mod(rot, 45);
        
        % STEP 3 - modified as of 2024.09.17
        % fit a full cycle of sinusoidal to the histogram of the 45° angle
        % mapping histogram, to estimate the final rotation angle in XY plane
        % re-scale back to 0 - 360° for full cycle sinusoidal fit. Not to be confused with the original rotation angle.
        rot_360 = rot_45 * 8;
        % phase angle histogram bin size
        edges = 0 : angel_bin_size*8 : 360;
        binCounts = histcounts(rot_360, edges, 'Normalization','probability'); % bin count size is length(angleRes) - 1
        binCenters = movmean(edges(2:end), 2);
       
        % smooth the histogram with RMS filter, window size = 9 bins
        %windowSize = round( angleScaleFactor );
        %binCount_RMS = sqrt(movmean(binCount_rescale .^ 2, windowSize));
        
        % locate the max bin count, as the phase angle of majority of localization, as our initial guess for the sine fit
        [maxCount, maxIndex] = max(binCounts);
        intialAngleGuess = binCenters(maxIndex);
        % define the sine function model
        %sineModel = @(p, x) (1/360) * cosd( (x - p) ) + (1/360);
        Amplitude = maxCount / 2;
        sineModel = @(p, x) Amplitude * cosd( (x - p) ) + Amplitude;
        % perform the fitting using nonlinear least squares
        options = optimset('Display','off');
        sineParams = lsqcurvefit(sineModel, intialAngleGuess, binCenters, binCounts, [], [], options);
        
        % map phase angle back to [0, 45] degree from fitted sine function
        phaseShiftDegrees = sineParams(1) / 8;
        
        if (showFitting)
            if ~ishandle(903)
                fig = figure(903);
                fig.NumberTitle = 'off';
                fig.Name = 'Sinusoidal fitting of rotation angle of cluster';
                tg = uitabgroup(fig);
            else
                fig = findobj( 'Type', 'Figure', 'Number', 903);
            end
            tab = uitab(tg, 'title', ""+i);
            ax = axes('Parent', tab);
            hold on;
            %histogram(rot_360, edges, 'Normalization', 'probability');
            %plot(XdataDegree, binCount_RMS, 'g', 'LineWidth', 2);
            plot(binCenters/8, binCounts, 'rpentagram', 'LineStyle', 'none', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'HandleVisibility','off');
            % Overlay the fitted sine function
            XdataDegree = 0.5 : 1 : 359.5; % use 1 degree resolution for a complete sine wave plot
            fittedCurve = sineModel(sineParams, XdataDegree);
            plot(XdataDegree/8, fittedCurve, 'b-', 'LineWidth', 1, 'HandleVisibility','off');
            xline(phaseShiftDegrees, '--b', 'LineWidth', 2);
            %title('Histogram with Fitted Sine Function');
            %legend('normalized angle histogram', 'RMS smoothed bin counts', 'fitted sine curve', strcat("phase angle = ", num2str(phaseShiftDegrees*8), "°"), 'Location', 'Best');
            legend(strcat("phase angle = ", num2str(phaseShiftDegrees), "°"), 'Location', 'Best');
            grid on;
            xlim([0, 45]); xticks(0:5:45);
            set(ax,'FontSize', 12)
            xlabel('angle (degree)', 'FontSize', 20);
            ylabel('normalized frequency', 'FontSize', 20);
        end
        
        cluster_data(i).rotation = mod( phaseShiftDegrees + angle_to_base, 45) ;

    end
    fprintf('\n'); % To go to a new line after reaching 100% progress

    switch save_mode
        case 'overwrite'
            assignin('base', 'cluster_data', cluster_data);
        case 'new'
            assignin('base', 'cluster_data_rotated', cluster_data);
        otherwise
            % do nothing
    end

end
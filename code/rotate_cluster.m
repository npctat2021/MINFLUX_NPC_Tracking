function rotate_cluster (cluster_data, showFitting, save_mode)
    
    if nargin < 3
        save_mode = 'overwrite';
    end
    if nargin < 2
        showFitting = false;
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
        rot = atan2d(xnorm, ynorm);
    
        % STEP 2
        % mapping rotation angle to the range of [0°, 45°] to account for
        % 8-fold symmetry of the NPC sub-unit
        rot_45 = mod(rot, 45);
        
        % STEP 3 - modified as of 2024.09.17
        % fit a full cycle of sinusoidal to the histogram of the 45° angle
        % mapping histogram, to estimate the final rotation angle in XY plane
        rot_angle_360 = rot_45 * 8;   % re-scale back to 0 - 360° for full cycle sinusoidal fit !!! not to be confused with the original rotation angle !!!
        edges = 0 : 1 : 360;                % use 1 degree precision
        binCount_360 = histcounts(rot_angle_360, edges, 'Normalization','probability');
        % smooth the histogram with RMS filter, window size = 9 bins
        binCount_RMS = sqrt(movmean(binCount_360 .^ 2, 9));

        [~, maxIndex] = max(binCount_RMS);
        % Define x scale to cover [0, 360] degrees for a complete cycle
        XdataDegree = 1 : 1 : 360;
        % Define the sine function model
        sineModel = @(sineFunc, x) 1/360 * sind( x + sineFunc(1)) + 1 / 360;
        % Perform the fitting using nonlinear least squares
        options = optimset('Display','off');
        sineParams = lsqcurvefit(sineModel, maxIndex - 90, edges(2:end), binCount_RMS, [], [], options);
    
        % extract phase shift degree from fitted sine function
        phaseShiftDegrees = mod( 90 - sineParams(1), 360 ) / 8;


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
            histogram(rot_45, edges/8, 'Normalization', 'probability');
            plot(XdataDegree/8, binCount_RMS, 'g', 'LineWidth', 2);
            % Overlay the fitted sine function
            fittedCurve = sineModel(sineParams, XdataDegree);
            plot(XdataDegree/8, fittedCurve, 'r-', 'LineWidth', 2);
            xline(phaseShiftDegrees, '--r', 'LineWidth', 2);
            %title('Histogram with Fitted Sine Function');
            legend('normalized angle histogram', 'RMS smoothed bin counts', 'fitted sine curve', strcat("phase angle = ", num2str(phaseShiftDegrees), "°"), 'Location', 'Best');
            grid on;
            xlim([0, 45]);
            set(ax,'FontSize', 12)
            xlabel('angle (degree)','FontSize',20);
            ylabel('normalized frequency','FontSize',20);
        end
        
        cluster_data(i).rotation = 45 - phaseShiftDegrees;

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
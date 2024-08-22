function pore_rotation_MINFLUX (cluster_data, showFitting, save_mode)
    
    if nargin < 3
        save_mode = 'overwrite';
    end
    if nargin < 2
        showFitting = false;
    end
    
    global fig tg;

    num_cluster = length(cluster_data);


    for i = 1 : 1:num_cluster
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
        % mapping localizations to [-90° 90°] range in the X-Y plane (mirror along Y axis)
        rot_90 = atand( xnorm ./ ynorm );
    
        % STEP 2
        % mapping localizations to [-90° 90°] range in the X-Y plane (mirror along Y axis)
        rot_45 = mod(rot_90 + 90, 45);

        % STEP 3
        % create a angle distribution histogram in the range of [0° 45°] with bin size of 5°
        [phase_norm, edges] = histcounts(rot_45, 9, 'Normalization','probability');
        phase_norm = phase_norm';
        bin_center = (edges(1:end-1) + 2.5)';

        % STEP 4
        % fitting angle distribution to a sinusoidal function to determine
        % the rotation angle (in XY plane) of the cluster
        func = inline('9^(-1)+20.6^(-1)*cosd(8*(x-8.4-p))','p','x'); % HERE!!! 
        theo = 0 : 0.1 : 45;
        angle =lsqcurvefit( func, 10, bin_center, phase_norm);
        if angle < 0
            angle = angle + 45;
        end
        
        
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
            phase = func(angle, theo);
            plot(ax, bin_center, phase_norm,'ro', theo, phase, 'b');
            set(ax,'FontSize', 12)
            xlabel('angle (degree)','FontSize',20);
            ylabel('frequency','FontSize',20);
        end
        
        cluster_data(i).rotation = angle;

    end

    switch save_mode
        case 'overwrite'
            assignin('base', 'cluster_data', cluster_data);
        case 'new'
            assignin('base', 'cluster_data_sineFit', cluster_data);
        otherwise
            % do nothing
    end

end
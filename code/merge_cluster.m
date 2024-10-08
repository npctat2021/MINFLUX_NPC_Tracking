function merge_cluster (cluster_data, showResult, save_mode)
    
    if nargin < 3
        save_mode = 'overwrite';
    end
    if nargin < 2
        showResult = false;
    end

    num_cluster = length(cluster_data);
    
    progress = 0;
    fprintf(1,'       progress: %3d%%\n', progress);
    for i = 1 : 1:num_cluster
        % report progress
        progress = ( 100*(i/num_cluster) );
        fprintf(1,'\b\b\b\b%3.0f%%', progress); % Deleting 4 characters (The three digits and the % symbol)


        cluster = cluster_data(i);
        loc_nm = cluster.loc_nm;
        % translate origin to the center of this cluster
        loc_norm = loc_nm - cluster.center;
        % rotate around the center by the angle(+22.5°) computed from previous sinusoidal fitting steps
        rot_rad = deg2rad( cluster.rotation + 22.5 );
        rotation_matrix = [ cos(rot_rad), -sin(rot_rad) ;
                            sin(rot_rad),  cos(rot_rad) ];
        
        loc_norm(:, 1:2) = loc_norm(:, 1:2) * rotation_matrix;

        cluster_data(i).loc_norm = loc_norm;

    end
    fprintf('\n'); % To go to a new line after reaching 100% progress

    assignin('base', 'cluster_data', cluster_data);

    switch save_mode
        case 'overwrite'
            assignin('base', 'cluster_data', cluster_data);
        case 'new'
            assignin('base', 'cluster_data_merged', cluster_data);
        otherwise
            % do nothing
    end
    
    % save tsv to txt file pore_merged.txt
    tid = vertcat(cluster_data.tid);
    tim = vertcat(cluster_data.tim);
    loc_norm = vertcat(cluster_data.loc_norm);
    pore_merged = [tid tim loc_norm];

    if (showResult)
        if ~ishandle(904)
            fig = figure(904);
            fig.NumberTitle = 'off';
            fig.Name = 'scatter plot of merged cluster';
        else
            fig = findobj( 'Type', 'Figure', 'Number', 904);
        end
        

        x = loc_norm(:, 1); y = loc_norm(:, 2); z = loc_norm(:, 3);
        densityMap_xy = renderNPC2D ([x, y]);
        densityMap_xz = renderNPC2D ([x, z]);

        img_xy = imgaussfilt(densityMap_xy, 5);
        img_xz = imgaussfilt(densityMap_xz, 5);
        max_xy = max(max(img_xy));
        max_xz = max(max(img_xz));

        ax1 = subplot(1,2,1, 'Parent', fig);
        imshow(img_xy, 'Parent', ax1);
        colormap(ax1, 'hot');
        clim(ax1, [0, max_xy]);
        title("X-Y view");

        ax2 = subplot(1,2,2, 'Parent', fig);
        imshow(flipud(img_xz'), 'Parent', ax2);
        colormap(ax2, 'hot');
        clim(ax2, [0, max_xz]);
        title("X-Z view");


        % alphaLevel = 3e3 / length(loc_norm);
        % alphaLevel = min(0.5, alphaLevel);
        % 
        % scatter(ax1,...
        %     loc_norm(:,1), loc_norm(:,2), 'ro',...
        %     'SizeData', 0.3,'MarkerEdgeAlpha', alphaLevel, 'MarkerFaceColor', [.55, 0, 0], 'MarkerFaceAlpha', alphaLevel);
        % xlabel("x (nm)"); ylabel("y (nm)"); axis equal; 
        % title("X-Y view");
        % ax2 = subplot(1,2,2, 'Parent', fig);
        % 
        % scatter(ax2,...
        %     loc_norm(:,1), loc_norm(:,3), 'ro',...
        %     'SizeData', 0.3,'MarkerEdgeAlpha', alphaLevel, 'MarkerFaceColor', [.55, 0, 0], 'MarkerFaceAlpha', alphaLevel);
        % xlabel("x (nm)"); ylabel("z (nm)"); axis equal; 
        % title("X-Z view");

    end
    


    save([pwd, '/',  'pore_rotated_merged.txt'],'-ascii','-TABS','pore_merged');

end
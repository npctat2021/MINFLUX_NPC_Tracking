function merge_cluster (cluster_data, showResult, save_mode)
    
    if nargin < 3
        save_mode = 'overwrite';
    end
    if nargin < 2
        showResult = false;
    end

    num_cluster = length(cluster_data);
    
    for i = 1 : 1:num_cluster
        cluster = cluster_data(i);
        loc_nm = cluster.loc_nm;
        % translate origin to the center of this cluster
        loc_norm = loc_nm - cluster.center;
        % rotate around the center by the angle(+45°) computed from previous sinusoidal fitting steps
        rot_rad = deg2rad( cluster.rotation + 45 );
        rotation_matrix = [ cos(rot_rad), -sin(rot_rad) ;
                            sin(rot_rad),  cos(rot_rad) ];
        
        loc_norm(:, 1:2) = loc_norm(:, 1:2) * rotation_matrix;

        cluster_data(i).loc_norm = loc_norm;

    end
    

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
        ax1 = subplot(1,2,1, 'Parent', fig);
        scatter(ax1,...
            loc_norm(:,1), loc_norm(:,2), 'ro',...
            'SizeData', 5.5,'MarkerEdgeAlpha', 0.1, 'MarkerFaceColor', [.55, 0, 0], 'MarkerFaceAlpha', 0.15);
        xlabel("x (nm)"); ylabel("y (nm)"); axis equal; 
        title("X-Y view");
        ax2 = subplot(1,2,2, 'Parent', fig);
        scatter(ax2,...
            loc_norm(:,1), loc_norm(:,3), 'ro',...
            'SizeData', 5.5,'MarkerEdgeAlpha', 0.1, 'MarkerFaceColor', [.55, 0, 0], 'MarkerFaceAlpha', 0.15);
        xlabel("x (nm)"); ylabel("z (nm)"); axis equal; 
        title("X-Z view");
    end
    


    save([pwd, '/',  'pore_rotated_merged.txt'],'-ascii','-TABS','pore_merged');

end
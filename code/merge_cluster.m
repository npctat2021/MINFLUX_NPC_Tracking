function merge_cluster (cluster_data, showResult, save_mode)
    % merge_cluster normalize and merges localizations from all cluster data to form a NPC reconstruction.
    %
    % Inputs:
    %   cluster_data (struct array) - Structure array containing cluster data that has been phase angle computed.
    %
    %   showResult (logical) - Flag indicating whether to visually display the result 
    %                         of the merged clusters in a plot (true) or not (false).
    %   save_mode (string) - Specifies how to save the merged results; options include:
    %     'over_write' - Overwrites existing variable with the same name 'cluster_data'.
    %     'new' - Saves fitting results to a new varaible with name 'cluster_data_merged' to avoid overwriting.
    %
    % Outputs: depending on the save_mode
    %   cluster_data (struct array) - same as input, append the following field from sinusoidal fitting result:
    %       - loc_norm: normalized and rotated localizations for the given cluster
    %
    % Example:
    %   results = merge_cluster(cluster_data, true, 'new');
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04

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
    pore_merged = [tid tim*1e3 loc_norm]; % time in millisecond, loc in nanometer

    if (showResult)
        if ~ishandle(904)
            fig = figure(904);
            fig.NumberTitle = 'off';
            fig.Name = '2D rendering of merged cluster';
        else
            fig = findobj( 'Type', 'Figure', 'Number', 904);
        end

        x = loc_norm(:, 1); y = loc_norm(:, 2); z = loc_norm(:, 3);
        densityMap_xy = render_NPC_2D ([x, y]);
        densityMap_xz = render_NPC_2D ([x, z]);

        img_xy = imgaussfilt(densityMap_xy, 5);
        img_xz = imgaussfilt(densityMap_xz, 5);

        img_size = max([size(img_xy), size(img_xz)]);
        pad_x = ceil( (img_size - size(img_xy, 1)) / 2 );
        pad_y = ceil( (img_size - size(img_xy, 2)) / 2 );
        pad_z = ceil( (img_size - size(img_xz, 2)) / 2 );
        img_xy = padarray(img_xy, [pad_x, pad_y]);
        img_xz = padarray(img_xz, [pad_x, pad_z]);

        max_xy = mean(img_xy(:)) + 3*std(img_xy(:), 1);
        max_xy = max( max_xy, max(img_xy(:)) );
        max_xz = mean(img_xz(:)) + 3*std(img_xz(:), 1);
        max_xz = max( max_xz, max(img_xz(:)) );
        
        ax1 = subplot(1,2,1, 'Parent', fig);
        imshow(flipud(img_xy'), 'Parent', ax1, 'InitialMagnification', 100);
        colormap(ax1, 'hot');
        clim(ax1, [0, max_xy]);
        title("X-Y view");

        ax2 = subplot(1,2,2, 'Parent', fig);
        imshow(flipud(img_xz'), 'Parent', ax2, 'InitialMagnification', 100);
        colormap(ax2, 'hot');
        clim(ax2, [0, max_xz]);
        title("X-Z view");
    end
    
    % save the merged pore data as N by 5 array to text file
    save([pwd, '/',  'pore_rotated_merged.txt'],'-ascii','-TABS','pore_merged');

end
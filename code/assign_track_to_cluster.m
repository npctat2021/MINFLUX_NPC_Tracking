function result = assign_track_to_cluster (track_data, npc_cluster_data)
    % assign_track_to_cluster Assigns tracking data to specified NPC clusters.
    %
    % Inputs:
    %   track_data (struct array) - Structure array containing tracking information, 
    %                                including coordinates and timestamps of tracked entities.
    %   npc_cluster_data (struct array) - Structure array containing NPC cluster data, 
    %                                      which includes fields such as cluster coordinates 
    %                                      and identifiers for association with tracking data.
    %
    % Outputs:
    %   result (struct array) - same as input track_data, append the following field from alignment:
    %       - cluster_ID: the cluster ID of the associated NPC cluster to the Cargo data
    %       - loc_norm: transformed localizations of the Cargo according to its identified NPC cluster
    %
    % Example:
    %   track_data = assign_track_to_cluster (track_data, cluster_data);
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04    
    
    result = track_data;

    if isempty(track_data)
        return;
    end

    cluster_ID = vertcat(npc_cluster_data.cluster_ID);
    cluster_center = vertcat(npc_cluster_data.center);
    cluster_rotation = vertcat(npc_cluster_data.rotation);
    
    track_ID = vertcat(track_data.trace_ID);
    track_center = cellfun(@(x) mean(x), track_data.loc_nm, 'UniformOutput', false);
    track_center = cell2mat(track_center);
    nTracks = size(track_center, 1);
    track_length = cellfun(@(x) size(x, 1), track_data.trace_txyz);

    dist2 = pdist2(cluster_center(:, 1:2), track_center(:, 1:2));
    [xyDiff, I] = min(dist2);
    
    z_maxDist = 100; % half thickness of the pore
    xy_maxDist = 100; % radius+uncertainty
    zDiff = (track_center(:, 3) - cluster_center(I, 3))';
    
    exclude = xyDiff > xy_maxDist | zDiff > z_maxDist;

    track_cluster_ID = cluster_ID(I);
    track_cluster_ID(exclude, :) = -1;
    
    % prepare result track_data
    result.cluster_ID = track_cluster_ID;
    
    loc_norm = cell(nTracks, 1);
    tid_array = track_data.data_array(:,1);

    for i = 1 : nTracks
        if (track_cluster_ID(i) == -1) 
            continue;
        end
        tid = track_ID(i);
        center_norm = cluster_center( I(i), : );
        rot = cluster_rotation( I(i) );
        

        loci = track_data.loc_nm{i} - center_norm;

        % rotate around the center by the angle(+45°) computed from previous sinusoidal fitting steps
        rot_rad = deg2rad( rot + 22.5 );
        rotation_matrix = [ cos(rot_rad), -sin(rot_rad) ;
                            sin(rot_rad),  cos(rot_rad) ];
        
        loci(:, 1:2) = loci(:, 1:2) * rotation_matrix;

        loc_norm{i} = loci;
        result.data_array(tid_array==tid, 3:5) = loci;


    end
   
    result.loc_norm = loc_norm;
    
    % filter data array
    exclude_array = repelem(exclude, track_length);
    result.data_array(exclude_array, :) = [];
    assignin('base', 'track_data', result);
    data_array = result.data_array;
    save( fullfile(pwd, 'tracks_aligned_filtered.txt'), '-ascii', '-TABS', 'data_array');

end
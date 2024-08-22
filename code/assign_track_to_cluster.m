function result = assign_track_to_cluster (track_data, npc_cluster_data)
    
    result = track_data;
    
    cluster_center = vertcat(npc_cluster_data.center);
    cluster_ID = vertcat(npc_cluster_data.ClusterID);
    

    track_center = cellfun(@(x) mean(x), track_data.loc_nm, 'UniformOutput', false);
    track_center = cell2mat(track_center);
    nTracks = size(track_center, 1);

    dist2 = pdist2(cluster_center(:, 1:2), track_center(:, 1:2));
    [M, I] = min(dist2);
    
    maxDist = 100;
    
    track_cluster_ID = cluster_ID(I);
    track_cluster_ID(M>maxDist, :) = -1;
    result.cluster_ID = track_cluster_ID;
    
    loc_norm = cell(nTracks, 1);
    for i = 1 : nTracks
        if (track_cluster_ID(i) == -1) 
            continue;
        end
        center_norm = cluster_center( I(i), : );
        loc_norm{i} = track_data.loc_nm{i} - center_norm;
    end
    
    result.loc_norm = loc_norm;

    assignin('base', 'track_data', result);

end
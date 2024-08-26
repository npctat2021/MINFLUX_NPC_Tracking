function result = align_track_to_NPC (file_track , beads_track, beads_npc, RIMF)
    
    % referactive index mismatch factor
    if nargin < 4
        RIMF = 0.668;
    end
    

    % load track data, beads data from both NPC and Track experiment
    data_array_track = load(file_track);
    %data_array_npc = load(file_npc);
    bead_data_npc = load(beads_npc);
    bead_data_trk = load(beads_track);
    
    % get X, Y coordinates from the beads data
    base_points = bead_data_npc(:, 1:2); 
    input_points = bead_data_trk(:, 1:2);
    
    % compute translational transform of X, and Y axis
    fit_arg_x = polyfit(base_points(:,1), input_points(:,1), 1); % 1st order polynomial fit (y=a1*x+a2) of top channel x-pixels (x) & bottom channel x-pixels (y), output is [a1, a2] 
    fit_arg_y = polyfit(base_points(:,2), input_points(:,2), 1); % 1st order polynomial fit (y=b1*x+b2) of top channel y-pixels (x) & bottom channel y-pixels (y), output is [b1, b2]
    map_func = inline('fit_arg(1)*xdata(:,1)+fit_arg(2)*xdata(:,2)+fit_arg(3)','fit_arg','xdata'); % defining a 1st order polynomial function
    xdata=base_points;
    fit_arg=[fit_arg_x(1) 0 fit_arg_x(2)]; % fit_arg_x(1) is a1, fit_arg_x(2) is b1 
    options=optimset('lsqcurvefit');
    options=optimset(options,'display','off');
    px = lsqcurvefit(map_func,fit_arg,xdata,input_points(:,1),[],[],options); % expressing bottom channel x-pixel in terms of top channel x-pixel and y-pixel, px=[px1,px2,px3]
    fit_arg = [0 fit_arg_y(1) fit_arg_y(2)];
    py = lsqcurvefit(map_func,fit_arg,xdata,input_points(:,2),[],[],options); % expressing bottom channel x-pixel in terms of top channel x-pixel and y-pixel, py=[py1,py2,py3]
    %pxy=[px', py']; % this is the alignment matrix 
    pz = mean(bead_data_npc(:,3) - mean(bead_data_trk(:,3)));

    % plot alignment figure
    figure("Name", "Track data and NPC data alignment with beads" );
    hold on;
    plot3(bead_data_npc(:,1), bead_data_npc(:,2), bead_data_npc(:,3), 'r*', 'DisplayName', 'beads NPC channel');
    plot3(bead_data_trk(:,1), bead_data_trk(:,2), bead_data_trk(:,3), 'b*',  'DisplayName', 'beads Track channel');
    plot3(px(1)*bead_data_trk(:,1)+px(2)*bead_data_trk(:,2)+px(3), py(1)*bead_data_trk(:,1)+py(2)*bead_data_trk(:,2)+py(3), bead_data_trk(:,3)+pz, 'ro', 'DisplayName', 'beads Track channel aligned');
    hold off;
    legend;
    saveas(gcf, [pwd, '/', 'track_to_NPC_alignment.fig']);
    
    tid = data_array_track(:,1);
    tim = data_array_track(:,2);
    loc = data_array_track(:, 3:5);
    track_ID = unique(tid);

    % prepare result
    result = struct();
    result.track_ID = track_ID;
    N_tracks = size(track_ID, 1);
    track_length = arrayfun(@(x) sum(tid==x), track_ID);
    result.time_stamp = cell(N_tracks, 1);
    result.loc_nm = cell(N_tracks, 1);
    result.track_txyz = cell(N_tracks, 1);
    
    for i = 1 : N_tracks
        selected_data = tid==track_ID(i);
        result.time_stamp{i} = tim(selected_data);
        loc_nm = loc(selected_data, :) * 1e9;
        loc_nm(:, 3) = loc_nm(:, 3) * RIMF;
        
        x_calib = loc_nm(:,1).* px(1) + loc_nm(:,2).* px(2) + px(3);
        y_calib = loc_nm(:,1).* py(1) + loc_nm(:,2).* py(2) + py(3);
        z_calib = loc_nm(:,3) + pz;
        

        result.loc_nm{i} = horzcat(x_calib, y_calib, z_calib);
        result.track_txyz{i} = [result.time_stamp{i} result.loc_nm{i}];
    end
    
    


    % combine ID, time, x, y, z into one data array
    data_array(:, 1) = double (repelem(result.track_ID, track_length));
    data_array(:, 2:5) = vertcat(result.track_txyz{:});
    result.data_array = data_array;

    assignin('base', 'track_data', result);
    %save([pwd, '/',  'tracks_aligned.txt'], '-ascii', '-TABS', 'data_array');

end
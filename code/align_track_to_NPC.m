function result = align_track_to_NPC (file_track , beads_track, beads_npc, RIMF)
    
    % referactive index mismatch factor
    if nargin < 4
        RIMF = 0.67;
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
    fit_arg_x = polyfit(input_points(:,1), base_points(:,1), 1); % 1st order polynomial fit (y=a1*x+a2) of top channel x-pixels (x) & bottom channel x-pixels (y), output is [a1, a2]
    fit_arg_y = polyfit(input_points(:,2), base_points(:,2), 1); % 1st order polynomial fit (y=b1*x+b2) of top channel y-pixels (x) & bottom channel y-pixels (y), output is [b1, b2]
    map_func = inline('fit_arg(1)*xdata(:,1)+fit_arg(2)*xdata(:,2)+fit_arg(3)','fit_arg','xdata'); % defining a 1st order polynomial function
    xdata=input_points;
    fit_arg=[fit_arg_x(1) 0 fit_arg_x(2)]; % fit_arg_x(1) is a1, fit_arg_x(2) is b1
    options=optimset('lsqcurvefit');
    options=optimset(options,'display','off');
    px = lsqcurvefit(map_func,fit_arg,xdata,base_points(:,1),[],[],options); % expressing bottom channel x-pixel in terms of top channel x-pixel and y-pixel, px=[px1,px2,px3]
    fit_arg = [0 fit_arg_y(1) fit_arg_y(2)];
    py = lsqcurvefit(map_func,fit_arg,xdata,base_points(:,2),[],[],options); % expressing bottom channel x-pixel in terms of top channel x-pixel and y-pixel, py=[py1,py2,py3]
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
    trace_ID = unique(tid);

    % prepare result
    result = struct();
    result.trace_ID = trace_ID;
    N_traces = size(trace_ID, 1);
    trace_length = arrayfun(@(x) sum(tid==x), trace_ID);
    result.tim_ms = cell(N_traces, 1);
    result.loc_nm = cell(N_traces, 1);
    result.trace_txyz = cell(N_traces, 1);
    
    for i = 1 : N_traces
        selected_data = tid==trace_ID(i);
        tim_trace = tim(selected_data);
        loc_trace = loc(selected_data, :);

        result.tim_ms{i} = tim_trace * 1e3;
        loc_nm = loc_trace * 1e9;
        loc_nm(:, 3) = loc_nm(:, 3) * RIMF;
        
        x_calib = loc_nm(:,1).* px(1) + loc_nm(:,2).* px(2) + px(3);
        y_calib = loc_nm(:,1).* py(1) + loc_nm(:,2).* py(2) + py(3);
        z_calib = loc_nm(:,3) + pz;
        
        result.loc_nm{i} = horzcat(x_calib, y_calib, z_calib);
        result.trace_txyz{i} = [tim_trace result.loc_nm{i}/1e9];
    end
    
    

    % combine ID, time, x, y, z into one data array
    data_array(:, 1) = double (repelem(result.trace_ID, trace_length));
    data_array(:, 2:5) = vertcat(result.trace_txyz{:});
    result.data_array = data_array;

    assignin('base', 'track_data', result);
    %save([pwd, '/',  'tracks_aligned.txt'], '-ascii', '-TABS', 'data_array');

end
function filter_result = load_minflux_raw_data (minfluxRawDataPath, cfr_range, efo_range, dcr_range, length_range, do_trace_mean, RIMF)
    % modified on 2024.07.12
    % <Ziqiang.Hunag@embl.de>
    % Select MINFLUX data and select EFO, CFR, DCR, and track length
    % Write "Yes" or "Y" in the 'filter with tracke-wise mean value' 
    % yield the Track_data_array, Track_ID, Time, Coordinates.
    % Enter this command  in command window [length = cellfun(@(x) size(x, 1), ans.tracks); track_data_array = double (repelem(ans.track_ID, length));track_data_array(:, 2:5) = vertcat(ans.tracks{:});]
    % Get the 'Track_data_array' in the workspace to extract 'Track_ID, Time, Coordinates (x, y and z)' .
    
    filter_result = [];
    %% load data file
    if nargin < 1
        [filename, filepath] = uigetfile({'*.mat'}, 'MINFLUX raw data file');
        if isequal(filename, 0)
            return;   
        end
        minfluxRawDataPath = fullfile(filepath, filename);
    end
    data = load(minfluxRawDataPath);

    % check MINFLUX data type, load attribute: loc, cfr, efo
    abberior_format = isempty(find(strcmp(fieldnames(data), 'loc'), 1));
    % load attribute: vld, tid, tim
    vld = data.vld;
    tid = data.tid(vld);
    tim = data.tim(vld);
    trace_ID = unique(tid);
    trace_length = arrayfun(@(x) sum(tid==x), trace_ID);
    if abberior_format
        loc = squeeze(data.itr.loc(vld, end, :));
        cfr = data.itr.cfr(vld, :);
        efo = data.itr.efo(vld, :);
        dcr = data.itr.dcr(vld, end);
    else
        loc = squeeze(data.loc(vld, end, :));
        cfr = data.cfr(vld, :);
        efo = data.efo(vld, :);
        dcr = data.dcr(vld, end);
    end
    
    % in earlier version of MINFLUX raw data format, cfr and efo values
    % were not always stored in the last iteration. (before 2024 May)
    [~, idx] = max(nansum(cfr)); %#ok<NANSUM>
    cfr = cfr(:, idx);
    [~, idx] = max(nansum(efo)); %#ok<NANSUM>
    efo = efo(:, idx);

    %% create dialog to get user input: range of CFR, EFO, DCR, and track length, whether to compare using trace-wise mean value, and RIMF value
    if nargin <= 1
        prompt = {'cfr min:',...
            'cfr max:',...
            'efo min:',... 
            'efo max:',... 
            'dcr min:',... 
            'dcr max:',... 
            'track length min:',... 
            'track length max:',... 
            'filter with track-wise mean value:',...
            'refractive index mismatch factor'};
        dlgtitle = 'Input';
        dims = [1, 55];
        definput = {num2str(min(cfr)), num2str(max(cfr)),...
            num2str(min(efo)), num2str(max(efo)),...
            num2str(min(dcr)), num2str(max(dcr)),...
            num2str(min(trace_length)), num2str(max(trace_length)),...
            'yes',...
            '0.668'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        if isempty(answer)
            return;
        end
        
        cfr_range =   [str2double(answer{1}) str2double(answer{2})];
        efo_range =   [str2double(answer{3}) str2double(answer{4})];
        dcr_range =   [str2double(answer{5}) str2double(answer{6})]; 
        length_range = [str2double(answer{7}) str2double(answer{8})];
        do_trace_mean =  ~isequal('n', lower(answer{9}(1))); % filter with track-wise average: if first letter input is n (or N), then No.
        RIMF = str2double(answer{10}); % refractive index mismatch factor should be measured experimentally
    end

    %vld_cfr = cfr>=cfr_range(1) & cfr<=cfr_range(2);
    %vld_efo = efo>=efo_range(1) & efo<=efo_range(2);
    
    % filter by trace length, inclusive
    
    TF_length = trace_length>=length_range(1) & trace_length<=length_range(2);
    %vld_length = repelem(TF_length, trace_length);

    
    %filter_trace_mean = true;
    if do_trace_mean
        % filter entire trace by trace-wise mean value: cfr, efo
        cfr_mean = arrayfun(@(x) mean(cfr(tid==x,:)), trace_ID);
        efo_mean = arrayfun(@(x) mean(efo(tid==x,:)), trace_ID);
        dcr_mean = arrayfun(@(x) mean(dcr(tid==x,:)), trace_ID);
        TF_trace_cfr = cfr_mean>=cfr_range(1) & cfr_mean<=cfr_range(2);
        TF_trace_efo = efo_mean>=efo_range(1) & efo_mean<=efo_range(2);
        TF_trace_dcr = dcr_mean>=dcr_range(1) & dcr_mean<=dcr_range(2);
        TF_trace = TF_trace_cfr & TF_trace_efo & TF_trace_dcr;
        %vld_trace = repelem(TF_trace, trace_length);
    else    
        % filter entire trace by min & max value: cfr, efo
        cfr_min = arrayfun(@(x) min(cfr(tid==x,:)), trace_ID);
        cfr_max = arrayfun(@(x) max(cfr(tid==x,:)), trace_ID);
        efo_min = arrayfun(@(x) min(efo(tid==x,:)), trace_ID);
        efo_max = arrayfun(@(x) max(efo(tid==x,:)), trace_ID);
        dcr_min = arrayfun(@(x) min(dcr(tid==x,:)), trace_ID);
        dcr_max = arrayfun(@(x) max(dcr(tid==x,:)), trace_ID);        
        TF_trace_cfr = cfr_min>=cfr_range(1) & cfr_max<=cfr_range(2);
        TF_trace_efo = efo_min>=efo_range(1) & efo_max<=efo_range(2);
        TF_trace_dcr = dcr_min>=dcr_range(1) & dcr_max<=dcr_range(2);
        TF_trace = TF_trace_cfr & TF_trace_efo & TF_trace_dcr;
        %vld_trace = repelem(TF_trace, trace_length);
    end
    
    trace_ID = trace_ID(TF_length & TF_trace)';
    track_length = trace_length(TF_length & TF_trace);
    %vld = vld & vld_length & vld_trace;
    
    % prepare filtered result
    filter_result = struct();
    filter_result.trace_ID = trace_ID;
    N_traces = size(trace_ID, 1);
    
    filter_result.time_stamp = cell(N_traces, 1);
    filter_result.loc_nm = cell(N_traces, 1);
    filter_result.trace_txyz = cell(N_traces, 1);
    
    for i = 1 : N_traces
        selected_data = tid==trace_ID(i);
        filter_result.time_stamp{i} = tim(selected_data)';
        
        %time = filter_result.time{i} - filter_result.time{i}(1);
        %time = time(2:end);
        loc_nm = loc(selected_data, :) * 1e9;
        loc_nm(:, 3) = loc_nm(:, 3) * RIMF;
        filter_result.loc_nm{i} = loc_nm;
        %dS = vecnorm(diff(filter_result.coordinates{i}), 2, 2);
        %S = cumsum(dS, 1);

        filter_result.trace_txyz{i} = [filter_result.time_stamp{i} filter_result.loc_nm{i}];
    end
    
    % combine ID, time, x, y, z into one data array
    data_array(:, 1) = double (repelem(filter_result.track_ID, track_length));
    data_array(:, 2:5) = vertcat(filter_result.trace_txyz{:});
    filter_result.data_array = data_array;
    data_path_txt = minfluxRawDataPath(1:end-4) + ".txt";
    save(data_path_txt, '-ascii', '-TABS', 'data_array');

end


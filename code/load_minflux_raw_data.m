function filter_result = load_minflux_raw_data (minfluxRawDataPath, cfr_range, efo_range, dcr_range, length_range, do_trace_mean, save_to_file)
    % load_minflux_raw_data Loads, filters, and optionally arranges MINFLUX raw data
    %
    % Inputs:
    %   minfluxRawDataPath - The path to the MINFLUX .mat format raw data file
    %   cfr_range (1x2 array) - Range for filtering data by cfr [min, max]
    %   efo_range (1x2 array) - Range for filtering data by efo [min, max]
    %   dcr_range (1x2 array) - Range for filtering data by dcr [min, max]
    %   length_range (1x2 array) - Range for filtering data by length of trace [min, max]
    %   do_trace_mean (logical) - Flag to determine whether to filter data with trace-wise mean value
    %   save_to_file (logical) - Flag to determine whether to save the data array to a tab separated value text file
    %
    % Output:
    %   filter_result (struct) - Struct containing the filtered result data, with the following fields:
    %       trace_ID (N-by-1 array) - array of trace ID ('tid' attribute of the MINFLUX raw data, see below Note)
    %       tim_ms (N-by-1 array) - array of time stamp, in milliseconds
    %       loc_nm (N-by-3 array) - X, Y, and Z values of the 3D localization coordinates, in nanometer
    %       trace_txyz (N-by-4 array) - array of filtered data with 4 columns: time stamp, X, Y, and Z coordinates. The units are the same as raw data, i.e.: seconds and meters.
    %       data_array (N-by-5 array) - array of filtered data with 5 columns: trace ID, time stamp, X, Y, and Z coordinates. The units are the same as raw data, i.e.: seconds and meters.
    %
    % Example:
    %    filter_result = load_minflux_raw_data ( ...
    %           ".\data\MINFLUX Nuclear Pore Raw Data.mat",...  % MATLAB format MINFLUX raw data path
    %           [0, 0.8], ...   % cfr_range [0, 0.8]
    %           [1e4, 1e7], ... % efo_range [1e4, 1e7]
    %           [0, 1], ...     % dcr_range [0, 1]
    %           [1, 350], ...   % trace length range [1, 350]
    %           true, ...       % filter with trace-wise mean value
    %           true );         % save data array to .txt data file
    % Note:
    %   Write "Yes" or "Y" in the dialog field: 'filter with tracke-wise mean
    %   or, write "No" or "N" (all not case-sensitive) to filter on each
    %   localization level. Beware that filter on single localization level
    %   will result in missing values of a given trace in filtered result.
    % 
    %   The description of trace (as identified by 'tid'), efo, cfr, and dcr attribute of MINFLUX raw data are:
    %   - tid: Trace ID (each burst or molecule track gets allocated a unique ID)
    %   - efo: Effective frequency offset (emission frequency of the fluorophore while accumulating signal on the outer EOD pattern positions, background corrected)
    %   - cfr: Center frequency ratio (the ratio of the emission frequency at the center position over that on the outer EOD pattern positions)
    %   - dcr: Detector channel ratio (the ratio of the amount of photons detected on detector Cy5 near over that detected on Cy5 far)
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04

    filter_result = [];
    %% parse input and load data file
    if nargin < 7
        save_to_file = false;
    end
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
    % in earlier version of MINFLUX raw data format, certain attributes are nested under itr
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

    %% create dialog to get user input: range of CFR, EFO, DCR, and track length, whether to compare using trace-wise mean value
    if nargin <= 1
        prompt = {'cfr min:',...
            'cfr max:',...
            'efo min:',... 
            'efo max:',... 
            'dcr min:',... 
            'dcr max:',... 
            'trace length min:',... 
            'trace length max:',... 
            'filter with trace-wise mean value:'};
        dlgtitle = 'Input';
        dims = [1, 55];
        definput = {num2str(min(cfr)), num2str(max(cfr)),...
            num2str(min(efo)), num2str(max(efo)),...
            num2str(min(dcr)), num2str(max(dcr)),...
            num2str(min(trace_length)), num2str(max(trace_length)),...
            'yes'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        if isempty(answer)
            return;
        end
        
        cfr_range =   [str2double(answer{1}) str2double(answer{2})];
        efo_range =   [str2double(answer{3}) str2double(answer{4})];
        dcr_range =   [str2double(answer{5}) str2double(answer{6})]; 
        length_range = [str2double(answer{7}) str2double(answer{8})];
        do_trace_mean =  ~isequal('n', lower(answer{9}(1))); % filter with track-wise average: if first letter input is n (or N), then No.
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
    
    filter_result.tim_ms = cell(N_traces, 1);
    filter_result.loc_nm = cell(N_traces, 1);
    filter_result.trace_txyz = cell(N_traces, 1);
    
    for i = 1 : N_traces
        selected_data = tid==trace_ID(i);   % select data specific to the current trace (by tid)
        tim_trace = tim(selected_data)';    % time stamp of the selected trace (in second)
        loc_trace = loc(selected_data, :);  % localization coordinates of the selected trace (in meter)
        filter_result.tim_ms{i} = tim_trace * 1e3; % convert time stamp to millisecond unit
        filter_result.loc_nm{i} = loc_trace * 1e9; % convert localization coordinates to nanometer unit
        %dS = vecnorm(diff(filter_result.loc_nm{i}), 2, 2);
        %S = cumsum(dS, 1);
        filter_result.trace_txyz{i} = [tim_trace loc_trace];    % trace data: t, x, y, z
    end
    
    % combine ID, time, x, y, z into one data array
    data_array(:, 1) = double (repelem(filter_result.trace_ID, track_length));
    data_array(:, 2:5) = vertcat(filter_result.trace_txyz{:});
    filter_result.data_array = data_array;

    % save data array to tab-separated value text file
    if save_to_file
        data_path_txt = minfluxRawDataPath(1:end-4) + ".txt";
        save(data_path_txt, '-ascii', '-TABS', 'data_array');
    end

end


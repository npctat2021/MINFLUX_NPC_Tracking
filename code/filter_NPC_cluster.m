function filter_NPC_cluster (cluster_data, save_mode, varargin)
    % filter_NPC_cluster filters NPC cluster data based on specified criteria.
    %
    % Inputs:
    %   cluster_data (struct array) - Structure array containing cluster data that has been double-ring fitted, to be filtered.
    %
    %   save_mode (string) - Specifies how to save the results; can be either:
    %     'over_write' - Overwrites existing variable with the same name 'cluster_data'.
    %     'new' - Saves filtered results to a new varaible with name 'cluster_data_filtered' to avoid overwriting.
    %
    %   Optional Name-Value Pairs (varargin):
    %       'heightMin' (numeric) - Minimum inter-ring height, e.g., 25.
    %       'heightMax' (numeric) - Maximum inter-ring height, e.g., 100.
    %       'diameterMin' (numeric) - Minimum ring diameter, e.g., 70.
    %       'diameterMax' (numeric) - Maximum ring diameter, e.g., 150.
    %       'zCenterMin' (numeric) - Lowest z-center location, e.g., -300.
    %       'zCenterMax' (numeric) - Highest z-center location, e.g., 100.
    %       'nLocMin' (numeric) - Minimum number of data points in cluster, e.g., 20.
    %
    % Outputs: depending on the save_mode
    %   cluster_data (struct array) - same as input, with clusters that not pass filter removed
    %
    % Example:
    %   result = filter_NPC_cluster(myClusterData, 'new', 'heightMin', 25, 'heightMax', 100, ...
    %                                 'diameterMin', 70, 'diameterMax', 150, ...
    %                                 'zCenterMin', -300, 'zCenterMax', 100, ...
    %                                 'nLocMin', 20);
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04

    
    % default saving mode is to overwrite cluster_data in base workspace
    default_save_mode = 'overwrite';
    if nargin == 1
        save_mode = default_save_mode;
    end
    heightMin = 25;
    heightMax = 100;
    diameterMin = 70;
    diameterMax = 150;
    zCenterMin = -300;
    zCenterMax  = 100;
    nLocMin = 20;
    p = inputParser;
    % cluster data is required
    addRequired(p, 'cluster_data');
    addRequired(p, 'save_mode');

    % Add optional name-value pairs
    addParameter(p, 'heightMin',    heightMin,      @isnumeric);
    addParameter(p, 'heightMax',    heightMax,      @isnumeric);
    addParameter(p, 'diameterMin',  diameterMin,    @isnumeric);
    addParameter(p, 'diameterMax',  diameterMax,    @isnumeric);
    addParameter(p, 'zCenterMin',   zCenterMin,     @isnumeric);
    addParameter(p, 'zCenterMax',   zCenterMax,     @isnumeric);
    addParameter(p, 'nLocMin',      nLocMin,        @isnumeric);

    % Parse varargin
    parse(p, cluster_data, save_mode, varargin{:});
    
    % Retrieve parameter values
    %param1 = p.Results.Parameter1;
   % param2 = p.Results.Parameter2;




    % if nargin <= 2
    %     %% get user input: render pixel size, margin ratio, channel settings
    %     prompt = {  'height min:',...
    %                 'height max:',...
    %                 'diameter min:',... 
    %                 'diameter max:',... 
    %                 'z_center min:',... 
    %                 'z_center max:',... 
    %                 'loc cound min:'};
    %     dlgtitle = 'Cluster Filter Criterion:';
    %     dims = [1, 55];
    %     definput = { '25',...
    %                  '100',...
    %                  '70',...
    %                  '150',...
    %                  '-300',...
    %                  '300',...
    %                  '20'};
    % 
    %     answer = inputdlg(prompt,dlgtitle,dims,definput);
    % 
    %     if isempty(answer)
    %         return;
    %     end
    % 
    %     height_range =   [str2double(answer{1}) str2double(answer{2})];
    %     diameter_range =   [str2double(answer{3}) str2double(answer{4})];
    %     zCenter_range =   [str2double(answer{5}) str2double(answer{6})]; 
    %     minPts = str2double(answer{7});
    % 
    % end

    height_range = [p.Results.heightMin, p.Results.heightMax];
    diameter_range = [p.Results.diameterMin, p.Results.diameterMax];
    zCenter_range = [p.Results.zCenterMin, p.Results.zCenterMax];
    minPts = p.Results.nLocMin;

    num_cluster = length(cluster_data);

    passFilter = false(num_cluster, 1);
    
    progress = 0;
    fprintf(1,'       progress: %3d%%\n', progress);
    for i = 1 : 1:num_cluster
        % report progress
        progress = ( 100*(i/num_cluster) );
        fprintf(1,'\b\b\b\b%3.0f%%', progress); % Deleting 4 characters (The three digits and the % symbol)
        
        cluster = cluster_data(i);
        if isempty(cluster.loc_nm)
            continue;
        end
        height = cluster.height;
        diameter = cluster.diameter;
        zCenter = cluster.center(:, 3);
        numPts = size(cluster.loc_nm, 1);
        
        passFilter(i) = height >= height_range(1) &&...
                        height <= height_range(2) &&...
                        diameter >= diameter_range(1) &&...
                        diameter <= diameter_range(2) &&...
                        zCenter >= zCenter_range(1) &&...
                        zCenter <= zCenter_range(2) &&...
                        numPts >= minPts;
    end
    fprintf('\n'); % To go to a new line after reaching 100% progress

    cluster_data( ~passFilter ) = [];

    switch save_mode
        case 'overwrite'
            assignin('base', 'cluster_data', cluster_data);
        case 'new'
            assignin('base', 'cluster_data_filtered', cluster_data);
        otherwise
            % do nothing
    end

end
function filter_NPC_cluster (cluster_data, save_mode, varargin)
% templateFunction - A template function demonstrating fixed and optional inputs
%
% Syntax:
%   output = templateFunction(fixedInput1, fixedInput2, 'Name', Value, ...)
%
% Inputs:
%   fixedInput1 - Description of the first fixed input
%   fixedInput2 - Description of the second fixed input
%   Name-Value Pairs:
%     'Parameter1'  - Description of parameter 1 (default: defaultValue1)
%     'Parameter2'  - Description of parameter 2 (default: defaultValue2)
%     ...           - Additional parameters as needed
%
% Output:
%   output - Description of the output


% Semi-automated clustering with interactive UI controls in MATLAB
% 
% Inputs:
%   loc - Nx3 matrix of 3D loc [x, y, z].
%   dbscan_eps - Epsilon parameter for the DBSCAN clustering.
%   dbscan_minPts - Minimum loc parameter for the DBSCAN clustering.
%   tid - Trace IDs corresponding to the loc.
%   timestamps - Time stamps corresponding to the loc.
    
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
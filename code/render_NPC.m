function density_map = render_NPC (loc, pixel_size, sd_smooth, num_sd_range)
    % renderNPC Generates a 2D or 3D density map from localization data of NPCs.
    %
    % Inputs:
    %   loc (N x m array) - An Nx2 or Nx3 matrix containing the (x, y) or (x, y, z)
    %                       coordinates of localizations.
    %   pixel_size (numeric) - The size of each pixel in the density map,
    %                           in nanometer
    %   sd_smooth (numeric) - The standard deviation for Gaussian smoothing to be 
    %                         applied to the density map.
    %   num_sd_range (numeric) - The number of standard deviations to consider for 
    %                            defining the range of the density map in each dimension 
    %
    % Outputs:
    %   densityMap (matrix) - A 2D or 3D array representing the density of localizations
    %                         smoothed over a grid in the input localizations.
    %
    % Note:
    %   It can also be used to generate side view (i.e.: XZ, YZ) by adjust
    %   the 2nd column of the input array.
    %
    % Example:
    %   densityMap = renderNPC (loc, 1, 1.0, 2.5);
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04
    
    % input argument control
    if nargin < 4
        num_sd_range = 2.5; % default range of the histogram will be ± 2.5 standard deviation around mean value of each axis
    end

    if nargin < 3
        sd_smooth = 1;    % default Gaussian blur with 1 pixel (standard deviation of Gaussian)
    end

    if nargin < 2
        pixel_size = 1;      % default pixel/voxel size is 1 nm
    end

    n_dim = size(loc, 2);
    if n_dim > 3 || n_dim < 2
        disp(" dimension of input localization data wrong! It need to be 2D or 3D.");
    end
    

    %% code block copied and modified from Mathew Beharrell's histcnd function:
    % https://www.mathworks.com/matlabcentral/fileexchange/29435-n-dimensional-histogram-count
    size_map = [1 1];
    num_pixel_dimension = 1;
    bin_count_1d = 1;
    % loop through dimensions: X, Y, Z
    for dim = 1 : n_dim
        data = loc(:, dim); % localization data along current dimension
        if range(data) < 1 
            data = data * 1e9; % in case the input localization is with unit meter
        end
        % compute histogram edge as ± N standard deviation around the mean value 
        data_mean = mean(data);
        data_std = std(data, 1);
        data_min = data_mean - num_sd_range * data_std;
        data_max = data_mean + num_sd_range * data_std;
        edge = data_min : pixel_size : data_max;   % edge of the current localization data
        % update size of the final rendered histogram map
        size_map(dim) = length(edge);
        % generate 1D array of (M) edges and (N) data, and also M '1' and N
        % '0' array, to compute the histogram bin counts, and the bin index
        % of input localization data
        cd = zeros(numel(data), 1);     % N by 1 data with 0
        ce = ones(size_map(dim), 1);     % M by 1 edge with 1
        ed = [ edge(:); data];          % edge and data vertically combined
        [~, edi] = sort(ed);            % sort combined edge, return index of sorted array corresponding to unsorted 'ed'
        ced=[ce; cd];                   % M times '1', and N times '0' vertically combined
        csum = cumsum(ced(edi));        % computing bin counts
        csum(edi) = csum;               % bin counts of the unsorted 'ed'
        bin_index_data = csum(ced==0);  % bin index of original coordinate data, identified by '0' value in ced
        %XI(XI<1) = nan;                % data cannot be assigned to any bin
        % update bin counts 1D array with the current axis bin counts
        bin_count_1d = bin_count_1d + (bin_index_data-1) * num_pixel_dimension;
        % update bin counts offset, as the total number of pixels in previous dimension
        num_pixel_dimension = num_pixel_dimension * size_map(dim);
    end
    bin_count_nd = histcounts( bin_count_1d, 1 : prod(size_map) ); % generate histogram counts for all bins of all dimensions
    bin_count_nd(end+1) = 0;
    bin_count_nd = reshape(bin_count_nd, size_map); % reshape the final bin counts into the N-D histogram

    density_map = imgaussfilt3(bin_count_nd, sd_smooth);
    
    % optional code block, to accommodate for 8-bit gray image
    % factor = 255 / max(density_map(:));    % rescale to 0-255 pixel value range
    % density_map = density_map * factor;

end
function densityMap = render_NPC_2D (xy)
    % render_NPC_2D Generates a 2D density map from provided 2D coordinates of NPC localizations.
    %
    % Inputs:
    %   xy (Nx2 array) - An Nx2 matrix containing the (x, y) coordinates of the 
    %                    nuclear pore complex (NPC) localizations.
    %
    % Outputs:
    %   densityMap (matrix) - A 2D array representing the density of localizations
    %                         visualized over a grid in the XY plane.
    %
    % Note:
    %   It can also be used to generate side views (i.e.: XZ, YZ) by
    %   adjusting the 2nd column of the input array.
    %
    % Example:
    %   densityMap = render_NPC_2D([xCoordinates, yCoordinates]);
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04

    x = xy(:, 1);
    y = xy(:, 2);
    pixelSize = 1;  % default pixel size: 1nm

    xMean = mean(x); xStd = std(x, 1);
    yMean = mean(y); yStd = std(y, 1);
    %marginRatio = 10;    % default margin ratio 10%

    xMin = xMean - 2.5*xStd; xMax = xMean + 2.5*xStd;
    yMin = yMean - 2.5*yStd; yMax = yMean + 2.5*yStd;
    % xMin = min(x); xMax = max(x); xRange = xMax-xMin; xMid = (xMin+xMax)/2;
    % yMin = min(y); yMax = max(y); yRange = yMax-yMin; yMid = (yMin+yMax)/2;
    % %zMin = min(z); zMax = max(z); zRange = zMax-zMin; zMid = (zMin+zMax)/2;
    % halfSize = 0.5 * (1 + marginRatio/100);
    % xMin = xMid - halfSize * xRange; xMax = xMid + halfSize * xRange;
    % yMin = yMid - halfSize * yRange; yMax = yMid + halfSize * yRange;
    % %zMin = zMid - halfSize * zRange; zMax = zMid + halfSize * zRange;
    
    
    
    % pixel/voxel resolution in nm
    resolution = pixelSize;   
    xGrid = xMin : resolution : xMax;   % X grid
    yGrid = yMin : resolution : yMax;   % Y grid
    %zGrid = zMin : resolution : zMax;   % Z grid

    densityMap = histcounts2(x, y, xGrid, yGrid);
    %renderImg = imgaussfilt(densityMap, sd_gaussian);
    %factor = 255/max(renderImg(:));
    %factor = 1;
    %renderImg = renderImg*factor;

end
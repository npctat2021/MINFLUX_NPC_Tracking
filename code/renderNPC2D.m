function densityMap = renderNPC2D (xy)
    
    x = xy(:,1);
    y = xy(:,2);
    pixelSize = 1;  % default pixel size: 1nm
    marginRatio = 5;    % default margin ratio 5%



    xMin = min(x); xMax = max(x); xRange = xMax-xMin; xMid = (xMin+xMax)/2;
    yMin = min(y); yMax = max(y); yRange = yMax-yMin; yMid = (yMin+yMax)/2;
    %zMin = min(z); zMax = max(z); zRange = zMax-zMin; zMid = (zMin+zMax)/2;
    halfSize = 0.5 * (1 + marginRatio/100);
    xMin = xMid - halfSize * xRange; xMax = xMid + halfSize * xRange;
    yMin = yMid - halfSize * yRange; yMax = yMid + halfSize * yRange;
    %zMin = zMid - halfSize * zRange; zMax = zMid + halfSize * zRange;
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
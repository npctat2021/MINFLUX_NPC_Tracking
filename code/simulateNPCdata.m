function loc_all = simulateNPCdata (nCluster, diameter, ringDistance, cornerSigma, nPointPerCorner)
    
    if nargin < 5
        nPointPerCorner = 1e2;
    end
    if nargin < 4
        cornerSigma = 15;
    end
    if nargin < 3
        ringDistance = 40;
    end
    if nargin < 2
        diameter = 110;
    end
    if nargin < 1
        nCluster = 10;
    end

    numRingPerCluster = 2;
    numCornerPerRing = 8;
    cornerAngleShift = 22.5;

    

    xrot = 15 * rand;
    yrot = 15 * rand;
    Rx = [1, 0, 0; 0, cosd(xrot), sind(xrot); 0, -sind(xrot), cosd(xrot)];
    Ry = [cosd(yrot), 0, -sind(yrot); 0, 1, 0; sind(yrot), 0, cosd(yrot)];

    %loc_all = zeros(nCluster * numRingPerCluster * numCornerPerRing * nPointPerCorner, 3);
    loc_all = [];
    


    % calculate the center coordinates of the NPC subunits, relative to the NPC center
    cornerCenters = zeros(numCornerPerRing * numRingPerCluster, 3);
    angleIncrement = 360 / numCornerPerRing;
    for n = 1 : numCornerPerRing
        angleRad = deg2rad(angleIncrement * (n - 1) + cornerAngleShift);
        cornerCenters(n, :) = [diameter / 2 * cos(angleRad), diameter / 2 * sin(angleRad), -ringDistance/2];
        cornerCenters(n + numCornerPerRing, :) = ...
            [diameter / 2 * cos(angleRad), diameter / 2 * sin(angleRad), ringDistance/2];
    end
    

    % generate the NPC cluster centers, in a FOV of 1000 x 1000 x 200 nm volume
    xyz_center = 2e3 * rand(nCluster, 3);
    xyz_center(:, 3) = xyz_center(:, 3) / 5;
    
    
    for i = 1 : nCluster
        pos = xyz_center(i, :);
        %cornerCenter_i = cornerCenters + pos;
        
        loc_cluster = [];
        for m = 1 : size(cornerCenters, 1)
            locs = generateGaussianPoints(cornerCenters(m, :), cornerSigma/2, round(nPointPerCorner*rand));
            locs = locs(:, 1:3);
            loc_cluster = [loc_cluster; locs]; %#ok<AGROW>
        end
        
        zrot = 45* rand;
        Rz = [cosd(zrot), sind(zrot), 0; -sind(zrot), cosd(zrot), 0; 0, 0, 1];
        
        loc_rot = ( Rz* (Ry* (Rx* loc_cluster') ) )';
        loc_trans = loc_rot + pos;

        loc_all = [loc_all; loc_trans]; %#ok<AGROW>

    end


    % Plot point cloud
    figure;
    scatter3(loc_all(:,1), loc_all(:,2), loc_all(:,3), '.');
    axis equal;



end

function points = generateGaussianPoints(center, sigma, numPoints)
    % Generate Gaussian-distributed points around the cluster center
    x = randn(numPoints, 1) * sigma + center(1);
    y = randn(numPoints, 1) * sigma + center(2);
    z = randn(numPoints, 1) * sigma + center(3);
    gaussValues = exp(-((x-center(1)).^2 + (y-center(2)).^2 + (z-center(3)).^2) / (2 * sigma^2));
    %probability = gaussValues / max(gaussValues);
    %mask = rand(numPoints, 1) < probability;
    points = [x, y, z, gaussValues];
end
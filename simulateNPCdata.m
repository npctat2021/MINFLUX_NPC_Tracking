function data_all = simulateNPCdata (nCluster, npc_density, nPointPerCorner, curvAngle, diameter, ringDistance, cornerSigma, frameInterval, RIMF)
    
    if nargin < 9
        RIMF = 0.668;
    end
    if nargin < 8
        frameInterval = 1e-3;   % default frame interval is 1 millisecond
    end
    if nargin < 7
        cornerSigma = 10;       % size of the subunit (per MINFLUX trace) in nm
    end
    if nargin < 6
        ringDistance = 40;      % NPC inter-ring distance in nm
    end
    if nargin < 5
        diameter = 110;         % NPC ring diameter in nm
    end
    if nargin < 4
        curvAngle = 15;          % curvature angle of the surface, corresponding to the steradian/angle of the minimum circumscribe sphere to the surface
    end
    if nargin < 3
        nPointPerCorner = 5e2;  % number of Loc per subunit (per MINFLUX trace)
    end
    if nargin < 3
        npc_density = 0.01;     % NPC density per area, maximum is 1, as NPCs are right next to each other in the generated FOV
    end
    if nargin < 1
        nCluster = 20;          % number of NPC in simulated data
    end

    numRingPerCluster = 2;
    numCornerPerRing = 8;
    cornerAngleShift = 22.5;
    %x_angle = 30;   % rotation degree around X axis, YZ plane
    %y_angle = 30;   % rotation degree around Y axis, XZ plane
    %z_angle = 45;   % rotation degree around Z axis, XY plane
    %xrot = x_angle * (rand-0.5);
    %yrot = y_angle * (rand-0.5);

    %disp("x rotation: " + xrot);
    %disp("y rotation: " + yrot);

    %Rx = [1, 0, 0; 0, cosd(xrot), sind(xrot); 0, -sind(xrot), cosd(xrot)];
    %Ry = [cosd(yrot), 0, -sind(yrot); 0, 1, 0; sind(yrot), 0, cosd(yrot)];
    %npc_density = 0.03; % roughly 1 NPC in the area of 
    %xy_range = diameter * sqrt(nCluster) / npc_density;
    %z_range = xy_range / 20;
    %xyz_FOV = [xy_range, xy_range, z_range]; % default FOV is 1000 x 1000 x 200 nm volume
    %cellCenter = [0, 0, -9700]; % default cell center is in the middle of FOV, and 10 micron beneath imaging plane.


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
    [points, rotationMatrices, radius] = generateSpherePointsWithRotation(nCluster, diameter/2, npc_density, curvAngle);
    disp(" sphere radius: " + radius + " nm");
    xyz_center = points;
    xyz_center = xyz_center - mean(xyz_center);
    
    
    info = struct();

    trace_ID = 1; timeStamp = 0;
    %loc_all = zeros(nCluster * numRingPerCluster * numCornerPerRing * nPointPerCorner, 3);
    data_all = [];
    for i = 1 : nCluster
        
        info(i).cluster = i;
        pos = xyz_center(i, :);
        %cornerCenter_i = cornerCenters + pos;
        info(i).center = pos;

        info(i).trace = [];
        data_cluster = [];
        for m = 1 : size(cornerCenters, 1)
            data_corner = generateSubunitLocData(cornerCenters(m, :), cornerSigma/2, round(nPointPerCorner*rand), trace_ID, timeStamp, frameInterval);
            if isempty(data_corner)
                continue;
            end

            info(i).trace = vertcat(info(i).trace, trace_ID);

            trace_ID = trace_ID + 1;
            timeStamp = timeStamp + data_corner(end, 2) + 5e-3; % in between trace delay set to 5 ms
            data_cluster = [data_cluster; data_corner];  

        end
        
        loc_ori = data_cluster(:, 3:5);
        
        zrotInPlane = 45 * rand;
        RzInPlane = [cosd(zrotInPlane), sind(zrotInPlane), 0; -sind(zrotInPlane), cosd(zrotInPlane), 0; 0, 0, 1];
        loc_ori = (RzInPlane * loc_ori')';

        
        info(i).rotation = rotationMatrices{i};
        [zrot, yrot, xrot] = rotationMatrixToEulerAngles( info(i).rotation );
        Rx = [1, 0, 0; 0, cosd(xrot), sind(xrot); 0, -sind(xrot), cosd(xrot)];
        Ry = [cosd(yrot), 0, -sind(yrot); 0, 1, 0; sind(yrot), 0, cosd(yrot)];
        Rz = [cosd(zrot), sind(zrot), 0; -sind(zrot), cosd(zrot), 0; 0, 0, 1];
        info(i).Rx = Rx;
        info(i).Ry = Ry;
        info(i).Rz = Rz;
        info(i).zrotInPlane = zrotInPlane;
        info(i).RzInPlane = RzInPlane;
        
        loc_rot = ( rotationMatrices{i} * loc_ori' )';

        loc_trans = loc_rot + pos;
        
        data_cluster(:, 3:5) = loc_trans;
        
        info(i).nLoc = size(data_cluster, 1);

        data_all = [data_all; data_cluster]; 

    end

    data_all(:, 5) = data_all(:, 5) / RIMF;

    assignin('base', 'data_sim_info', info);

    % Plot point cloud
    figure;
    scatter3(data_all(:, 3), data_all(:, 4), data_all(:, 5), [], data_all(:, 1), '.');
    colormap jet;
    axis equal;
    view(2);



end

function [points, rotationMatrices, radius] = generateSpherePointsWithRotation(nPoint, npc_radius, npc_density, maxPolarAngle)
    % Initialize variables
    %points = zeros(nPoint, 3);
    rotationMatrices = cell(nPoint, 1);
    % Define the original up direction (Z-axis) in the local frame
    originalZ = [0, 0, 1];
  
    [points, radius] = generateCenterPoints(nPoint, npc_radius, npc_density, maxPolarAngle);

    for i = 1 : length(points)
        % Generate random spherical coordinates with elevation bounded by theta

        % Calculate the normal vector at the sphere surface point
        normalVector = [points(i, 1), points(i, 2), points(i, 3)] / radius;  % Normalized, since it's on the sphere
        % Calculate the axis of rotation (cross product)
        axisOfRotation = cross(originalZ, normalVector);
        % Check for alignment
        if norm(axisOfRotation) < 1e-6
            % If the normal vector is aligned with the original Z, the rotation is identity
            R = eye(3);
        else
            % Calculate the angle of rotation using the dot product
            angleOfRotation = acos(dot(originalZ, normalVector));
            % Normalize the axis of rotation
            axisOfRotation = axisOfRotation / norm(axisOfRotation);
            % Compute the rotation matrix using Rodrigues' rotation formula
            R = computeRotationMatrix(axisOfRotation, angleOfRotation);
        end
        
        rotationMatrices{i} = R;
    end

    %figure;
    %scatter3(points(:,1), points(:,2), points(:,3), '.');
    %axis equal;

end


function [points, radius] = generateCenterPoints(nPoint, npc_radius, npc_density, maxPolarAngle)
    if maxPolarAngle == 0
        maxPolarAngle = 1e-3;
    end
     % Calculate the effective radius
    radius = npc_radius * sqrt( nPoint / 2 / npc_density / (1-cosd(maxPolarAngle) ) ) ;
    % use random without checking on overlap
    angleArc = maxPolarAngle / 180 * pi;

    minSeparation = npc_radius * 2 *1.1;

    azimuth = 2*pi* rand(nPoint, 1);
    elevation_start = pi/2 - angleArc;
    elevation = asin( rand(nPoint, 1) );
    elevation = elevation * angleArc * 2 / pi; %elevation * ( 1 - (2*elevation_start/pi) );
    elevation = elevation + elevation_start;
    
    [x,y,z] = sph2cart(azimuth, elevation, radius);
    
    xy = [x, y];
    dist = pdist2(xy, xy);
    [dist_sort, ~] = sort(dist, 2);
    overlappedPair = dist_sort(:, 2) < minSeparation;

    x(overlappedPair) = [];
    y(overlappedPair) = [];
    z(overlappedPair) = [];
    
    iter = 0; maxIter = 2e4;
    count = nPoint - sum(overlappedPair);

    while ( count < nPoint )

        if iter > maxIter
            break;
        end
        iter  = iter+1;

        azimuth_new = 2*pi* rand;
        elevation_new = asin(rand);
        elevation_new = elevation_new * angleArc * 2 / pi; %elevation * ( 1 - (2*elevation_start/pi) );
        elevation_new = elevation_new + elevation_start;

        [x_new, y_new, z_new] = sph2cart(azimuth_new, elevation_new, radius);
        if min( pdist2 ([x, y], [x_new, y_new]) ) < minSeparation
            continue;
        end

        count = count + 1;
        x = [x; x_new]; %#ok<*AGROW>
        y = [y; y_new];
        z = [z; z_new];

    end
    points = [x, y, z];
end


function R = computeRotationMatrix(axis, angle)
    % Compute the rotation matrix from axis and angle using Rodrigues' formula
    a_x = [0, -axis(3), axis(2);
           axis(3), 0, -axis(1); 
          -axis(2), axis(1), 0];
    I = eye(3);
    R = I + sin(angle) * a_x + (1 - cos(angle)) * (a_x * a_x);
end



function [yaw, pitch, roll] = rotationMatrixToEulerAngles(R)
    % Check if the matrix is a valid rotation matrix
    if size(R, 1) ~= 3 || size(R, 2) ~= 3 || abs(det(R) - 1) > 1e-5
        error('Input must be a valid 3x3 rotation matrix.');
    end
    % Calculate pitch (theta)
    pitch = asin(-R(3, 1));
    if abs(cos(pitch)) > 1e-5  % cos(pitch) is not zero
        % Calculate roll (phi) and yaw (psi) normally
        roll = atan2(R(3, 2), R(3, 3));
        yaw = atan2(R(2, 1), R(1, 1));
    else
        % Gimbal lock case
        % If pitch is ±90°, roll and yaw are coupled
        roll = atan2(-R(1, 2), R(2, 2));
        yaw = 0;
    end
    % Convert all angles from radians to degrees
    yaw = rad2deg(yaw);
    pitch = rad2deg(pitch);
    roll = rad2deg(roll);
end


function data_perSubunit = generateSubunitLocData(center, radius, nLoc, trace_ID, t0, dt, type, minLoc)
    data_perSubunit = [];
    
    if nargin < 8
        minLoc = 30;
    end
    if (nLoc < minLoc)
        return;
    end
    if nargin < 7
        type = 'normal';
    end
    
    % Generate trace ID array and time stamp array
    tid = (repelem(trace_ID, nLoc))';
    tim = ( t0 + dt*(0 : 1 : nLoc-1) )';
    
    xyz = zeros(nLoc, 3);

    switch type
        case 'normal'
            xyz = randn(nLoc, 3) * radius / 3; % approximate radius as 3 sigma (FWHM of Gaussian is 2.3548 sigma)

        case 'even'
            nLoc_cube = 3 * nLoc;
            xyz = 2  * radius * ( rand(nLoc_cube, 3) -0.5 );
            dist = vecnorm(xyz')';
            xyz = xyz(dist<=radius, :);
            if (size(xyz, 1)>nLoc)
                xyz = xyz(1:nLoc, :);
            end

        case 'rim'
            rimSize = radius / 5;
            rimSigma = rimSize / 6;
            directions = randn(nLoc, 3);
            directions = directions ./ vecnorm(directions, 2, 2); % Normalize to unit vectors
            radii = radius + rimSigma * randn(nLoc, 1); % Gaussian distribution around 'radius'
            radii = max(0, radii); % Ensure no negative radius
            radii = min(radius + rimSize, max(radius - rimSize, radii));
            xyz = directions .* radii;

        case 'shell'
            golden_angle = pi * (3 - sqrt(5));
            %i = 1 : 1 : nLoc;
            z = 1 : 2/(1-nLoc) : -1;
            %z = 1 - (2*i-1)/nLoc;

            theta = acos(z);
            phi = mod(golden_angle*(1:1:nLoc), 2*pi);

            x = cos(phi).*sin(theta);
            y = sin(phi).*sin(theta);
            xyz = radius * [x', y', z'];  

    end

    xyz = xyz + center;
    % Generate Gaussian-distributed points around the cluster center
    
    %gaussValues = exp(-((x-center(1)).^2 + (y-center(2)).^2 + (z-center(3)).^2) / (2 * sigma^2));
    %probability = gaussValues / max(gaussValues);
    %mask = rand(numPoints, 1) < probability;
    %points = [x, y, z, gaussValues];
    data_perSubunit = [tid, tim, xyz(:,1), xyz(:,2), xyz(:,3)];
end




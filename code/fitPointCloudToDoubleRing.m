function fitPointCloudToDoubleRing(pointCloud)
    % Assume pointCloud is an Nx3 matrix with the center of mass already at the origin

    % Parameters for the double ring model
    ringDiameter = 100;  % example value
    interRingDistance = 50;  % example value
    numClustersPerRing = 8;
    maxZTilt = deg2rad(30);  % 30 degree tilt limit in radians

    % Generate ring model
    [ring1, ring2] = generateRings(ringDiameter, interRingDistance, numClustersPerRing);
    ringModel = [ring1; ring2];

    % Initial rotation guess (identity rotation)
    initialRot = eye(3);

    % Options for optimization
    options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');

    % Objective function to minimize (distance error)
    objectiveFun = @(rotParams) calculateFitError(pointCloud, ringModel, rotParams);

    % Constraints to maintain Z tilt within limits
    constraintFun = @(rotParams) rotationConstraints(rotParams, maxZTilt);

    % Optimize rotation parameters
    rotParams = fmincon(objectiveFun, rotationToParams(initialRot), [], [], [], [], [], [], constraintFun, options);

    % Convert optimized parameters back to rotation matrix
    R = paramsToRotation(rotParams);

    % Rotate the ring model to the best fit
    fittedModel = (R * ringModel')';

    % Visualize result
    figure;
    scatter3(pointCloud(:, 1), pointCloud(:, 2), pointCloud(:, 3), 'b');
    hold on;
    scatter3(fittedModel(:, 1), fittedModel(:, 2), fittedModel(:, 3), 'r', 'filled');
    axis equal;
    grid on;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('Point Cloud with Fitted Double Ring Model');
    legend('Point Cloud', 'Fitted Rings');
end

function [ring1, ring2] = generateRings(diameter, interRingDist, numPoints)
    theta = linspace(0, 2*pi, numPoints + 1);
    theta(end) = [];  % drop the duplicate point at 2*pi
    circX = (diameter / 2) * cos(theta);
    circY = (diameter / 2) * sin(theta);
    ring1 = [circX', circY', zeros(numPoints, 1)];
    ring2 = [circX', circY', interRingDist * ones(numPoints, 1)];
end

function error = calculateFitError(points, ringModel, rotParams)
    R = paramsToRotation(rotParams);
    transformedModel = (R * ringModel')';
    distances = pdist2(points, transformedModel);
    minDists = min(distances, [], 2);
    error = sum(minDists);
end

function [c, ceq] = rotationConstraints(rotParams, maxZTilt)
    R = paramsToRotation(rotParams);
    upVector = R * [0; 0; 1];
    c = abs(acos(dot(upVector, [0; 0; 1]))) - maxZTilt;
    ceq = [];
end

function params = rotationToParams(R)
    % Convert rotation matrix to angle-axis representation
    axang = rotm2axang(R);
    params = axang(1:3) * axang(4);
end

function R = paramsToRotation(params)
    % Convert parameters to rotation matrix
    axang = [params / norm(params), norm(params)];
    R = axang2rotm(axang);
end

function axang = rotm2axang(R)
    % rotm2axang Converts a rotation matrix to an axis-angle representation.
    % 
    % Input:
    %   R - A 3x3 rotation matrix
    % 
    % Output:
    %   axang - A 1x4 vector where the first three elements represent the
    %           axis of rotation, and the fourth element is the rotation angle in radians.

    % Ensure R is a valid rotation matrix
    assert(all(size(R) == [3, 3]), 'Input must be a 3x3 matrix.');
    assert(abs(det(R) - 1) < 1e-6, 'Matrix R must be orthogonal with determinant 1.');

    % Calculate the angle
    angle = acos((trace(R) - 1) / 2);

    % Calculate the rotation axis
    if sin(angle) < 1e-6
        % Special case: If angle is near zero, the axis is indeterminate (identity matrix)
        axis = [1, 0, 0]; % Choose an arbitrary axis
    else
        axis = [R(3, 2) - R(2, 3), R(1, 3) - R(3, 1), R(2, 1) - R(1, 2)] / (2 * sin(angle));
    end

    % Prepare the axis-angle result
    axang = [axis, angle];

    % Ensure the axis is a unit vector
    axang(1:3) = axang(1:3) / norm(axang(1:3));
end

function R = axang2rotm(axang)
    % axang2rotm Converts an axis-angle representation to a rotation matrix.
    %
    % Input:
    %   axang - A 1x4 vector where the first three elements represent the
    %           axis of rotation, and the fourth element is the rotation angle in radians.
    %
    % Output:
    %   R - A 3x3 rotation matrix.

    % Extract axis and angle
    axis = axang(1:3);
    theta = axang(4);

    % Normalize the axis
    axis = axis / norm(axis);

    % Extract components
    x = axis(1);
    y = axis(2);
    z = axis(3);

    % Precompute sine and cosine of the angle
    c = cos(theta);
    s = sin(theta);

    % Compute the rotation matrix components
    R = [c + x^2*(1-c),   x*y*(1-c) - z*s, x*z*(1-c) + y*s;
         y*x*(1-c) + z*s, c + y^2*(1-c),   y*z*(1-c) - x*s;
         z*x*(1-c) - y*s, z*y*(1-c) + x*s, c + z^2*(1-c)];
end

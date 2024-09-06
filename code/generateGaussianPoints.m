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
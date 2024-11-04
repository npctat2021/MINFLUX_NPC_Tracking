function fit_cylinder_to_cluster (cluster_data, showFitting, save_mode)
    % fit_cylinder_to_cluster Fits a double-ring (cylinder) geometry model to clustered localization data.
    %
    % Inputs:
    %   cluster_data (struct array) - Structure array containing cluster information,
    %                                  which should include fields loc_nm as coordinates 
    %                                   in nanometer, and cluster_ID.
    %   showFitting (logical) - Flag to determine whether to visually display the 
    %                           fitting result in a plot (true) or not (false).
    %   save_mode (string) - Flag specifies how to save the fitting result, can be either:
    %     'over_write' - Overwrites existing variable with the same name 'cluster_data'.
    %     'new' - Saves fitting results to a new varaible with name 'cluster_data_cylinderFitted' to avoid overwriting.
    %
    % Outputs: depending on the save_mode
    %   cluster_data (struct array) - same as input, append the following fields from fitting result:
    %       - center: fitted center of the double-ring structure
    %       - diameter: fitted ring diameter of the double-ring structure
    %       - height: fitted inter-ring distance of the double-ring structure
    %       - fittingError: sum of XY and Z fitting error of all localizations in cluster
    %
    % Example:
    %   fit_cylinder_to_cluster(cluster_data, true, 'overwrite');
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2024.11.04

    if nargin < 3
        save_mode = 'overwrite';
    end
    if nargin < 2
        showFitting = false;
    end
    
    global fig tg; %#ok<*GVMIS>
    num_pore = length(cluster_data);

    %theta=0:0.01:2*pi;
    %pixel_size=1.0; %nm
    
    %result = struct;
    try
        close(901);
    catch
        % no previous double-circle fitting figure, no action
    end
    
    progress = 0;
    fprintf(1,'       progress: %3d%%\n', progress);
    for i = 1 : num_pore %for total how many pores you want
        % report progress
        progress = ( 100*(i/num_pore) );
        fprintf(1,'\b\b\b\b%3.0f%%', progress); % Deleting 4 characters (The three digits and the % symbol)

        if isempty(cluster_data(i).loc_nm)
            continue;
        end
        P = cluster_data(i).loc_nm;
    
        global x_noise y_noise z_noise; %#ok<*TLEV>
        x_noise = P(:,1)';
        y_noise = P(:,2)';
        z_noise = P(:,3)';
        
        
        %Initial guess of the parameters [x_c, y_c, z_c, r, cylinder_radius, cylinder_height]
        initialGuess = [
            mean(x_noise), mean(y_noise), mean(z_noise), ...
            (max(x_noise) - min(x_noise) + max(y_noise) - min(y_noise)) / 2, ...
            max(z_noise) - min(z_noise)];
        
        
        %Estimate the parameters
        options = optimoptions(@fminunc,'Display', 'off');
        [solution, fval, ~, ~, ~, ~] = fminunc(@calculateError, initialGuess, options);
        
        
        %Output the parameter estimates
        if (showFitting)
            % disp(["Center x estimate: ", sprintf('%.2f', solution(1))]);
            % disp(["Center y estimate: ", sprintf('%.2f', solution(2))]);
            % disp(["Center z estimate: ", sprintf('%.2f', solution(3))]);
            % disp(["Center radius estimate: ", sprintf('%.2f', solution(4))]);
            % disp(["Center height estimate: ", sprintf('%.2f', solution(5))]);
            % disp(["Exit flag: ", sprintf('%d', info)]);

            %Plot the data points
            if ~ishandle(901)
                fig = figure(901);
                fig.NumberTitle = 'off';
                fig.Name = 'Double ring fit of cluster';
                tg = uitabgroup(fig);
            else
                fig = findobj( 'Type', 'Figure', 'Number', 901);
            end

            tab = uitab(tg, 'Title', num2str(cluster_data(i).cluster_ID));
            ax = axes('Parent', tab);
            scatter3(ax, x_noise, y_noise, z_noise,  '*');
            axis equal;
            hold on
            %Plot circles based on parameter estimates
            t = 0:pi/16:2 * pi;
            plot3(ax, solution(1) + solution(4) * cos(t), solution(2) + solution(4) * sin(t), ones(1, length(t)) .* solution(3) + solution(5) / 2, 'g-', 'LineWidth', 3);
            plot3(ax, solution(1) + solution(4) * cos(t), solution(2) + solution(4) * sin(t), ones(1, length(t)) .* solution(3) - solution(5) / 2, 'y-', 'LineWidth', 3);
            hold off;

        end
        
        cluster_data(i).center = solution(1:3);
        cluster_data(i).diameter = 2 * solution(4);
        cluster_data(i).height = solution(5);
        cluster_data(i).fittingError = fval;

    end
    fprintf('\n'); % To go to a new line after reaching 100% progress

    % x_center=x_center';
    % y_center=y_center';
    % z_center=z_center';
    % diameter=diameter';
    % height=height';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    switch save_mode
        case 'overwrite'
            assignin('base', 'cluster_data', cluster_data);
        case 'new'
            assignin('base', 'cluster_data_cylinderFitted', cluster_data);
        otherwise
            % do nothing
    end
    assignin('base', 'cluster_data', cluster_data);
end

%Error function that is minimized
function err = calculateError(theta)

  global x_noise y_noise z_noise;
  
  x_center = theta(1);
  y_center = theta(2);
  z_center = theta(3);
  radius = theta(4);
  height = theta(5);

  xyDistFromCenter = sqrt((x_noise - x_center) .^ 2 + (y_noise - y_center) .^ 2);
  xyDistError = abs(xyDistFromCenter - radius);
  
  zDistFromCenter = abs(z_noise - z_center);
  zDistError = abs(zDistFromCenter - height / 2);
  
  err = sum([xyDistError zDistError]);

end


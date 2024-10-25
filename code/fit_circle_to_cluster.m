function fit_circle_to_cluster (cluster_data, showFitting, save_mode)
    
    %fold_name='C:\Users\zhuang\Workspace\MINFLUX\TAMU_tracking\MINFLUX_NPC_Tracking-main\';
    %file_name='pore';
    %num_pore=4; % Mention the number of qualified pores from the clusters
    if nargin < 3
        save_mode = 'overwrite';
    end
    if nargin < 2
        showFitting = false;
    end
    
    global fig tg;

    theta=0:0.01:2*pi;
    %pixel_size=1.0; %nm, not used for MINFLUX analysis.

    num_cluster = length(cluster_data);
    xhat = zeros(num_cluster, 1);
    yhat = zeros(num_cluster, 1);
    rhat = zeros(num_cluster, 1);

    
    
    x2hat = zeros(num_cluster, 1);
    y2hat = zeros(num_cluster, 1);
    r2hat = zeros(num_cluster, 1);
    
    progress = 0;
    fprintf(1,'       progress: %3d%%\n', progress);
    for i = 1 : num_cluster
        % report progress
        progress = ( 100*(i/num_cluster) );
        fprintf(1,'\b\b\b\b%3.0f%%', progress); % Deleting 4 characters (The three digits and the % symbol)

        cluster = cluster_data(i);

        %P=load([fold_name num2str(i) file_name '.txt']);
        
        %id = cluster.tid;
        %fr = cluster.tim;
        x = cluster.loc_nm(:, 1);
        y = cluster.loc_nm(:, 2);
        nLoc = length(x);
        %z = cluster.loc_nm(:, 3);
        c = [x y ones(length(x),1)]\-(x.^2+y.^2); %least squares fit


        xhat(i) = real(-c(1)/2);
        yhat(i) = real(-c(2)/2);
        rhat(i) = real(sqrt(xhat(i)^2+yhat(i)^2-c(3)));
        % Exclude points for bisquare fitting
        y_all_possib=[yhat(i)+sqrt(rhat(i).^2-(x-xhat(i)).^2),yhat(i)-sqrt(rhat(i).^2-(x-xhat(i)).^2)];
        diff = y-y_all_possib;
        
        y_fit = zeros(nLoc, 1);
        for m=1:1:length(x)
            if abs(diff(m,1))<abs(diff(m,2))
                yfit1=y_all_possib(m,1);
            else
                yfit1=y_all_possib(m,2);
            end
            y_fit(m) = yfit1;
        end
        y_fit = real(y_fit);

        residuals = y-y_fit;
        I = abs( residuals) < 2*std( residuals );
        inliers = excludedata(x,y,'indices',I); % points to keep after excluding outliers
        

        % id2 = id(inliers);
        % ts2 = fr(inliers);
        x2 = x(inliers);
        y2 = y(inliers);
        % z2 = z(inliers);
        if (showFitting)
            if ~ishandle(902)
                fig = figure(902);
                fig.NumberTitle = 'off';
                fig.Name = 'Bisquare circle fit of cluster';
                tg = uitabgroup(fig);
            else
                fig = findobj( 'Type', 'Figure', 'Number', 902);
            end
            tab = uitab(tg, 'title', num2str(cluster_data(i).ClusterID));
            ax = axes('Parent', tab);
            plot(ax, x2, y2, '*')
            axis equal;
            hold on;
            c2 = [x2 y2 ones(length(x2),1)]\-(x2.^2+y2.^2); % least squares fit
            x2hat(i) = real(-c2(1)/2);
            y2hat(i) = real(-c2(2)/2);
            r2hat(i) = real(sqrt(x2hat(i)^2+y2hat(i)^2-c2(3)));
            points_x = repmat(x2hat(i),1,size(theta,2))+r2hat(i)*cos(theta);
            points_y = repmat(y2hat(i),1,size(theta,2))+r2hat(i)*sin(theta);
            plot(ax, points_x, points_y, 'r-');
            hold off;
        end
        
        cluster_data(i).loc_nm = cluster.loc_nm(inliers, :);
        cluster_data(i).tid = cluster.tid(inliers, :);
        cluster_data(i).tim = cluster.tim(inliers, :);

        %P2=[id2, ts2, x2, y2, z2];
        
        %save([fold_name num2str(i) file_name 'bisquare.txt'],'-ascii','-TABS','P2');
       
        
        
    end
    fprintf('\n'); % To go to a new line after reaching 100% progress

    switch save_mode
        case 'overwrite'
            assignin('base', 'cluster_data', cluster_data);
        case 'new'
            assignin('base', 'cluster_data_circleFitted', cluster_data);
        otherwise
            % do nothing
    end
    
end

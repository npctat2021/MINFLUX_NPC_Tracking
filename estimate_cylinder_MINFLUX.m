%Step2: Double circle fitting of the clusters

clear
clear global;

%Load data
%data = dlmread('ideal case.txt');
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
num_pore=16;% Mention the number of cluster isolated.
file_name='cluster';
theta=0:0.01:2*pi;
pixel_size=1.0; %nm


for i=1:num_pore %for total how many pores you want
    P=load([fold_name num2str(i) file_name '.txt']);

global x_noise y_noise z_noise;
x_noise = P(:,3)';
y_noise = P(:,4)';
z_noise = P(:,5)';


%Initial guess of the parameters [x_c, y_c, z_c, r, cylinder_height]
initialGuess = [mean(x_noise), mean(y_noise), mean(z_noise), ...
    (max(x_noise) - min(x_noise) + max(y_noise) - min(y_noise)) / 2, ...
    max(z_noise) - min(z_noise)];


%Estimate the parameters
[solution, fval, info, output, grad, hess] = fminunc(@calculateError, initialGuess);


%Output the parameter estimates
disp(["Center x estimate: ", sprintf('%.2f', solution(1))]);
disp(["Center y estimate: ", sprintf('%.2f', solution(2))]);
disp(["Center z estimate: ", sprintf('%.2f', solution(3))]);
disp(["Center radius estimate: ", sprintf('%.2f', solution(4))]);
disp(["Center height estimate: ", sprintf('%.2f', solution(5))]);
disp(["Exit flag: ", sprintf('%d', info)]);

x_center(i)=solution(1);
y_center(i)=solution(2);
z_center(i)=solution(3);
diameter(i)=2*solution(4);
height(i)=solution(5);


%Plot the data points
figure;
plot3(x_noise, y_noise, z_noise,  '*');
set(gca, 'DataAspectRatio', [1 1 1]);
hold on


%Plot circles based on parameter estimates
t = 0:pi/16:2 * pi;
hold on;
plot3(solution(1) + solution(4) * cos(t), solution(2) + solution(4) * sin(t), ones(1, length(t)) .* solution(3) + solution(5) / 2, 'g-', 'LineWidth', 5);
hold on;
plot3(solution(1) + solution(4) * cos(t), solution(2) + solution(4) * sin(t), ones(1, length(t)) .* solution(3) - solution(5) / 2, 'y-', 'LineWidth', 5);
pause(1)
close(gcf)
end

x_center=x_center';
y_center=y_center';
z_center=z_center';
diameter=diameter';
height=height';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mean_dev_diameter=mean(diameter-100);
dev_dev_diameter=std(diameter-100);
diameter_error=[mean_dev_diameter,dev_dev_diameter];
mean_dev_height=mean(height-55);
dev_dev_height=std(height-55);
height_error=[mean_dev_height,dev_dev_height];

save([fold_name file_name 'x_center.txt'],'-ascii','-TABS','x_center');
save([fold_name file_name 'y_center.txt'],'-ascii','-TABS','y_center');
save([fold_name file_name 'z_center.txt'],'-ascii','-TABS','z_center');
save([fold_name file_name 'diameter.txt'],'-ascii','-TABS','diameter');
save([fold_name file_name 'height.txt'],'-ascii','-TABS','height');
save([fold_name file_name 'diameter_error.txt'],'-ascii','-TABS','diameter_error');
save([fold_name file_name 'height_error.txt'],'-ascii','-TABS','height_error');


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
% Calculation of frequency against bin to plot as a histogram
function pore_rotation_MINFLUX_step1
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name1='porebisquare';
file_name2='porex_center';
file_name3='porey_center';
pore_center_x=load([fold_name file_name2 '.txt']);
pore_center_y=load([fold_name file_name3 '.txt']);
num_pore=16;% Mention the number of qualified pores from the clusters
for l=1:1:num_pore
data_pore=load([fold_name num2str(l) file_name1 '.txt']);
x=data_pore(:,3);
y=data_pore(:,4);
x_centered=x-pore_center_x(l);
y_centered=y-pore_center_y(l);
rot_ninety=atan(y_centered./x_centered).*(180/pi);
save([fold_name num2str(l) 'pore_ninety_normalized.txt'],'-ascii','-TABS','rot_ninety');
end
end
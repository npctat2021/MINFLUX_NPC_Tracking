%step-2: apply the transfer matrix in x,y,z in green localizations to match
%those with red channel
function green_localization_in_red_channel_MINFLUX
clc
clear
b=-8.22;% Take average difference in z (Red-Yellow) from bead data and place the number.
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='Tracks Model Data';% txt file contains track id, time stamp and x, y, z data.
all_green=load([fold_name file_name '.txt']);
transfer_mat=load([fold_name 'g2r_transfer_matrix.txt']);
id=all_green(:,1);
ts=all_green(:,2);
tsa=ts*(10^3);
xm=all_green(:,3);
x=xm*(10^9);
ym=all_green(:,4);
y=ym*(10^9);
zm=all_green(:,5);
z=zm*(10^9)*0.668;% Applying z-scaling factor of the MINFLUX instrument. 
x_calib=((x.*transfer_mat(1,1))+(y.*transfer_mat(2,1)))+transfer_mat(3,1);
y_calib=((y.*transfer_mat(1,2))+(y.*transfer_mat(2,2)))+transfer_mat(3,2);
z_calib=z+b;
all_green_calib=[id,tsa,x_calib,y_calib,z_calib];
save([fold_name file_name '_calib.txt'],'-ascii','-TABS','all_green_calib');
end
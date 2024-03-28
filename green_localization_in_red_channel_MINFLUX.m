%step-2: apply the transfer matrix in x,y,z in green localizations to match
%those with red channel
function green_localization_in_red_channel_MINFLUX
clc
clear
b=2;% Difference in z value (nm)
fold_name='H:\MINFLUXexportimport\Manuscript\MINFLUX  MATLAB programs\Code for Aligning Tracks with NPC\';
file_name='Tracksxyz3';% txt file contains track id, time stamp and x, y, z data.
all_green=load([fold_name file_name '.txt']);
transfer_mat=load([fold_name 'g2r_transfer_matrix.txt']);
id=all_green(:,1);
ts=all_green(:,2);
x=all_green(:,3);
y=all_green(:,4);
z=all_green(:,5);
x_calib=((x.*transfer_mat(1,1))+(y.*transfer_mat(2,1)))+transfer_mat(3,1);
y_calib=((y.*transfer_mat(1,2))+(y.*transfer_mat(2,2)))+transfer_mat(3,2);
z_calib=z+b;
all_green_calib=[id,ts,x_calib,y_calib,z_calib];
save([fold_name file_name '_calib.txt'],'-ascii','-TABS','all_green_calib');
end
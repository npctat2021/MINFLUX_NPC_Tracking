%step-3: match green localizations with pore locations and pick green
% localizations with reference to the centers of the pore
function track_localize_whole_roi_MINFLUX
clc
clear
fold_name='H:\MINFLUXexportimport\Manuscript\MINFLUX  MATLAB programs\Code for Aligning Tracks with NPC\';
file_name='Tracksxyz3_calib';
half_thickness=300; % half thickness of the pore
radius_error=300; % radius+uncertainty
num_pore=43; %for total how many pores you want to analyze
all_track_calibrated=load([fold_name file_name '.txt']);
z=all_track_calibrated(:,5);
x_center=load([fold_name 'porex_center.txt']);
y_center=load([fold_name 'porey_center.txt']);
z_center=load([fold_name 'porez_center.txt']);
for i=1:num_pore 
   % first filtering
   ind1=find(z>z_center(i)-half_thickness & z<z_center(i)+half_thickness);
   track1=all_track_calibrated(ind1,:);
   xx=track1(:,3);
   % second filtering
   ind2=find(xx>x_center(i)-radius_error & xx<x_center(i)+radius_error);
   track2=track1(ind2,:);
   yy=track2(:,4);
   % third filtering
   ind3=find(yy>y_center(i)-radius_error & yy<y_center(i)+radius_error);
   track3=track2(ind3,:);
save([fold_name 'track to whole' num2str(i) '.txt'],'-ascii','-TABS','track3');
end
end
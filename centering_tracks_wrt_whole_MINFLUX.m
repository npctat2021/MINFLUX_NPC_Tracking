% Step4: Set all pore center to (0,0,0)
function centering_tracks_wrt_whole_MINFLUX
clc
clear
fold_name='H:\MINFLUXexportimport\Manuscript\MINFLUX  MATLAB programs\Code for Aligning Tracks with NPC\';
file_name='pore';
file_name1='track to whole';
num_pore=43; %for total how many pores you want
pore_all_z_center=load([fold_name file_name 'z_center.txt']);
pore_all_x_center=load([fold_name file_name 'x_center.txt']);
pore_all_y_center=load([fold_name file_name 'y_center.txt']);
for i=1:num_pore
    track=load([fold_name file_name1 num2str(i) '.txt']);
    if isempty(track)==1
        track_centered=[];
    else
    id=track(:,1);fr=track(:,2);x=track(:,3);y=track(:,4);z=track(:,5);
    x_centered=x-pore_all_x_center(i);
    y_centered=y-pore_all_y_center(i);
    z_centered=z-pore_all_z_center(i);
    track_centered=[id,fr,x_centered,y_centered,z_centered];
    end
    save([fold_name 'track_cen_wrt_whole' num2str(i) '.txt'],'-ascii','-TABS','track_centered');
end
end
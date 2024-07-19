%step-6: Merge MINFLUX tracks after rotation.
function merge_after_rotation_whole_MINFLUX
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='track to whole rotated';
num_pore=16; %for total how many pores you want
track=[];
for i=1:num_pore
    track1=load([fold_name file_name num2str(i) '.txt']);
    track=[track;track1];
end
save([fold_name 'track_merged_rotated_whole.txt'],'-ascii','-TABS','track');
end
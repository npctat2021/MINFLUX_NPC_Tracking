% Merge pores
function merge_after_rotation_MINFLUX_step7
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='pore';
file_name1=' pore_rotated';
num_pore=16; %% Mention the number of qualified pores from the clusters
pore=[];
for i=1:num_pore
    pore1=load([fold_name num2str(i) file_name1 '.txt']);
    pore=[pore;pore1];
end
save([fold_name 'pore_merged_rotated.txt'],'-ascii','-TABS','pore');
end
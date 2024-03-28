% Merge pores
function merge_after_rotation_MINFLUX_step7
clc
clear
fold_name='H:\MINFLUXexportimport\Manuscript\MINFLUX  MATLAB programs\Code for NPC Scaffold localization\';
file_name='pore';
file_name1=' pore_rotated';
num_pore=11; %for total how many pores you want
pore=[];
for i=1:num_pore
    pore1=load([fold_name num2str(i) file_name1 '.txt']);
    pore=[pore;pore1];
end
save([fold_name 'pore_merged_rotated.txt'],'-ascii','-TABS','pore');
end
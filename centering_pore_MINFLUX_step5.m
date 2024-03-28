%step-8: Merge pores after all kind of filtering
function centering_pore_MINFLUX_step5
clc
clear
fold_name='H:\MINFLUXexportimport\Manuscript\MINFLUX  MATLAB programs\Code for NPC Scaffold localization\';
file_name='pore';
file_name1='porebisquare';
num_pore=11; %for total how many pores you want
pore_all_z_center=load([fold_name file_name 'z_center.txt']);
pore_all_x_center=load([fold_name file_name 'x_center.txt']);
pore_all_y_center=load([fold_name file_name 'y_center.txt']);
for i=1:num_pore
    pore=load([fold_name num2str(i) file_name1 '.txt']);
    id=pore(:,1);ts=pore(:,2);x=pore(:,3);y=pore(:,4);z=pore(:,5);
    x_centered=x-pore_all_x_center(i);
    y_centered=y-pore_all_y_center(i);
    z_centered=z-pore_all_z_center(i);
    pore_centered=[id,ts,x_centered,y_centered,z_centered];
    save([fold_name num2str(i) 'pore_centered.txt'],'-ascii','-TABS','pore_centered');
    end
end
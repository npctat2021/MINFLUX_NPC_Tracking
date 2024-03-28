%% Fitting the phase histogram and find out the angle of rotation
function pore_rotation_MINFLUX_step6
clc
clear
fold_name='H:\MINFLUXexportimport\Manuscript\MINFLUX  MATLAB programs\Code for NPC Scaffold localization\';
file_name='pore_centered';
file_name2='rot_angle';
angle=load([fold_name file_name2 '.txt']);
num_pore=11; % This is the total number of pores you have analyzed
for w=1:1:num_pore
pore_raw=load([fold_name num2str(w) file_name '.txt']);
id=pore_raw(:,1);
ts=pore_raw(:,2);
x=pore_raw(:,3);
y=pore_raw(:,4);
z=pore_raw(:,5);
xx=x*cosd(angle(w)+45)+y*sind(angle(w)+45);
yy=-x*sind(angle(w)+45)+y*cosd(angle(w)+45);
all=[id,ts,xx,yy,z];
save([fold_name num2str(w) ' pore_rotated.txt'],'-ascii','-TABS','all');
end
end
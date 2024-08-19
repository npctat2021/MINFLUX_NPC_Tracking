%%Step5: Rotate localizations of each pore by its angle of rotation
function track_rotation_in_whole_MINFLUX
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='track_cen_wrt_whole';
file_name2='rot_angle';
angle=load([fold_name file_name2 '.txt']);
num_pore=16; % This is the total number of pores you have analyzed
for w=1:1:num_pore
track_raw=load([fold_name file_name num2str(w) '.txt']);
if isempty(track_raw)==1
    all=[];
else
id=track_raw(:,1);
fr=track_raw(:,2);
x=track_raw(:,3);
y=track_raw(:,4);
z=track_raw(:,5);
xx=x.*cosd(angle(w))+y.*sind(angle(w));
yy=-x.*sind(angle(w))+y.*cosd(angle(w));
all=[id,fr,xx,yy,z];
end
save([fold_name 'track to whole rotated' num2str(w) '.txt'],'-ascii','-TABS','all');
end
end
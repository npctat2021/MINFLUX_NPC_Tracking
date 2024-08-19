%% there is always a 8.4 degree inherent rotation of pore. this step compensates for that rotation of respective tracks. 
function Track_rotate_back_MINFLUX_step8
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='track_merged_rotated_whole';
pore_all=load([fold_name file_name '.txt']);
id=pore_all(:,1);
ts=pore_all(:,2);
x=pore_all(:,3);
y=pore_all(:,4);
z=pore_all(:,5);
pore=[];
for w=1:1:length(x)
xx=x(w)*cosd(8.4)+y(w)*sind(8.4);
yy=-x(w)*sind(8.4)+y(w)*cosd(8.4);
pore1=[id(w),ts(w),xx,yy,z(w)];
pore=[pore;pore1];
end
save([fold_name file_name '_back.txt'],'-ascii','-TABS','pore');
end
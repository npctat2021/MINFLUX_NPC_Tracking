%% step1: Manually select the cluster, upon running the program a window will open with scatter plots. Select the pores as rectangle. 
%% Double click inside the rectangle to save a cluster. Repeat the process until you are done selecting all the pores. Once you
%% are done save the picture and then close the figure. This will show an error in the end but ignore it.
function separate_cluster_MINFLUX
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='Nuclear Pore Model Data';
pixel_size=1.0;% not required for MINFLUX
all=load([fold_name file_name '.txt']);
id=all(:,1);% Track Id
tsa=all(:,2);% Time Stamp
ts=tsa*(10^3);% Converting time stamp from second to milisecond. 
x=all(:,3);
xx=x*(10^9);% Converting cooradinate from meter to nanometer scale. 
y=all(:,4);
yy=y*(10^9);% Converting cooradinate from meter to nanometer scale. 
z=all(:,5);
zz=z*(10^9)*0.668;% Applying z-scaling factor of the MINFLUX instrument. 
set(gca,'fontsize',16)
plot(xx,yy,'b.','MarkerSize',3)
k=1;
button=1;
while button==1
%% select rectangular
h=imrect;
position=wait(h)
rectangle('position',[position(1),position(2),position(3),position(4)],'edgecolor','b');
text(round(position(1))+44,round(position(2))+44,num2str(k),'color','r');
[i,j]=find(xx>position(1) & xx<position(1)+position(3) & yy>position(2) & yy<position(2)+position(4)); % finding the spots you select as elliptical boxes
id_roi=id(i);
ts_roi=ts(i)
x_roi=xx(i)*pixel_size;
y_roi=yy(i)*pixel_size;
z_roi=zz(i);
pore=[id_roi,ts_roi,x_roi,y_roi,z_roi];
save([fold_name num2str(k) 'cluster.txt'],'-ascii','-TABS','pore');
k=k+1;
end
end
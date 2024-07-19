% Calculation of frequency against bin to plot as a histogram
% (unnormalized & normalized)
function pore_rotation_MINFLUX_step3
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='pore_fortyfive';
num_pore=16;% Mention the number of qualified pores from the clusters
bin_center=[2.5:5:42.5];
bin_start=[0:5:40]';
bin_end=[5:5:45]';
for l=1:1:num_pore
pore_fortyfive=load([fold_name num2str(l) file_name '.txt']);
fortyfive=pore_fortyfive(:,1);
%int_rel=pore_fortyfive(:,1);
    p(1)=length(fortyfive(find(fortyfive>=bin_start(1) & fortyfive<bin_end(1))));
    p(2)=length(fortyfive(find(fortyfive>=bin_start(2) & fortyfive<bin_end(2))));
    p(3)=length(fortyfive(find(fortyfive>=bin_start(3) & fortyfive<bin_end(3))));
    p(4)=length(fortyfive(find(fortyfive>=bin_start(4) & fortyfive<bin_end(4))));
    p(5)=length(fortyfive(find(fortyfive>=bin_start(5) & fortyfive<bin_end(5))));
    p(6)=length(fortyfive(find(fortyfive>=bin_start(6) & fortyfive<bin_end(6))));
    p(7)=length(fortyfive(find(fortyfive>=bin_start(7) & fortyfive<bin_end(7))));
    p(8)=length(fortyfive(find(fortyfive>=bin_start(8) & fortyfive<bin_end(8))));
    p(9)=length(fortyfive(find(fortyfive>=bin_start(9) & fortyfive<bin_end(9)))); 
    p1=p./sum(p);
    phase_unnorm=[bin_center',p1'];
    save([fold_name num2str(l) 'phase_unnorm.txt'],'-ascii','-TABS','phase_unnorm');
    %%% Photon Normalized
    pn1=find(fortyfive>=bin_start(1) & fortyfive<bin_end(1));
    pn2=find(fortyfive>=bin_start(2) & fortyfive<bin_end(2));
    pn3=find(fortyfive>=bin_start(3) & fortyfive<bin_end(3));
    pn4=find(fortyfive>=bin_start(4) & fortyfive<bin_end(4));
    pn5=find(fortyfive>=bin_start(5) & fortyfive<bin_end(5));
    pn6=find(fortyfive>=bin_start(6) & fortyfive<bin_end(6));
    pn7=find(fortyfive>=bin_start(7) & fortyfive<bin_end(7));
    pn8=find(fortyfive>=bin_start(8) & fortyfive<bin_end(8));
    pn9=find(fortyfive>=bin_start(9) & fortyfive<bin_end(9));
    int(1)=sum(fortyfive(pn1));
    int(2)=sum(fortyfive(pn2));
    int(3)=sum(fortyfive(pn3));
    int(4)=sum(fortyfive(pn4));
    int(5)=sum(fortyfive(pn5));
    int(6)=sum(fortyfive(pn6));
    int(7)=sum(fortyfive(pn7));
    int(8)=sum(fortyfive(pn8));
    int(9)=sum(fortyfive(pn9));
    total_int=sum(int);
    int_normalized=int./total_int;
    phase_normalized=[bin_center',p1'];
    save([fold_name num2str(l) 'phase_norm.txt'],'-ascii','-TABS','phase_normalized');
end
end
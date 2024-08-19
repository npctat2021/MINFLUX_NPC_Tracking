% Calculation of frequency against bin to plot as a histogram
function pore_rotation_MINFLUX_step2
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='pore_ninety_normalized';
num_pore=16;% Mention the number of qualified pores from the clusters
for l=1:1:num_pore
data_pore_ninety=load([fold_name num2str(l) file_name '.txt']);
ninety=data_pore_ninety(:,1);
int_rel=data_pore_ninety(:,1)./3000;
fortyfive=[];
for m=1:1:length(ninety)
    if ninety(m)<-45
        fortyfive(m)=ninety(m)+90;
    elseif ninety(m)>=-45 && ninety(m)<0
        fortyfive(m)=ninety(m)+45;
    elseif ninety(m)>=0 && ninety(m)<45
        fortyfive(m)=ninety(m);
    elseif ninety(m)>=45
        fortyfive(m)=ninety(m)-45;
    else
        fortyfive(m)=0;
    end
end
fortyfive=fortyfive';
    pore_fortyfive=[fortyfive];
    save([fold_name num2str(l) 'pore_fortyfive.txt'],'-ascii','-TABS','pore_fortyfive');
end
end
%% Fitting the phase histogram and find out the angle of rotation
function pore_rotation_MINFLUX_step4_fitting
clc
clear
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='phase_norm';
func=inline('9^(-1)+20.6^(-1)*cosd(8*(x-8.4-p))','p','x');
num_pore=16; % % Mention the number of qualified pores from the clusters
theo=0:0.1:45;
for w=1:1:num_pore
pore_rot=load([fold_name num2str(w) file_name '.txt']);
phase=pore_rot(:,1);
frequency=pore_rot(:,2);
%% Fitting
angl(w)=lsqcurvefit(func,10,phase,frequency);
if angl(w)<0
    angle(w)=angl(w)+45;
else
    angle(w)=angl(w);
end
ang=angle(w)
phase_theo=func(ang,theo);
plot(phase,frequency,'or',theo,phase_theo,'b')
set(gca,'FontSize',20)
xlabel('angle (degree)','FontSize',20)
ylabel('frequency','FontSize',20)
pause(10)
close
end
rotation=angle';
save([fold_name 'rot_angle.txt'],'-ascii','-TABS','rotation');
end

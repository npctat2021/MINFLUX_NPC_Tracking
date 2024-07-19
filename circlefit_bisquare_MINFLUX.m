% step4: Least square (processed as bisquare) fitting of the pore as circle.
function circlefit_bisquare_MINFLUX
fold_name='E:\EMBL 3rd Visit\2nd week\New folder\20240524\20240524\cell1\';
file_name='pore';
num_pore=16; % Mention the number of qualified pores from the clusters
theta=0:0.01:2*pi;
pixel_size=1.0; %nm, not used for MINFLUX analysis.
for i=1:num_pore
    P=load([fold_name num2str(i) file_name '.txt']);
    id=P(:,1);
    fr=P(:,2);
x=P(:,3);
y=P(:,4);
z=P(:,5);
c = [x y ones(length(x),1)]\-(x.^2+y.^2); %least squares fit
xhat(i) = real(-c(1)/2);
yhat(i) = real(-c(2)/2);
rhat(i) = real(sqrt(xhat(i)^2+yhat(i)^2-c(3)));
% Exclude points for bisquare fitting
y_all_possib=[yhat(i)+sqrt(rhat(i).^2-(x-xhat(i)).^2),yhat(i)-sqrt(rhat(i).^2-(x-xhat(i)).^2)];
diff=y-y_all_possib;
y_fit=[];
for m=1:1:length(x)
    if abs(diff(m,1))<abs(diff(m,2))
        yfit1=y_all_possib(m,1);
    else
        yfit1=y_all_possib(m,2);
    end
    y_fit=[y_fit;yfit1];
end
y_fit=real(y_fit);
residuals=y-y_fit;
I = abs( residuals) < 2*std( residuals );
outliers = excludedata(x,y,'indices',I); %points to keep after excluding outliers
id2=id(outliers);
ts2=fr(outliers);
x2=x(outliers);
y2=y(outliers);
z2=z(outliers);
f=figure;
plot(x2,y2,'o')
axis equal;
hold on
c2 = [x2 y2 ones(length(x2),1)]\-(x2.^2+y2.^2); %least squares fit
x2hat(i) = real(-c2(1)/2);
y2hat(i) = real(-c2(2)/2);
r2hat(i) = real(sqrt(x2hat(i)^2+y2hat(i)^2-c2(3)));
points_x=repmat(x2hat(i),1,size(theta,2))+r2hat(i)*cos(theta);
points_y=repmat(y2hat(i),1,size(theta,2))+r2hat(i)*sin(theta);
plot(points_x,points_y,'r-');
pause(1)
close(f)
P2=[id2,ts2,x2,y2,z2];
save([fold_name num2str(i) file_name 'bisquare.txt'],'-ascii','-TABS','P2');
end
end

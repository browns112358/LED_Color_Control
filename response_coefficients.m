clear all
close all

%http://spectralworkbench.org/
input_spectra=importdata('input_spectra.txt');
%input_spectra=importdata('testlight1.txt');

LED_Spectra=importdata('LED_Spectra.txt');
cmf1=importdata('cmf1.txt');
cmf2=importdata('cmf2.txt');

lambda=input_spectra(:,1);
raw_s=input_spectra(:,2);
x=spline(cmf1(:,1),cmf1(:,2),LED_Spectra(:,1));
y=spline(cmf1(:,1),cmf1(:,3),LED_Spectra(:,1));
z=spline(cmf1(:,1),cmf1(:,4),LED_Spectra(:,1));
%x=x';
%y=y';
%z=z';

s=spline(lambda,raw_s,LED_Spectra(:,1));

figure(1)
hold on
plot(LED_Spectra(:,1),LED_Spectra(:,2),'k','LineWidth',2)%,'k')
plot(LED_Spectra(:,1),LED_Spectra(:,3),'r','LineWidth',2)%,'r')
plot(LED_Spectra(:,1),LED_Spectra(:,4),'y','LineWidth',2)%,'y')
plot(LED_Spectra(:,1),LED_Spectra(:,5),'g','LineWidth',2)%,'g')
plot(LED_Spectra(:,1),LED_Spectra(:,6),'b','LineWidth',2)%,'b')
title('Conference Room LED Spectra')
xlabel('Wavelength (nm)')
ylabel('Response')

plot(LED_Spectra(:,1),s,'b')

R=[LED_Spectra(:,2)';LED_Spectra(:,3)';LED_Spectra(:,4)';LED_Spectra(:,5)';LED_Spectra(:,6)'];
R=R';
alpha=lsqnonneg(R,s);%For no constraint on alpha: alpha=s*R'*(R*R')^(-1);
R=R';

alpha_applied=[alpha(1)*R(1,:);alpha(2)*R(2,:);alpha(3)*R(3,:);alpha(4)*R(4,:);alpha(5)*R(5,:)];
new_spectrum=sum(alpha_applied,1);
plot(LED_Spectra(:,1),new_spectrum,'r')
hold off

figure(2)
hold on
plot(LED_Spectra(:,1),x,'r')
plot(LED_Spectra(:,1),y,'g')
plot(LED_Spectra(:,1),z,'b')
hold off

% min_s=min(s);
% max_s=max(s);
% s=(s-min_s)./(max_s-min_s);
% 
% min_g=min(new_spectrum);
% max_g=max(new_spectrum);
% new_spectrum=(new_spectrum-min_g)./(max_g-min_g);

%input
x=2.380952*x;
y=2.380952*y;
z=2.380952*z;
test=sum(x.^2)/2330
xs=sum(x.*s)/size(s,1);
ys=sum(y.*s)/size(s,1);
zs=sum(z.*s)/size(s,1);

%generated
xg=sum(x.*new_spectrum')/size(new_spectrum,2);
yg=sum(y.*new_spectrum')/size(new_spectrum,2);
zg=sum(z.*new_spectrum')/size(new_spectrum,2);

M=[.41847 -.15866 -.082835;-.091169 .25243 .015708; .0009209 -.00254998 .17860];
rgb_s=M*[xs;ys;zs]
rgb_g=M*[xg;yg;zg]

% rgb_s=1.16*rgb_s.^(1/3)-.16
% rgb_g=1.16*rgb_g.^(1/3)-.16
% 
% rgb_g=rgb_g/255;
% rgb_s=rgb_s/255;

test_s=ones(5,6,3);
test_s(:,:,1)=rgb_s(1);
test_s(:,:,2)=rgb_s(2);
test_s(:,:,3)=rgb_s(3);
figure(3)
image(test_s)

test_g=ones(5,6,3);
test_g(:,:,1)=rgb_g(1);
test_g(:,:,2)=rgb_g(2);
test_g(:,:,3)=rgb_g(3);
figure(4)
image(test_s)


hold off


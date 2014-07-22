close all
clear all
%clc

red=importdata('TestData/red_LED.txt');
green=importdata('TestData/green_LED.txt');
blue=importdata('TestData/blue_LED.txt');
amber=importdata('TestData/amber_LED.txt');
white=importdata('TestData/white_LED.txt');

red=red(2:end,:);
green=green(2:end,:);
blue=blue(2:end,:);
amber=amber(2:end,:);
white=white(2:end,:);

white_lux=193;
red_lux=65;
green_lux=51;
blue_lux=44;
amber_lux=125;

cmf1=importdata('RequiredData/xyz_cmf_10deg.txt');

Wavelength=360:1:760;
figure(1)
plot(Wavelength,red(:,2),'LineWidth',2)

xcmf=spline(cmf1(:,1),cmf1(:,2),Wavelength);
xcmf(Wavelength < min(cmf1(:,1)))=0;
xcmf(Wavelength > max(cmf1(:,1)))=0;

ycmf=spline(cmf1(:,1),cmf1(:,3),Wavelength);
ycmf(Wavelength < min(cmf1(:,1)))=0;
ycmf(Wavelength > max(cmf1(:,1)))=0;

zcmf=spline(cmf1(:,1),cmf1(:,4),Wavelength);
zcmf(Wavelength < min(cmf1(:,1)))=0;
zcmf(Wavelength > max(cmf1(:,1)))=0;

figure(2)
hold on
plot(Wavelength,xcmf,'r')
plot(Wavelength,ycmf,'g')
plot(Wavelength,zcmf,'b')
hold off

%snorm=(s-min(s))./(max(s)-min(s))%s./(sum(s)/size(s,1));
%s=snorm;

%X=sum(xcmf.*s')/size(s,1)
% X=683*sum(s.*xcmf.*(red(2,1)-red(1,1)));
% %k=100/sum(s.*ycmf.*(input(2,1)-input(1,1)))
% %X=k*sum(s.*xcmf.*(input(2,1)-input(1,1)))
% 
%Y=sum(ycmf.*s')/size(s,1)
% Y=683*sum(s.*ycmf.*(red(2,1)-red(1,1)));
% %Y=k*sum(s.*ycmf.*(input(2,1)-input(1,1)))
% 
%Z=sum(zcmf.*s')/size(s,1)
% Z=683*sum(s.*zcmf.*(red(2,1)-red(1,1)));
%Z=k*sum(s.*zcmf.*(input(2,1)-input(1,1)))

k=683;%100/sum(green(:,2).*ycmf'.*(green(2,1)-green(1,1)));%1%.06;%
alpha_red=red_lux/(k*sum(red(:,2).*ycmf'.*(red(2,1)-red(1,1))));
%test=max(ycmf)
%alpha2=65/(k*sum(red(:,2).*ycmf'.*.5))
red(:,2)=alpha_red*red(:,2);

%k=100/sum(green(:,2).*ycmf'.*(green(2,1)-green(1,1)));
alpha_green=green_lux/(k*sum(green(:,2).*ycmf'.*(green(2,1)-green(1,1))));
green(:,2)=alpha_green*green(:,2);

%k=100/sum(blue(:,2).*ycmf'.*(blue(2,1)-blue(1,1)));
alpha_blue=blue_lux/(k*sum(blue(:,2).*ycmf'.*(blue(2,1)-blue(1,1))));
blue(:,2)=alpha_blue*blue(:,2);

%k=100/sum(amber(:,2).*ycmf'.*(amber(2,1)-amber(1,1)));
alpha_amber=amber_lux/(k*sum(amber(:,2).*ycmf'.*(amber(2,1)-amber(1,1))));
amber(:,2)=alpha_amber*amber(:,2);

%k=100/sum(white(:,2).*ycmf'.*(white(2,1)-white(1,1)));
alpha_white=white_lux/(k*sum(white(:,2).*ycmf'.*(white(2,1)-white(1,1))));
white(:,2)=alpha_white*white(:,2);

s=red(:,2);
X=k*sum(xcmf.*s')*(red(2,1)-red(1,1))
Y=k*sum(ycmf.*s')*(red(2,1)-red(1,1))
Z=k*sum(zcmf.*s')*(red(2,1)-red(1,1))

figure(3)
hold on
plot(Wavelength,red(:,2),'r')
plot(Wavelength,green(:,2),'g')
plot(Wavelength,blue(:,2),'b')
plot(Wavelength,amber(:,2),'y')
plot(Wavelength,white(:,2),'k')

% XYZ_factor=100/Y;
% X=XYZ_factor*X
% Y=XYZ_factor*Y
% Z=XYZ_factor*Z

% X=trapz(Wavelength,xcmf.*s)
% Y=trapz(Wavelength,ycmf.*s)
% Z=trapz(Wavelength,zcmf.*s)

%check validity
% x=X/(X+Y+Z)
% y=Y/(X+Y+Z)
% 
% Y=100
% X=x*Y/y
% Z=(1-x-y)*Y/y

% xe=.3366;
% ye=.1735;
% A0=-949.86315;
% A1=6253.80338;
% t1=.92159;
% A2=28.70599;
% t2=.20039;
% A3=.00004;
% t3=.07125;
% n=(x-xe)/(y-ye);
% 
% CCT=A0+A1*exp(-n/t1)+A2*exp(-n/t2)+A3*exp(-n/t3)

M=[ 2.0413690 -0.5649464 -0.3446944;
-0.9692660  1.8760108  0.0415560;
 0.0134474 -0.1183897  1.0154096];

% M=[.41847 -.15866 -.082835;-.091169 .25243 .015708; .0009209 -.00254998 .17860];
%  M=[2.6422874 -1.2234270 -0.3930143;...
%  -1.1119763  2.0590183  0.0159614;...
%   0.0821699 -0.2807254  1.4559877]

% M=[ 1.9099961 -0.5324542 -0.2882091;...
% -0.9846663  1.9991710 -0.0283082;...
%  0.0583056 -0.1183781  0.8975535]
RGB=M*[X;Y;Z]

%RGB=255*RGB/max(RGB)

% T=(1/.177697)*[.49 .31 .2;.17697 .81240 .01063; 0 .01 .99];
% test=T*RGB;
test_s=ones(1,2,3);
test_s(:,1,1)=RGB(1)/255
test_s(:,1,2)=RGB(2)/255
test_s(:,1,3)=RGB(3)/255
figure(4)
image(test_s)
% 
% R_50=R*255;
% G_150=G*255;
% B_255=B*255;

%R=1.16*R.^(1/3)-.16
%G=1.16*G.^(1/3)-.16
%B=1.16*B.^(1/3)-.16
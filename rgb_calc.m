close all
clear all
clc

input=importdata('red_LED.txt');
cmf1=importdata('xyz_cmf.txt');

figure(1)
plot(input(:,1),input(:,2),'LineWidth',2)

xcmf=spline(cmf1(:,1),cmf1(:,2),input(:,1));
xcmf(input(:,1) < min(cmf1(:,1)))=0;
xcmf(input(:,1) > max(cmf1(:,1)))=0;

ycmf=spline(cmf1(:,1),cmf1(:,3),input(:,1));
ycmf(input(:,1) < min(cmf1(:,1)))=0;
ycmf(input(:,1) > max(cmf1(:,1)))=0;

zcmf=spline(cmf1(:,1),cmf1(:,4),input(:,1));
zcmf(input(:,1) < min(cmf1(:,1)))=0;
zcmf(input(:,1) > max(cmf1(:,1)))=0;

figure(2)
hold on
plot(input(:,1),xcmf,'r')
plot(input(:,1),ycmf,'g')
plot(input(:,1),zcmf,'b')
hold off

s=input(:,2);
%snorm=(s-min(s))./(max(s)-min(s))%s./(sum(s)/size(s,1));
%s=snorm;

%X=sum(xcmf.*s)/size(s,1)
X=683*sum(s.*xcmf.*(input(2,1)-input(1,1)))
%k=100/sum(s.*ycmf.*(input(2,1)-input(1,1)))
%X=k*sum(s.*xcmf.*(input(2,1)-input(1,1)))

%Y=sum(ycmf.*s)/size(s,1)
Y=683*sum(s.*ycmf.*(input(2,1)-input(1,1)))
%Y=k*sum(s.*ycmf.*(input(2,1)-input(1,1)))

%Z=sum(zcmf.*s)/size(s,1)
Z=683*sum(s.*zcmf.*(input(2,1)-input(1,1)))
%Z=k*sum(s.*zcmf.*(input(2,1)-input(1,1)))

lux=65;
alpha=lux/683*sum(s.*ycmf.*(input(2,1)-input(1,1)))
s=alpha*s

figure(3)
plot(input(:,1),s)
% XYZ_factor=100/Y;
% X=XYZ_factor*X
% Y=XYZ_factor*Y
% Z=XYZ_factor*Z

% X=trapz(input(:,1),xcmf.*s)
% Y=trapz(input(:,1),ycmf.*s)
% Z=trapz(input(:,1),zcmf.*s)

%check validity
x=X/(X+Y+Z)
y=Y/(X+Y+Z)

% Y=100;
% X=x*Y/y;
% Z=(1-x-y)*Y/y;

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

%M=[.41847 -.15866 -.082835;-.091169 .25243 .015708; .0009209 -.00254998 .17860];
% M=[2.6422874 -1.2234270 -0.3930143;...
% -1.1119763  2.0590183  0.0159614;...
%  0.0821699 -0.2807254  1.4559877]

% M=[ 1.9099961 -0.5324542 -0.2882091;...
% -0.9846663  1.9991710 -0.0283082;...
%  0.0583056 -0.1183781  0.8975535]
% RGB=M*[X;Y;Z]

%RGB=255*RGB/max(RGB)

% T=(1/.177697)*[.49 .31 .2;.17697 .81240 .01063; 0 .01 .99];
% test=T*RGB;
% test_s=ones(1,1,3);
% test_s(:,:,1)=R;
% test_s(:,:,2)=G;
% test_s(:,:,3)=B;
% figure(3)
% image(test_s)
% 
% R_50=R*255;
% G_150=G*255;
% B_255=B*255;

%R=1.16*R.^(1/3)-.16
%G=1.16*G.^(1/3)-.16
%B=1.16*B.^(1/3)-.16
clear all
clc

Wavelength=360:1:760;
Wavelength=Wavelength';

%Import and set up required data for calculations
illuminant_data_xy_2deg=importdata('RequiredData/illuminants_xy_2deg.txt');
illuminant_data_xy_10deg=importdata('RequiredData/illuminants_xy_10deg.txt');
DSPD=importdata('RequiredData/DSPD.txt');
CIETCS1nm=importdata('RequiredData/CIETCS1nm.txt');

temp=Wavelength;
for i=2:size(DSPD,2)
    data=spline(DSPD(:,1),DSPD(:,i),Wavelength);
    data(Wavelength < min(DSPD(:,1)))=0;
    data(Wavelength > max(DSPD(:,1)))=0;
    temp=[temp data];
end
DSPD=temp;

temp=Wavelength;
for i=2:size(CIETCS1nm,2)
    data=spline(CIETCS1nm(:,1),CIETCS1nm(:,i),Wavelength);
    data(Wavelength < min(CIETCS1nm(:,1)))=0;
    data(Wavelength > max(CIETCS1nm(:,1)))=0;
    temp=[temp data];
end
CIETCS1nm=temp;

%3 columns: kelvin, u, v with 1 kelvin resolution. Credit pspectro 
uvbbCCT=importdata('RequiredData/uvbbCCT.txt');

%http://www.cvrl.org/cmfs.htm
cmf=importdata('RequiredData/xyz_cmf_2deg.txt');

xcmf=spline(cmf(:,1),cmf(:,2),Wavelength);
xcmf(Wavelength < min(cmf(:,1)))=0;
xcmf(Wavelength > max(cmf(:,1)))=0;

ycmf=spline(cmf(:,1),cmf(:,3),Wavelength);
ycmf(Wavelength < min(cmf(:,1)))=0;
ycmf(Wavelength > max(cmf(:,1)))=0;

zcmf=spline(cmf(:,1),cmf(:,4),Wavelength);
zcmf(Wavelength < min(cmf(:,1)))=0;
zcmf(Wavelength > max(cmf(:,1)))=0;

cmf=[xcmf ycmf zcmf];

in1=importdata('TestData/red_LED.txt');
in2=importdata('TestData/green_LED.txt');
in3=importdata('TestData/blue_LED.txt');
in4=importdata('TestData/amber_LED.txt');
in5=importdata('TestData/white_LED.txt');

in=[in1(:,2) in2(:,2) in3(:,2) in4(:,2) in5(:,2)];
lux=in(1,:);
in(1,:)=[];
for i=1:5
        k=683;
        coeff=in(1,i)/(k*sum(in(:,i).*cmf(:,2).*(Wavelength(2,1)-Wavelength(1,1))));
        in(:,i)=coeff*in(:,i);
end

in1=in(:,1);
in2=in(:,2);
in3=in(:,3);
in4=in(:,4);
in5=in(:,5);
testsourcespd=[Wavelength 3*(7.3688*in1+16.7171*in2+76.1477*in3+5.2255*in4+13.2734*in5)];

k=683;
X=k*sum(xcmf.*testsourcespd(:,2)*(Wavelength(2)-Wavelength(1)));
Y=k*sum(ycmf.*testsourcespd(:,2)*(Wavelength(2)-Wavelength(1)));
Z=k*sum(zcmf.*testsourcespd(:,2)*(Wavelength(2)-Wavelength(1)));

u_prime=4*X/(X+15*Y+3*Z);
v_prime=9*Y/(X+15*Y+3*Z);

%credit pspectro getuvbbCCT.m
finddistance = sqrt((u_prime-uvbbCCT(:,2)).^2+(v_prime-uvbbCCT(:,3)).^2);
[mindistance,row] = min(finddistance);

CCT = uvbbCCT(row,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
range=Wavelength;

    %blackbody spd
    if CCT <= 5000
        c1 = 3.7418e-16;
        c2 = 1.438775225e-2;
        refspd = horzcat(range,c1./(range.^5.*(exp(c2./(range.*CCT))-1)));
        
    %daylight spd    
    elseif CCT > 5000
        %linearly interpolate DSPD
        %DSPD = horzcat(range',interp1(DSPD(:,1),DSPD(:,[2 3 4]),range,'linear'));

        daylightspd = zeros(length(range),2);

        %calculate x_d,y_d based on input color temperature
        if CCT <= 7000
            xd = .244063 + .09911*(1e3/CCT) + 2.9678*(1e6/(CCT^2)) - 4.6070*(1e9/(CCT^3));
        else 
            xd = .237040 + .24748*(1e3/CCT) + 1.9018*(1e6/CCT^2) - 2.0064*(1e9/CCT^3);
        end

        yd = -3.000*xd^2 + 2.870*xd - 0.275;

        %calculate relatative SPD
        M = 0.0241 + 0.2562*xd - 0.7341*yd;
        M1 = (-1.3515 - 1.7703*xd + 5.9114*yd)/M;
        M2 = (0.03000 - 31.4424*xd + 30.0717*yd)/M;

        refspd = horzcat(DSPD(:,1),DSPD(:,2) + M1.*DSPD(:,3) + M2.*DSPD(:,4));    
    end 
     
%     startval = find(refspd(:,1) == min(range));
%     endval = find(refspd(:,1) == max(range));

    %normalize spd around given wavelength
    %nrefspd = horzcat(range',1.*(input(:,2)./refspd(refspd(:,1) == wavelength,2)));

    
    
    referencespd=refspd
    
    %compute object color tristimulus data for test source and reference
    testXYZ= zeros(3,15);
    referenceXYZ = zeros(3,15);

    %calculate normalization constant k for perfect diffuse reflector of source
    ktest = 100./sum(testsourcespd(:,2).*cmf(:,2));
    kreference = 100./sum(referencespd(:,2).*cmf(:,2));

    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            testXYZ(j,i) = ktest.*sum(CIETCS1nm(:,i).*cmf(:,j).*testsourcespd(:,2));
        end
    end

    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            referenceXYZ(j,i) = kreference.*sum(CIETCS1nm(:,i).*cmf(:,j).*referencespd(:,2));
        end
    end
    
%     %reformat spds for functions
%     testXYZ = testXYZ';
%     referenceXYZ = referenceXYZ';
% 
%     %calculate chromaticity coordinates first is xy, then convert to uv
%     testxyzsamples = getxyz(testXYZ);
%     referencexyzsamples = getxyz(referenceXYZ);
% 
%     uvtestsamples = xytouv(testxyzsamples);
%     uvreferencesamples = xytouv(referencexyzsamples);
% 
%     %apply von Kries chromatic adaptation
%     %first calculate c and d for both sources
%     %this requires calculating the chromaticity in uv for the test source and
%     %reference source
% 
%     uvtestsource = xytouv(getxyz(gettristimulus2degn(testsourcespd,range)));
%     %make sure yvtestsource is last sample (full spd)
%     uvtestsource = uvtestsource(end,:);
% 
%     uvreferencesource = xytouv(getxyz(gettristimulus2degn(referencespd,range)));
% 
%     %convert that last sample to [c_ref d_ref] and [c_test d_ref]
%     cdtestsource = uvtocd(uvtestsource);
%     cdreferencesource = uvtocd(uvreferencesource);
% 
%     %convert TCS samples illuminated by test light to [c_test_i d_test_i]
%     cdtestsamples = uvtocd(uvtestsamples);
% 
%     %apply chromatic transform 
%     % c_rt = cdreferencesource(:,1)/cdtestsource(:,1);
%     % d_rt = cdreferencesource(:,2)/cdtestsource(:,2);
%     % 
%     % uc_num = 10.872+(.404*c_rt.*cdtestsamples(:,1))-(4*d_rt.*cdtestsamples(:,2));
%     % uc_den = 16.518+(1.481*c_rt.*cdtestsamples(:,1))-(d_rt.*cdtestsamples(:,2));
%     % uc = uc_num./uc_den;
%     % 
%     % vc_num = 5.520;
%     % vc_den = 16.518+(1.481*c_rt.*cdtestsamples(:,1))-(d_rt.*cdtestsamples(:,2));
%     % 
%     % vc = vc_num./vc_den;
% 
%     % uc_num = 10.872+(.404* cdreferencesource(:,1))-(4*cdreferencesource(:,2));
%     % uc_den = 16.518+(1.481* cdreferencesource(:,1))-(cdreferencesource(:,2));
% 
%     uc = (10.872+.404.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-4.*(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2))...
%         ./(16.518+1.481.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2));
% 
%     vc = 5.520./(16.518+1.481.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2));
% 
%     %create chromatically adapted uv matrix
%     uvc = horzcat(uc,vc);
% 
%     %move uv coordinates into CIE1964 UVW color space
% 
%     % %calculate Luv for object colors
%     % Wtestcr = 116.*((testXYZ(:,2)./100).^(1/3))-16;
%     % Utestcr = 13.*Wtestcr.*(uvtestsamples(:,1)-uvreferencesource(:,1));
%     % Vtestcr = 13.*Wtestcr.*(uvtestsamples(:,2)-uvreferencesource(:,2));
%     % UVWtestcr = horzcat(Utestcr,Vtestcr,Wtestcr);
%     % 
%     % %calculate Luv for reference illumant object colors
%     % Wref = 116.*((testXYZ(:,2)./100).^(1/3))-16;
%     % Uref = 13.*Wref.*(uvreferencesamples(:,1)-uvreferencesource(:,1));
%     % Vref = 13.*Wref.*(uvreferencesamples(:,2)-uvreferencesource(:,2));
%     % UVWref = horzcat(Uref,Vref,Wref);
% 
%     %calculate UVW for chromatically adapted object colors
%     Wtestcr = 25.*(testXYZ(:,2).^(1/3))-17;
%     Utestcr = 13.*Wtestcr.*(uvc(:,1)-uvreferencesource(:,1));
%     Vtestcr = 13.*Wtestcr.*(uvc(:,2)-uvreferencesource(:,2));
%     UVWtestcr = horzcat(Utestcr,Vtestcr,Wtestcr);
% 
%     %calculate UVW for reference illumance object colors
%     Wref = 25.*(referenceXYZ(:,2).^(1/3))-17;
%     Uref = 13.*Wref.*(uvreferencesamples(:,1)-uvreferencesource(:,1));
%     Vref = 13.*Wref.*(uvreferencesamples(:,2)-uvreferencesource(:,2));
%     UVWref = horzcat(Uref,Vref,Wref);
% 
%     deltaE = sqrt((UVWtestcr(:,1)-UVWref(:,1)).^2+(UVWtestcr(:,2)-UVWref(:,2)).^2+(UVWtestcr(:,3)-UVWref(:,3)).^2);
%     R = 100-(4.6.*deltaE);
%     Ra = (sum(R(1:8,:))/8);
%     % Ytest
%     % Ztest
% 
% %credit pspectro
% %function nrefspd = get_nrefspd(CCT,DSPD,range,wavelength)

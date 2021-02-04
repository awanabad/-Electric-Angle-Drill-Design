%Clearing Command Window 
clc;
clear all;

%Computed Variables From Gear Code 
WBt=725.6; %Gear Forces, bevel and helical
WBr=118.1; 

dB=1.5; %Gear pitch diameters

%Shaft distances between points of interest
L1=1; 
L2=3;  
Lf=0.5; %distance to critical location 

%***********************************************
%Reaction Forces
RBy=(WBr*L1)/L2; %Sum of moments = 0
RBz=(WBt*L1)/L2;
RAy= WBr-RBy; %Sum of forces = 0
RAz=WBt-RBz; 
Tm= WBt*(dB/2); %Torque on shaft 

%***********************************************
%Shear and Moment Diagrams
subplot(3,2,1)
x = linspace(0,L2); %Shear in x-z plane
Vxz = RAz*(x>=0)-WBt*(x>L1)+RBz*(x>=L2);
plot(x,Vxz)
xlabel ('Distance (in)');
ylabel ('Shear (lbf)');
title('Vxz')

subplot(3,2,2) %Moment in x-z plane 
Mxz = RAz*x-WBt*(x-L1).*(x>L1);
plot(x,Mxz)
xlabel ('Distance (in)');
ylabel ('Moment (lbf*in)');
title('Mxz')

subplot(3,2,3) %Shear in x-y plane
Vxy = RAy*(x>=0)-WBr*(x>L1)+RBy*(x>=L2);
plot(x,Vxy)
xlabel ('Distance (in)');
ylabel ('Shear (lbf)');
title('Vxy')

subplot(3,2,4) %Moment in x-y plane
Mxy = RAy*x-WBr*(x-L1).*(x>L1);
plot(x,Mxy)
xlabel ('Distance (in)');
ylabel ('Moment (lbf*in)');
title('Mxy')

subplot(3,2,5)
Mtot = sqrt((Mxy.^2)+(Mxz.^2));
plot(x,Mtot)
xlabel ('Distance (in)');
ylabel ('Moment (lbf*in)');
title('Mtot')

%***********************************************
%Stress Concentration at Shoulder
MaXZ= -RAz*L1+(WBt-RAz)*(Lf-L1);
MaXY= RAy*L1+(-WBr+RAy)*(Lf-L1);

Ma = sqrt((MaXZ)^2+(MaXY)^2); 
Ta=0;
Mm=0;

%***********************************************
%Notch Sensitivity 
kt=1.7; %Well-rounded shoulder fillet (r/d = 0.1), Table 7-1  
kts=1.5;
kf=1.7; %Assume Kf = Kt and Kfs = Kts for conservative trial
kfs=1.5;

%***********************************************
%Material = 1020 CD Steel 
Sut=68; %kpsi
%Sy=0; 
SeP=Sut/2; %Eq 6-8 

n=1.5; %target safety factor

%***********************************************
%Surface Factor
a=2.7; %Machined
b=-0.265; 
ka = a*(Sut)^b; %Eq 6-19

%***********************************************
%Assumptions until diameter is found
kb=0.9; 
kc=1;
kd=1;
ke=1;

se = SeP*ka*kb; %Endurance limit, Eq 6-18

%***********************************************
%Use DE-Goodman for trial diameter
A = sqrt(4*(kf*Ma)^2+3*(kfs*Ta)^2);
B = sqrt(4*(kf*Mm)^2+3*(kfs*Tm)^2);

d= ((16*n/pi)*(A/(se*10^3)+B/(Sut*10^3)))^(1/3);

%***********************************************
%New Dimensions
dnew = 1; %Greater than trial diameter
dr = 1.5; %D/d ratio
D=dnew*dr;

fr = 0.1; %r/d ratio
r = dnew*fr;

%***********************************************
%Corrected Marin Factors
Kt = 1.7; %Fig A-15-9
q=0.77; %Fig 6-20
Kf = 1 + q*(Kt-1);

Kts = 1.42; %Fig A-15-8
qs = 0.78; %Fig 6-21
Kfs = 1 + qs*(Kts-1);

Kb = 0.879*(dnew)^-0.107; %Size Factor, Eq 6-20

Se = SeP*ka*Kb; %Endurance limit, Eq 6-18

%***********************************************
%Shaft Stresses
SigmaA = 32*Kf*Ma/(pi * dnew^3); %Eq 7-5
SigmaM = sqrt(3)*16*Kfs*Tm/(pi * dnew^3); %Eq 7-6

nf = (SigmaA/(Se*10^3) + SigmaM/(Sut*10^3))^-1; 

%***********************************************
fprintf('The minimum diameter at the critical location is: (inches) %s\n', d') 
fprintf(1, '\n');
fprintf('The selected diameter for D1 and D3 is: (inches) %s\n', dnew') 
fprintf('The selected diameter for D2 is: (inches) %s\n', D')
fprintf(1, '\n');
fprintf('The alternating stress is: (psi) %s\n', SigmaA')
fprintf('The midrange stress is: (psi) %s\n', SigmaM')
fprintf('With a safety factor of: %s\n', nf')

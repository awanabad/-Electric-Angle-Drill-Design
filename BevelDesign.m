%Clearing Command Window 
clc;
clear all;

%Priori Decisions
mG=2; %gear  ratio
mGH = 2.147; %helical gear reduction
Nl= 4.8*10^6/mGH; %load cycles, reduced life cycle due to 1st gear reduction
R=0.90; %reliability

%***********************************************
%Stress Cycle Factors (Gear and Pinion Respectively)
Clg=3.4822*(Nl/mG)^-0.0602; %For pitting resistance (Eq 15-14)
Clp=3.4822*(Nl)^-0.0602;

Klg=1.683*(Nl/mG)^-0.0323; %For bending strength (Eq 15-15)
Klp=1.683*(Nl)^-0.0323;

%***********************************************
%Reliability Factors
Kr= 0.70-0.15*log(1-R); %(Eq 15-20)
Cr=sqrt(Kr);

%***********************************************
%Temperature Factors
KT=1; %Assume room temperature (Eq 15-18)
Ct=KT;

%***********************************************
%Design and Safety Factors 
n=1.5;
Sf=2;
Sh=sqrt(2);

%***********************************************
%Tooth system
pAngle=pi/9; %radians, normal pressure angle
Np=15; %Number of pinion teeth 

if round(mG*Np)<mG*Np %round up to nearest integer
    Ng=round(mG*Np)+1;
else
    Ng=round(mG*Np);
end

Kx=1; %Straight bevel gears
Cxc = 1.5; %Properly crowned teeth
gamma= atan(Np/Ng); %radians (Figure 15-14)
Gamma= atan(Ng/Np); 

%***********************************************
%Geometry Factors 
I=0.07; %Fig 15-6
Jp=0.22; %Fig 15-7
Jg=0.18;

%***********************************************
%Decision1: Trial Diametral Pitch 
Pd=10;
np=200/mGH; %Input rpm (= motor rpm divided by helical gear reduction) 
hp=600/746; %600 Watts converted to horsepower, output power assuming no power losses

if Pd > 16
    Ks = 0.5; %Size factor, Eq 15-10
else
    Ks=0.4867+0.2132/Pd; 
end

%Pitch diameter of pinion and gear respectively
dp=Np/Pd;
dg=dp*mG;

vt=(pi*dp*np)/12; %Pitch-line velocity
Wt=33000*hp/vt; %Transmitted Force

Ao=dp/(2*sin(gamma)); %Cone Distance, Eq 15-25

Fmin=min(0.3*Ao,10/Pd); %Minimum face width, Eq 15-24

%***********************************************
%Diametral Pitch Iterations and Minimum Face Width

fprintf(1, '\n');
fprintf('*****************************************************************\n');
fprintf('Pitch Diameters (Based on Diametral Pitch)\n');
fprintf('*****************************************************************\n');
fprintf(1, '\n');
fprintf('Diametral Pitch is: (inches) %s\n', Pd);
fprintf('Pitch Diameter of Pinion is: (inches) %s\n', dp);
fprintf('Pitch Diameter of Gear is: (inches) %s\n', dg);

fprintf(1, '\n');
fprintf('*****************************************************************\n');
fprintf('Minumum Face Width Requirement\n');
fprintf('*****************************************************************\n');
fprintf(1, '\n');
fprintf('The face width must be greater than: (inches) %s\n', Fmin); 

%***********************************************
%Decision2: Let Fnew > F
Fnew=1.4;

if Fnew < 0.5
    Cs = 0.5; %Size Factor for Pitting Resistance, Eq 15-9
else
    Cs=0.125*Fnew+0.4375; 
end

Kmb=1.25; %neither member straddle mounted
Km=Kmb+0.0036*(Fnew)^2; %Load-Distribution Factor, Eq 15-11

%***********************************************
%Decision3: transmission accuracy of Qv=6 
%Dynamic Factor
Qv=6;
B=0.25*(12-Qv)^(2/3); %Eq 15-6
A=50+56*(1-B);
Kv= ((A+sqrt(vt))/A)^B; %Eq 15-5

%***********************************************
%Decision4: Pinion/Gear Material Treatment, carburized and case hardened steel
Sac=200000; %Table 15-4
Sat=40000; %Table 15-6

Ko=1.75; %Overload Factor, uniform input and heavy shock ouput

%***********************************************
%Gear Bending
StG= (Wt/Fnew)*Pd*Ko*Kv*((Ks*Km)/(Kx*Jg)); %Bending stress, Eq 15-3

SwtG= Sat*Klg/(Sf*KT*Kr); %Bending strength, Eq 15-4

ActualSF1= 2*(SwtG/StG); %Safety factor

%***********************************************
%Pinion Bending

StP=StG*(Jg/Jp); %Bending stress

SwtP= Sat*Klp/(Sf*KT*Kr); %Bending strength

ActualSF2= 2*(SwtP/StP); %Safety Factor

%***********************************************
%Gear Wear
Cp=2290; %Elastic coefficient of steel
Sc=Cp*((Wt/(Fnew*dp*I))*Ko*Kv*Km*Cs*Cxc)^(1/2); %Contact Stress, Eq 15-1

Ch=1; %Hardness Ratio Factor, assume 1
SwcG = Sac*Clg*Ch/(Sh*KT*Cr); %Contact Strength, Eq 15-2

ActualSF3=2*(SwcG/Sc)^2; %Safety Factor

%***********************************************
%Pinion Wear

SwcP =Sac*Clp*Ch/(Sh*KT*Cr); %Contact Strength

ActualSF4=2*(SwcP/Sc)^2; %Safety Factor

%***********************************************
%Stress Analysis
fprintf(1, '\n');
fprintf('*****************************************************************\n');
fprintf('Stress Analysis Results\n');
fprintf('*****************************************************************\n');
fprintf(1, '\n');
fprintf('Face Width is: (inches) %s\n', Fnew);
fprintf('Based on this, the stresses are\n');
fprintf(1, '\n');

fprintf('For Gear:\n');
fprintf('Bending Stress: (psi) %s\n', StG);
fprintf('Safety Factor: %s\n', ActualSF1);
fprintf('Contact Stress: (psi) %s\n', Sc);
fprintf('Safety Factor: %s\n', ActualSF3);
fprintf(1, '\n');
fprintf('For Pinion:\n');
fprintf('Bending Stress: (psi) %s\n', StP);
fprintf('Safety Factor: %s\n', ActualSF2);
fprintf('Contact Stress: (psi) %s\n', Sc);
fprintf('Safety Factor: %s\n', ActualSF4);
fprintf(1, '\n');

%***********************************************
%Gear Loads
Wr = Wt*tan(pAngle)*cos(Gamma); %radial load, Eq 13-38
Wa = Wt*tan(pAngle)*sin(Gamma); %axial load
fprintf('*****************************************************************\n');
fprintf('Bevel Gear Loads\n');
fprintf('*****************************************************************\n');
fprintf(1, '\n');
fprintf('Transverse Load is: (lbf) %s\n', Wt);
fprintf('Radial Load is: (lbf) %s\n', Wr);
fprintf('Axial Load is: (lbf) %s\n', Wa);
fprintf(1, '\n');












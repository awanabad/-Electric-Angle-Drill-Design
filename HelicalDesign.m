%Clearing Command Window 
clc;
clear all;

%Given Powers Specifications
Pow= 600; %Input Motor Power (W)
HorsePow= Pow/746; %Motor Power in Horse Power 

%Priori Decisions (Selected Arbitrarily) 
mG = 2.147; %Gear Ratio 
Np=15; %Number of Pinion Teeth 
if round(mG*Np)<mG*Np %Number of Gear Teeth, round up to nearest integer
    Ng=round(mG*Np)+1;
else
    Ng=round(mG*Np);
end

Psi=pi/6; %Helix Angle (radian)
Phi=pi/9; %Normal Pressure Angle (radians) 
Pn =20; %Normal Diametrical Pitch 

Ko=1.75; %Overload Factor (Heavy Shock Ooutput/ Uniform Input)
n=1.5; %Design Factor (Given)  
Kr=0.85; %Reliability Factor (From Table 14-10, Using Given R= 0.9) 
Qv=6; % Assumed Quality Factor (Grade 1 Material)

np = 400/2; %half of no-load speed

%***********************************************
%Calculated Gear Dimensions
     
Pt= Pn*cos(Psi); %Transverse Diamteter Pitch (calculated) (Eq 13-18) 
dp = Np/Pt; %Pinion Pitch Diameter
dg = Ng/Pt; %Gear Pitch Diameter

%***********************************************
%Normal Diametral Pitch Iterations

fprintf(1, '\n');
fprintf('*****************************************************************\n');
fprintf('Pitch Diameters (Based on Normal Diametral Pitch)\n');
fprintf('*****************************************************************\n');
fprintf(1, '\n');
fprintf('Normal Diametral Pitch is: (inches) %s\n', Pn);
fprintf('Pitch Diameter of Pinion is: (inches) %s\n', dp);
fprintf('Pitch Diameter of Gear is: (inches) %s\n', dg);

%***********************************************
%Factor Assumptions
 
Cf = 1; %Surface Condition Factor 
Kt =1; %Temperature Factor 
Kb=1; %Rim-Thickness Factor: assume  mB >= 1.2
      %mB is ratio (Rim Height : Tooth Height) 

%***********************************************
%Calculated Transmitted Force 

V = (pi*dp*np)/12; %Pitch Line Velocity
Wt = (33000*HorsePow)/V; %Transmitted Force (calculated for Power = Force * Vel) 

%***********************************************
%Dynamic Factor Calculation

B =0.25*(12-Qv)^(2/3);
A=50+56*(1-B);
Kv=((A+sqrt(V))/A)^B; %Eq 14 - 27 and 14 - 28

%***********************************************
%Stress Cycle Calculation
N = 4.8*10^6; %Number of Cycles 

%Stress Cycle Factors (Pinion) (Fig 14 - 14 and 14 - 15) 
Ynp = 3.517*(N)^(-0.0817);  %Nitrided
Znp = 1.249*(N)^(-0.0138);  %Nitrided
%Stress Cycle Factors (Gear)
Yng = 3.517*(N/3)^(-0.0817); %Nitrided
Zng = 1.249*(N/3)^(-0.0138); %Nitrided

%***********************************************
%Size Factor
y = 0.322; %Table 14-2
F = (4*pi)/Pt; %assumption (Helical Gear FW recommendation 3-5 times > trans cir pitch) 
%  pt = pi/Pt 
Ks= 1.192*(F*sqrt(y)/Pt)^0.0535; %Eq a, Sec 14 - 10 

%***********************************************
%Load Distribution Factor
Ce=1; %
Cmc=1; %Factor for Uncrowned Teeth (Eq 14 - 31)
Cpf = (F/(10*dp))-0.0375+0.0125*F; %Factor for Face Width (Eq 14 - 32)
Cpm=1; %Factor for Straddle Mounted Pinion (Eq 14 - 33)

%Cma Calculation (Eq 14 - 34) 
%Empirical Constants for Commerical Enclosed Units (Table 14 - 9)
Al= 0.127; 
Bl= 0.0158; 
Cl = -0.93*10^(-4); 
Cma = Al+Bl*F+Cl*F^2;    %(Different A B than Dyn Factor Calc) 

%Load Distribution Factor Calculations 
Cmf = 1+Cmc*(Cpf*Cpm+Cma*Ce); %Face Load Distribution Factor (Eq 14 - 30)
Km = Cmf; %Load Distribution Factor (Eq 14 - 30)

%***********************************************
%Geometry Factor 'I' (Eq 14 - 23)

Phit = atan(tan(Phi)/cos(Psi)); %Transverse Pressure Angle (Eq 13 - 19) 
PN = (pi/Pn)*cos(Phi); %Normal Circular Pitch 

rp = dp/2; %pitch radius of pinion 
rg = dg/2; %pitch radius of gear

rbp = (rp)*cos(Phit); %base circle radius of pinion (Eq 13 - 6)
rbg = (rg)*cos(Phit); %base circle radius of gear (Eq 13 - 6)

%Surface strength geometry factor 'Z' Eq (14 - 25) 
Z = ((rp + 1/Pn)^2 - rbp^2)^(1/2) + ((rg + 1/Pn)^2 - rbg^2)^(1/2) - (rp + rg)*sin(Phit); 

mN = PN/Z; %Load Sharing Ratio (Eq 14 - 21) 

I = cos(Phit)*sin(Phit)*mG/(2*mN*(mG+1)); %Geometry Factor I 

%***********************************************
%Geometry Factor 'J' 
Jp = 0.46; %Helical Pinion Geometry Factor J'(Figure 14-7) 
Jg = 0.54; %Helical Gear Geometry Factor J' (Figure 14-7)

JP = 0.945*Jp; %Geometry Modifying Factors (Figure 14-8)
JG = 0.995*Jg;

%***********************************************
%Material Properties
HB = 320; %(Figure 14-4) Nitralloy 135M
St = 86.2*HB + 12730; %Ultimate Tensile Strength (Table 14-5)
Sc = 170000; %Ultimate Compressive Strength (Table 14-6)
Cp = 2300; %Elastic Coefficient Of Steel

%***********************************************
%Min. Face Width Calculation 

Fpb = n*Wt*Ko*Kv*Ks*Pt*Km*Kb*Kt*Kr/(JP*St*Ynp); %Face Width Bending (Eq 14 -15)
Fpw = (Cp*Kt*Kr/(Sc*Znp))^2*n*Wt*Ko*Kv*Ks*Km*Cf/(dp*I);  %Face Width Wear (Eq 14 - 16) 

%***********************************************
%Command Outputs
fprintf(1, '\n');
fprintf('*****************************************************************\n');
fprintf('Minumum Face Width Requirement\n');
fprintf('*****************************************************************\n');
fprintf(1, '\n');

fprintf('Minumum Face Width for Bending: (inches) %s\n', Fpb);
fprintf('Minumum Face Width for Wear: (inches) %s\n', Fpw);
fprintf(1, '\n');

if Fpw > Fpb
    min=Fpw;
else
    min=Fpb;
end
fprintf('The face width must be greater than: (inches) %s\n', min);
%***********************************************
%Size Factor Correction based on Min Requirements 

F_new=1.7; %Minimum Face Width Requirement

%y = 0.322; (Declared Above) 
Ks_new= 1.192*(F_new*sqrt(y)/Pt)^0.0535; %Eq a 14 - 10 

%***********************************************
%Load Distribution Factor Correction based on Min Requirements 
%Ce=1; Cmc=1; %Cpm=1 (Declared Above) 
Cpf_new = (F_new/(10*dp))-0.025; %(Changed Based on F_new) Factor for Face Width (Eq 14 - 32)


%Cma Calculation (Eq 14 - 34) 
%Empirical Constants for Commerical Enclosed Units (Table 14 - 9)
%Al= 0.127; Bl= 0.0158; Cl = -0.93*10^(-4); (Declared Above) 
Cma_new = Al+Bl*F+Cl*F_new^2;

%Load Distribution Factor Calculations 
Cmf_new = 1+Cmc*(Cpf_new*Cpm+Cma_new*Ce); %Face Load Distribution Factor (Eq 14 - 30)
Km_new = Cmf_new; %Load Distribution Factor (Eq 14 - 30)

%***********************************************
%Stress Analyis based on Corrected Factor 
%Pinion Bending
sigmaP =  Wt*Ko*Kv*Ks_new*Pt*Km_new*Kb/(F_new*JP);
safetyP = St*Ynp/(Kt*Kr*sigmaP);

%Pinion Wear
sigmaC = Cp*sqrt(Wt*Ko*Kv*Ks_new*Km_new*Cf/(dp*F_new*I));

CH=1;
safetyCP = Sc*Znp*CH/(Kt*Kr*sigmaC);

%Gear Bending
sigmaG = sigmaP*(JP/JG);
safetyG = St*Yng/(Kt*Kr*sigmaG);

%Gear Wear
safetyCG = Sc*Zng*CH/(Kt*Kr*sigmaC);

%Rim
mB = 1.2;
ht = 2.25/Pn;
tR = mB*ht;

%***********************************************
%Face Width Iterations
fprintf(1, '\n');
fprintf('*****************************************************************\n');
fprintf('Stress Analysis Results (Based on Corrected Face Width)\n');
fprintf('*****************************************************************\n');
fprintf(1, '\n');
fprintf('Corrected Face Width is: (inches) %s\n', F_new);
fprintf('Based on this, the stresses are\n');
fprintf(1, '\n');

fprintf('For Pinion:\n');
fprintf('Bending Stress: (psi) %s\n', sigmaP);
fprintf('Safety Factor: %s\n', safetyP);
fprintf('Contact Stress: (psi) %s\n', sigmaC);
fprintf('Safety Factor: %s\n', safetyCP);
fprintf(1, '\n');
fprintf('For Gear:\n');
fprintf('Bending Stress: (psi) %s\n', sigmaG);
fprintf('Safety Factor: %s\n', safetyG);
fprintf('Contact Stress: (psi) %s\n', sigmaC);
fprintf('Safety Factor: %s\n', safetyCG);
fprintf(1, '\n');


%***********************************************
%Gear Loads
Wr = Wt*sin(Phi); %radial load, Eq 13-39
Wa = Wt*cos(Phi)*sin(Psi); %axial load
fprintf('*****************************************************************\n');
fprintf('Helical Gear Loads\n');
fprintf('*****************************************************************\n');
fprintf(1, '\n');
fprintf('Transverse Load is: (lbf) %s\n', Wt);
fprintf('Radial Load is: (lbf) %s\n', Wr);
fprintf('Axial Load is: (lbf) %s\n', Wa);
fprintf(1, '\n');

function[Dmax,Dmin,dmax,dmin] = tolerance(basicDiameter,shaft)
%All dimesnions in inches
d= basicDiameter; %shaft basic size
D=d;     %hole basic size

%From Table 7-9, close running fit symbol is H8/f7

%Table A-13 to calculate tolerance grade

if (shaft == "Motor")
    deltaD = 0.0011; %motor
elseif (shaft =="Intermediate" || shaft=="Drill")
    deltaD = 0.0013; % inter or drill
end

Dmax = D+deltaD;   %Hole Results
Dmin =D;

%Table A-14 to calculate fundamental deviation
if (shaft == "Motor")
    deltaF = -0.0006; %motor
elseif (shaft =="Intermediate" || shaft=="Drill")
    deltaF = -0.0008; % inter or drill
end

dmax= d+deltaF+deltaD;  %Shaft Results
dmin = d+deltaF;

%print everything
fprintf(1, '\n');
fprintf(1, '\n');
fprintf('Hole Dmax is: (inches)%s\n', Dmax')
fprintf('Hole Dmin is: (inches)%s\n', Dmin')
fprintf('Shaft dmax is: (inches)%s\n', dmax')
fprintf('Shaft dmin is: (inches)%s\n', dmin')

end
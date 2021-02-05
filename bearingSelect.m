function [bore,outerDiameter,width,resultingReliability,C10req,desiredReliability] = bearingSelect(radialForce,axialForce,type,rpm,desiredBore)
%The calculations will be done in imperial units
%Initialize variables 

lifeHours = 4000; % life in kilohours, Table 11-4
RD = 0.97; % Desired reliability of bearing
af = 1.5; % Load factor, Table 11-5, Assumed to be 2 because of "machinery with moderate impact"
V = 1; % Rotation Factor, "inner ring is rotating" see p.585


LR = 10^6; % Table 11-6
x0 = 0.02; % Table 11-6
theta = 4.459; % Table 11-6     <--- These are Weibull parameters for Manufacturer 2
b = 1.483; % Table 11-6

kNTolbf = 1/0.00445; % convert KN to lbf
mmToIn = 1/25.4; % convert mm to in 



% Tables from chapter 11
table1 = [[0.014 0.021 0.028 0.042 0.056 0.070 0.084 0.110 0.17 0.28 0.42 0.56]', [0.19 0.21 0.22 0.24 0.26 0.27 0.28 0.30 0.34 0.38 0.42 0.44]', [1 1 1 1 1 1 1 1 1 1 1 1]', [0 0 0 0 0 0 0 0 0 0 0 0]', [0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56]', [2.30 2.15 1.99 1.85 1.71 1.63 1.55 1.45 1.31 1.15 1.04 1.00]']; % Table 11-1
table2 = [mmToIn*[10 12 15 17 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95]', mmToIn*[30 32 35 40 47 52 62 72 80 85 90 100 110 120 125 130 140 150 160 170]', mmToIn*[9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 28 30 32]', mmToIn*[0.6 0.6 0.6 0.6 1 1 1 1 1 1 1 1.5 1.5 1.5 1.5 1.5 2 2 2 2]', mmToIn*[12.5 14.5 17.5 19.5 25 30 35 41 46 52 56 63 70 74 79 86 93 99 104 110]', mmToIn*[27 28 31 34 41 47 55 65 72 77 82 90 99 109 114 119 127 136 146 156]', kNTolbf*[5.07 6.89 7.80 9.56 12.7 14 19.5 25.5 30.7 33.2 35.1 43.6 47.5 55.9 61.8 66.3 70.2 83.2 95.6 108]', kNTolbf*[2.24 3.1 3.55 4.5 6.2 6.95 10 13.7 16.6 18.6 19.6 25 28 34 37.5 40.5 45 53 62 69.5]', kNTolbf*[4.94 7.02 8.06 9.95 13.3 14.8 20.3 27 31.9 35.8 37.7 46.2 55.9 63.7 68.9 71.5 80.6 90.4 106 121]', kNTolbf*[2.12 3.05 3.65 4.75 6.55 7.65 11 15 18.6 21.2 22.8 28.5 35.5 41.5 45.5 49 55 63 73.5 85]'];
table3 = [mmToIn*[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]', mmToIn*[52 62 72 80 85 90 100 110 120 125 130 140 150 160 170 180 200 215 230 250 270]', mmToIn*[15 16 17 18 19 20 21 22 23 24 25 26 28 30 32 34 38 40 40 42 45]', kNTolbf*[16.8 22.4 31.9 41.8 44 45.7 56.1 64.4 76.5 79.2 93.1 106 119 142 165 183 229 260 270 319 446]', kNTolbf*[8.8 12 17.6 24 25.5 27.5 34 43.1 51.2 51.2 63.2 69.4 78.3 100 112 125 167 183 193 240 260]', mmToIn*[62 72 80 90 100 110 120 130 140 150 160 170 180 190 200 215 240 260 280 300 320]', mmToIn*[17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 50 55 58 62 65]', kNTolbf*[28.6 36.9 44.6 56.1 72.1 88 102 123 138 151 183 190 212 242 264 303 391 457 539 682 781]', kNTolbf*[15 20 27.1 32.5 45.4 52 67.2 76.5 85 102 125 125 149 160 189 220 304 340 408 454 502]'];
emax = 0.44; % maximum value of e, from Table 11-1
emin = 0.19; % minimum value of e, from Table 11-1

%/////////////////////////////////////////////////////
%select type of bearing
if(type == "DeepGroove")
   bearingType =1;   
elseif(type == "AngularContact")
    bearingType = 2;
elseif(type == "CylindricalRollerS02")
    bearingType = 3;
elseif(type == "CylindricalRollerS03")
    bearingType = 4;
end

%//////////////////////////////////////////////////////// 
% Variables set through parameter call
speed = rpm; % speed of bearing, 
Fr = radialForce; % radial force
Fa = axialForce; % axial force

% Initializing more variables


Xi = 1; % X factor
C10req = 1; % required C10 per iteration
C10bearing = 1; % C10 value of bearing 
C0 = 0; % static load rating
loopCount = 0; % used to increment loop and find bearing
bearingFound = false; % true when C10>calculated C10
realizedReliability = 1; % To be compared with specified reliability
bearingBore = 1; % bore of ball bearing
bearingOD = 1; % bearing outer diameter 
bearingWidth = 1; % width of bearing
desiredBoreReliability = 0.9; % reliability of the desired bore size

%//////////////////////////////////////////////////// 

% Find a value based on type of bearing 
if ((bearingType == 1) || (bearingType == 2)) % ball or angular 
    a = 3;
else % cylindrical roller
    a = 10/3; 
end

%////////////////////////////////////////////////////////////



% Find C10
LD = speed*lifeHours*60; % life (rev)
XD = LD / LR; % multiple of rating life



% iteration to find Fe and Xi
while (~bearingFound) % infinte loop unit bearing is found
    % Find Fe (equivalent axial load)
    FaVFr = Fa/(V*Fr); %define 
    
    if (C0 ~= 0) % has been updated from previous iterations
        FaC0 = Fa/C0;
        % Find e using Table1
        % Loop through first column of table1 to find Fa/Co value
        if (FaC0 > 0.014 && FaC0 < 0.56) 
            
            for i = (1:size(table1,1)-1)
                currFaC0 = table1(i,1);
                nextFaC0 = table1(i+1,1);
                if (FaC0 < nextFaC0) % value is below
                    % Found correct range; interpolate for e
                    currE = table1(i,2);
                    nextE = table1(i+1,2);
                    e = currE + (nextE-currE)*((FaC0-currFaC0)/(nextFaC0-currFaC0));
                    % e has been acquired, compare to FaVFr to determine value of i, X, and Y
                    if (FaVFr <= e)
                        % Check 3rd and 4th columns
                        Xi = 1;
                        Yi = 0;
                    else
                        % Check 5th and 6th columns
                        Xi = 0.56;
                        currY2 = table1(i,6);
                        nextY2 = table1(i+1,6);
                        Yi = currY2 + (nextY2-currY2)*((FaC0-currFaC0)/(nextFaC0-currFaC0));
                    end
                    % values found; exit loop
                    break;
                elseif (FaC0 == nextFaC0) % value is equal
                    % e taken from table
                    e = table1(i+1,2);
                    % we have e, compare to FaVFr to get i, X, and Y
                    if (FaVFr <= e)
                        % Check 3rd and 4th columns
                        Xi = 1;
                        Yi = 10;
                    else
                        % Check 5th and 6th columns
                        Xi = 0.56;
                        Yi = table1(i+1,6);
                    end
                    % values found; exit loop
                    break;
                end
            end
        elseif (FaC0 < 0.014) % use 0.014 if Fa/C0 < 0.014
            FaC0 = 0.014;
            e = emin;
            if (FaVFr <= e)
                Xi = 1;
                Yi = 0;
            else
                Xi = 0.56;
                Yi = 2.30;
            end
        elseif (FaC0 > 0.56) % greater than table
            FaC0 = 0.56;
            e = emax;
            if (FaVFr <= e)
                Xi = 1;
                Yi = 0;
            else
                Xi = 0.56;
                Yi = 1;
            end
        end
    else % has not been found yet; first iteration
        if (FaVFr > emax)
            e = emax;
            % Start halfway and work up
            Xi = 0.56;
            Yi = 1.63;
        else
            e = emin;
            % Start from beginning and work up
            Xi = 1;
            Yi = 0;
        end
    end
    
    % We can now get Fe, Eq. 11-12
    Fe = Xi*V*Fr + Yi*Fa;
    
    % Calculate required C10 value, Eq. 11-9
    C10req = af*Fe*(XD/(x0+(theta-x0)*(1-RD)^(1/b)))^(1/a); 
    
    if (loopCount ~= 0) 
        if (C10req < C10bearing)  
            bearingFound = true; %confirmation that bearing has been found
        end
    end
    
 %///////////////////////////////////////////////////////////////////////////////   
    % Get data from Table 11-2 to get C0, C10 then test different bearings
    % loop until C10req < C10 
    
    if (~bearingFound) % Bearing is still not found
        if (bearingType == 1 || bearingType == 2) % Use table 11-2
            for iter = 1:size(table2,1)
                column10 = 0;
                column0 = 0;
                if (bearingType == 1) % deep groove ball bearing
                    column10 = 7;
                    column0 = 8;
                elseif (bearingType == 2) % angular contact ball bearing
                    column10 = 9;
                    column0 = 10;
                end
                currC10 = table2(iter,column10);
                if (currC10 > C10req)
                    % potential bearing found
                    % Get C10bearing value from table
                    C10bearing = currC10;
                    C0 = table2(iter,column0);
                    bearingBore = table2(iter,1); % save bore size (in)
                    bearingOD = table2(iter,2); % save outer diameter (OD) --> in
                    bearingWidth = table2(iter,3);
                    % exit loop
                    break;
                end
            end
    %////////////
        elseif (bearingType == 3 || bearingType == 4) % Use table 11-3
            for increment = 1:size(table3,1)
                % check the 02 series and 03 series
               
                columnValue = 4; % default 4 for 02 series
                widthColumn = 3; % default 3 for 02 series
                columnC0 = 5;
                columnC10 = 4;
                if (bearingType == 4) % different columns for 03 series bearing
                    columnC10 = 8;
                    columnC0 = 9;
                    widthColumn = 7; 
                end
                
                currC10 = table3(increment,columnC10); % get the current C10 value
                
                if (currC10 > C10req) %Final condition for bearing found
                    C10bearing = currC10;
                    C0 = table3(increment, columnC0);
                    bearingBore = table3(increment,1);
                    bearingOD = table3(increment,2);
                    bearingWidth = table3(increment,widthColumn);
                    break; % break loop
                end
            end
        end
         %////////////////////////
         %REALIABILITY
    else %Activated when bearing is found
        realizedReliability = exp(((XD*((af*Fe)/C10bearing)^a-x0)/(theta-x0))^b);
        
        if (realizedReliability > RD) % Reliability Check
            "Minimum bearing passes!";
        else
            "Minimum bearing fails!";
            
        end
    end
    loopCount = loopCount + 1;
end

%//////////////////////////////////////////
%FINAL OUTPUTS 

resultingReliability = realizedReliability;
bore = bearingBore;
outerDiameter = bearingOD;
width = bearingWidth;
%C10req = C10req*(4.45/1000);
desiredReliability = desiredBoreReliability;

fprintf(1, '\n');
fprintf(1, '\n');
fprintf('The desired reliability is: %s\n', desiredBoreReliability') 
fprintf('The realized reliability is: %s\n', realizedReliability') 
fprintf('The bearing bore is: (inches) %s\n', bearingBore')
fprintf('The bearing outer diameter is: (inches) %s\n', bearingOD')
fprintf('The bearing width is: (inches) %s\n', bearingWidth')
fprintf('The catalog load rating is: (lbf) %s\n', C10req')
end
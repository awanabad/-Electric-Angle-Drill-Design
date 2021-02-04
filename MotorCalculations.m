
clc; 
clear all;
P_in= 600; %Input Power 
W_rpm= 400; %No Load Speed 

%Conversion from rpm to rad/s 
W_max=(2*pi*W_rpm)/60; 

%Stall Torque Calculation 
W=W_max/2; %Max Power occurs at Half No Load Speed 
T_s=P_in/(W*(1-(W/W_max)));

%Input Torque Calculation 
T_in=T_s*(1-(W/W_max)); 

fprintf('Angular Velocity %s\n', double(W_max)); %rad/s
fprintf('The stall torque is %s\n', double(T_s)); %Nm
fprintf('The input torque is %s\n', double(T_in));%Nm

subplot(1,2,1)
%first plot
%Plot of T(W) 
x1=linspace(1,100); 
%m= -(T_s/W_max); 
m= -(57.3/41.89); 
%c= T_s;
c=57.3;
y1= (m*x1)+c; 
plot(y1, 'b');
title('Torque-Speed');
ylim([-1 60]);
ylabel('Torque(Nm)');
xlabel('Speed(rad/s)');
hold on; 

%second plot for Power
subplot(1,2,2)
x=linspace(0,80);
y=-1.3677.*(x-41.89).*(x); %parabola


plot(x,y,'r');
title('Power-Speed')
xlabel('Speed (rad/s)');
ylabel('Power(W)');
xlim([-1 45]);
ylim([-1 650]);

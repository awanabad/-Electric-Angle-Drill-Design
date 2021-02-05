clc;
clear all;

%Motor Shaft
fprintf('Motor Shaft: Helical Pinion'); 
tolerance(.5906, "Motor");
fprintf('*****************************************************************\n');

%Intermediate Shaft
fprintf('Intermediate Shaft: Helical Gear and Bevel Pinion'); 
tolerance(1, "Intermediate");
fprintf('*****************************************************************\n');

%Intermediate Shaft
fprintf('Drill Shaft: Bevel Gear'); 
tolerance(0.9, "Drill");
fprintf('*****************************************************************\n');
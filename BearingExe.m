%Clearing Command Window 
clc;
clear all;

%Motor Shaft Bearings
fprintf('Motor Shaft Bearings'); 
bearingSelect(200.2/2, 275.0/2, "AngularContact", 200, 0.5);
fprintf('*****************************************************************\n');

%Intermediary Shaft Bearing 1 (beside helical at end of shaft)
fprintf('Helical Gear Bearing'); 
bearingSelect(200.2, 275.0, "AngularContact", 200/2.147, 0.6);
fprintf('*****************************************************************\n');

%Intermediary Shaft Bearing 2 (between gears)
fprintf('Bevel Pinion Bearing'); 
bearingSelect(118.1, 236.2, "AngularContact", 200/2.147, 1.4);
fprintf('*****************************************************************\n');

%Drill Shaft Bearings
fprintf('Drill Shaft Bearings'); 
bearingSelect(118.1/2, 236.2/2, "AngularContact", 200/(2.147*2), 0.9);
fprintf('*****************************************************************\n');


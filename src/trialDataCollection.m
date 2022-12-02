%% Close uno and clear workspace
try
    uno.close;
catch
end
clear all; clc;
%% Setup
[uno, ArduinoConnected]=connect_ard1ch();
%% Collect Data
phasesPerClass = 10;
phaseWindowSize = 2000;
timeWindowSize = 5000;
[data, tdata, labels] = collectTriallData(timeWindowSize, phaseWindowSize, phasesPerClass);
%% Plot Data
data = data(~isnan(data));
labels = labels(~isnan(labels));
plot((data));
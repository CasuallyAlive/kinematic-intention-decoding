%% Close uno and clear workspace
try
    uno.close;
catch
end
clear all; clc;
%% Setup
[uno, ArduinoConnected]=connect_ard1ch();

dirFiles = '..\\trialData';
dirTrialData = strcat(dirFiles, '\\', 'trials\\');
dirLabels = strcat(dirFiles, '\\', 'trials_labels\\');

%% File Name
initials = "JL";
dateVal = "12062022";
trialNum = 5;

fileNameData = strcat(initials, "_", dateVal, "_", string(trialNum), ".mat");
fileNameLabels = strcat(initials, "_", dateVal, "_", string(trialNum), "_labels", ".mat");
%% Collect Data
phasesPerClass = 5;
phaseWindowSize = 2000;
timeWindowSize = 500;
[data, tdata, labels] = collectTriallData(uno, timeWindowSize, phaseWindowSize, phasesPerClass);
%% Plot Data
JL_12062022_5 = data(~isnan(data)); % Change this name
JL_12062022_5_labels = labels(~isnan(labels)); % Change this name

fig2 = figure();
hold off
plot(JL_12062022_5);
hold on
plot(JL_12062022_5_labels);
plot(getDataFeatures(JL_12062022_5, 300, 1e3));
legend({"Raw Data", "Labels", "Feature 1", "Feature 2", "Feature 3", "Feature 4", "Feature 5"}, "Location", "northeast");
%% Save Data
save(strcat(dirTrialData, fileNameData), "JL_12062022_5");
save(strcat(dirLabels, fileNameLabels), "JL_12062022_5_labels");
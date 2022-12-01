%% Clear
clc;
clear all;
%% Place all Trial data in Matrix
dirFiles = '..\\trialData\\';
mat = dir(strcat(dirFiles, 'trials\\',  '*.mat')); 
dataSet = NaN(length(mat), 1e6);
min_length = 1e6;

for q = 1:length(mat)
    fileName = mat(q).name;
    cont = load(strcat(dirFiles, 'trials\\', fileName)); 
    name = fileName(1:end-4);
    datatemp = [cont.(name)(:)]';

    temp_min = length(datatemp(~isnan(datatemp)));
    if(temp_min < min_length)
        min_length = temp_min;
    end

    dataSet(q,1:length(datatemp)) = datatemp;
end

trainingExamples = length(mat);
X_Vals = dataSet(1:trainingExamples,1:min_length);

%% Process Label Data
mat = dir(strcat(dirFiles, 'trials_labels\\',  '*.mat'));
dataSet_labels = NaN(length(mat), 1e6);

min_length = 1e6;
Y_Vals = [];

for q = 1:length(mat)
    fileName = mat(q).name;
    cont = load(strcat(dirFiles, 'trials_labels\\', fileName)); 
    name = fileName(1:end-4);
    datatemp = [cont.(name)(:)]';

    temp_min = length(datatemp(~isnan(datatemp)));
    if(temp_min < min_length)
        Y_Vals = datatemp;
        min_length = temp_min;
    end
    dataSet_labels(q,1:length(datatemp)) = datatemp;
end

% Intended Classes
class1 = Y_Vals == 0;
class2 = Y_Vals == 1;
Y = [class1', class2'];
%% Data processing
windowSize = 300;
samplingFrequency = 1e3;

EMGFeatures = getDataFeatures(X_Vals', windowSize, samplingFrequency); 
EMGFeatures = EMGFeatures/max(max(EMGFeatures));
%% Plot Features
plot(EMGFeatures')
hold on
plot(Y(:,1)')
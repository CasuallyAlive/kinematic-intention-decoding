%% Clear
clc;
clear all;
%% Params
windowSize = 300;
samplingFrequency = 1e3;
%% How many Features
featurecount = menu("How many Features?", "Only movmean", "All features");
%% Place all Trial data in Matrix
dirFiles = '..\\trialData\\';
mat = dir(strcat(dirFiles, 'trials\\',  '*.mat')); 
dataSet = NaN(length(mat), 1e6);

for q = 1:length(mat)
    fileName = mat(q).name;
    cont = load(strcat(dirFiles, 'trials\\', fileName)); 
    name = fileName(1:end-4);
    datatemp = [cont.(name)(:)]';

    dataSet(q,1:length(datatemp)) = datatemp;
end

trainingExamples = length(mat);
X_Vals = [];
for trainEx = 1:trainingExamples
    dataTemp = dataSet(trainEx, :);
    dataTemp = (dataTemp(~isnan(dataTemp)));

    switch(featurecount)
        case 1
            dataTemp = getDataFeatures(dataTemp, windowSize, samplingFrequency, nan, false);
        case 2
            dataTemp = getDataFeatures(dataTemp, windowSize, samplingFrequency, nan, true);
    end

    X_Vals = [X_Vals;dataTemp];
end

EMGFeatures = X_Vals;
%% Process Label Data
mat = dir(strcat(dirFiles, 'trials_labels\\',  '*.mat'));
dataSet_labels = NaN(length(mat), 1e6);

min_length = 1e6;

for q = 1:length(mat)
    fileName = mat(q).name;
    cont = load(strcat(dirFiles, 'trials_labels\\', fileName)); 
    name = fileName(1:end-4);
    datatemp = [cont.(name)(:)]';

    dataSet_labels(q,1:length(datatemp)) = datatemp;
end

Y_Vals = [];
for trainEx = 1:trainingExamples
    dataTemp = dataSet_labels(trainEx, :);
    dataTemp = dataTemp(~isnan(dataTemp));

    Y_Vals = [Y_Vals,dataTemp];
end

% Intended Classes
class1 = Y_Vals == 0;
class2 = Y_Vals == 1;
Y = double([class1', class2']);
%% Separate Into Training and Testing Sets
train_length = floor(size(EMGFeatures, 1) * 0.8);

Y_train = Y(1:train_length-1,:);
X_train = EMGFeatures(1:train_length-1,:);

Y_test = Y(train_length:end,:);
X_test = EMGFeatures(train_length:end,:);
%% Plot Features
fig1 = figure();

plot(Y(1:floor(end/4),2)')
hold on
plot(EMGFeatures(1:floor(end/4),:))

legend({"Labels", "Feature 1", "Feature 2", "Feature 3", "Feature 4", "Feature 5"}, "Location", "northeast");
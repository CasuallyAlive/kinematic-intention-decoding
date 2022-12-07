%% Visualize
t = linspace(1, size(X_train, 1)*0.001, size(X_train, 1));

plot3(X_train(:, 1)', Y_train(:,2)', t);

%% Clear
clc;
clear all;
%% DNN Training
learnRate = 0.001;
maxEpoch = 10;
model = trainNeuralNetwork(learnRate, maxEpoch, X_train,Y_train);

%% Test Neural Network
predictions = testNeuralNetwork(X_test,model);
%%
predLength = size(predictions, 1);
predictedClasses = [];
for i = 1:predLength
    if(predictions(i,1) >= predictions(i,2))
        class = 0;
    else
        class = 1;
    end
    predictedClasses(i,1) = class;
end

expectedClasses = [];
for i = 1:predLength
    if(Y_test(i,1) == 1)
        class = 0;
    else
        class = 1;
    end
    expectedClasses(i,1) = class;
end



correct = predictedClasses(predictedClasses == expectedClasses);
per_correct = length(correct)./length(predictedClasses);
disp(strcat("Accuracy: ", string(per_correct)));
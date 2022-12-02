%% DNN Training
learnRate = 0.001;
maxEpoch = 70;
model = trainNeuralNetwork(learnRate, maxEpoch, X_train,Y_train);

%% Test Neural Network
predictions = testNeuralNetwork(X_test,net);

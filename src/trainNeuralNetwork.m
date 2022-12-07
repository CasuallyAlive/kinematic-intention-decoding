function net=trainNeuralNetwork(learnRate, maxEpoch, NeuralFeatures,yTrain)
    %% CHECK INPUTS
    [len, numFeatures]=size(NeuralFeatures);
    [len2, numDOFs] = size(yTrain);
    if(numFeatures >= len)
        NeuralFeatures = NeuralFeatures';
        [len, numFeatures]=size(NeuralFeatures);
    end
    if(numDOFs >= len2)
        yTrain = yTrain';
        [len2, numDOFs] = size(yTrain);
    end
    if(len < len2)
        yTrain = yTrain(1:length(NeuralFeatures),:);
    end
    if(len > len2)
        NeuralFeatures = NeuralFeatures(1:length(yTrain),:);
    end
    %% SET NETWORK
    xTrain = zeros(numFeatures,1,1,len);
    for i=1:len
        xTrain(:,1,1,i)=NeuralFeatures(i,:)';
    end
    inputsize=[numFeatures 1 1];
    [~, numClasses] = size(yTrain);
    options = trainingOptions('sgdm','InitialLearnRate', learnRate, 'MaxEpochs', maxEpoch,...
        'Shuffle','every-epoch','Plots','training-progress');
    layers= [ ...
        imageInputLayer(inputsize)
        fullyConnectedLayer(numFeatures*2)
        tanhLayer
        fullyConnectedLayer(numFeatures*3)
        tanhLayer
%         fullyConnectedLayer(numFeatures*3)
%         tanhLayer
%         fullyConnectedLayer(numFeatures*2)
%         tanhLayer
        fullyConnectedLayer(numClasses)
        regressionLayer];
    % train MLP
    net=trainNetwork(xTrain,yTrain,layers,options);
end
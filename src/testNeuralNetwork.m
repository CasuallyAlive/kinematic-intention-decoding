function predictedValues=testNeuralNetwork(NeuralFeatures,net)
    [len, numFeatures]=size(NeuralFeatures);
    xTest = zeros(numFeatures,1,1,len);
    for i=1:len
        xTest(:,1,1,i)=NeuralFeatures(i,:)';
    end
    predictedValues=predict(net,xTest);
end
%% Load Model
featurecount = menu("How many Features?", "Only movmean", "All features");
switch(featurecount)
    case 1
        load("..\\DNN_model\\DNN_sEMG_Classifier_1_feature.mat", "model");
    case 2
        load("..\\DNN_model\\DNN_sEMG_Classifier.mat", "model");
end

%%
predictions = testNeuralNetwork(X_test, model);

error = loss(model,X_test)
% predLength = size(predictions, 1);
% labels = [];
% for i = 1:predLength
%     if(predictions(i,1) >= predictions(i,2))
%         class = 0;
%     else
%         class = 1;
%     end
%     labels(i,1) = class;
% end
% hold off
% confusionchart(X_test(1:2250,1), labels(1:2250));
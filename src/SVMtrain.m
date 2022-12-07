%% Generate SVM labels
Y_train_svm = [];

for i = 1:size(Y_train, 1)
    if(Y_train(i,1) == 1)
        class = 0;
    else
        class = 1;
    end
    Y_train_svm(i,1) = class;
end

Y_test_svm = [];
for i = 1:size(Y_test, 1)
    if(Y_test(i,1) == 1)
        class = 0;
    else
        class = 1;
    end
    Y_test_svm(i,1) = class;
end

%% Train SVM
model1 = fitcsvm(X_train, Y_train_svm, ...
    'KernelFunction','rbf');
model2 = fitcsvm(X_train, Y_train_svm, ...
    'KernelFunction','gaussian');
model3 = fitcsvm(X_train, Y_train_svm, ...
    'KernelFunction','polynomial');
%% predict
predictions1 = model1.predict(X_test);
predictions2 = model2.predict(X_test);
predictions3 = model3.predict(X_test);
%% percentage Correct

correct = Y_test_svm(predictions2 == Y_test_svm);
disp(length(correct)./length(Y_test_svm));
function pred = predictedOverallStateSVM(predictions)
    predLength = size(predictions, 1);
    class0 = 0;
    class1 = 0;
    for i = 1:predLength
        if(predictions(i,1) == 0)
            class0 = class0 + 1;
        else
            class1 = class1 + 1;
        end
    end
    if(class0 > class1)
        pred = 0;
        return;
    end
    pred = 1;
end
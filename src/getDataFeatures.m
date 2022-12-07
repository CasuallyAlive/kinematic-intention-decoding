function featuresEMG = getDataFeatures(data, windowSize, samplingFrequency, maxVal, allFeatures)

    filteredData = filterData(data, 60, 200, samplingFrequency);

    filteredData = filterData(filteredData, 120, 200, samplingFrequency);

    filteredData = filterData(filteredData, 180, 200, samplingFrequency);
    
%     filteredData = rmoutliers(filteredData);
%     filteredData = (filteredData - min(filteredData))./...
%                     (max(filteredData)-min(filteredData));

    featuresEMG(:, 1) = movmean(abs(filteredData), windowSize);
    if(allFeatures)
        featuresEMG(:, 2) = (movmad(filteredData, windowSize));
        featuresEMG(:, 3) = abs(movmedian(filteredData, windowSize));
        featuresEMG(:, 4) = movmax(filteredData, windowSize);
        featuresEMG(:, 5) = sqrt(mean(featuresEMG(:, 1:4).^2, 2));
    end
    maxFeature = max(featuresEMG);
    if(isnan(maxVal))
        featuresEMG = featuresEMG./maxFeature;
        return;
    end
    featuresEMG = featuresEMG./max([maxVal,maxFeature]);
end
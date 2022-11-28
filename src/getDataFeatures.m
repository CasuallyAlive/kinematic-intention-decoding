function featuresEMG = getDataFeatures(data, windowSize, samplingFrequency)
    w0 = 60/(samplingFrequency/2);
    bw = w0/120;
    
    [num, den] = iirnotch(w0, bw);
    
    filteredData = filter(num, den, data);
    featuresEMG = movmad(filteredData, windowSize);
end
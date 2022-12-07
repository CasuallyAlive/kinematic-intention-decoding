function filteredData = filterData(data, cutOffFrequency, qFactor, samplingFrequency)
    w0 = cutOffFrequency/(samplingFrequency/2);
    bw = w0/qFactor;
    
    [num, den] = iirnotch(w0, bw);
    
    filteredData = filter(num, den, data);
end


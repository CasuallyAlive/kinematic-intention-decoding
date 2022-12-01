function plotNeuralData(data,plotTitle)
figure()
sgtitle(plotTitle)
[timePoints,numchannels]=size(data);
x=0:1/30000:(timePoints-1)/30000;
for i= 1:numchannels
    subplot(2,3,i)
    plot(x,data(:,i))
    title(['Channel',' ',num2str(i)])
    xlabel('time (s)')
    ylabel('\muV')
    ylim([-200 200])
    xlim([0 timePoints/30000])
    
end
end
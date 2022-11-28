function [figHandle, lineHandles, Tmax, Tmin]=plotSetup1ch()
    % [figHandle, lineHandles, Tmax, Tmin] = plotSetup1ch()
    % PLOTSETUP1CH  sets up plots to visualize EMG input and the control
    % value calculated later in EMG_live. This function sets up one graph
    % for a single channel EMG input, and one for the control graph. (two
    % graphs total)
    % figHandle is the Figure handle for the graphs generated. 
    % lineHandles are the handles for the animated lines that are used to
    % update the graphs in updatePlot1ch.m. It makes it so the graphs can 
    % be shown in real time
    % Tmax is the max xlimit of the graph, initially set to 30
    % seconds
    % Tmin is the min xlimit of the graph, initially set to 0
    % both Tmax and Tmin are dynamically updated in updatePlot1ch.m
    
    numChannels=1; %number of input channels 
    numDOFs=numChannels; %number of degrees of freedom controlled
    numPlots=numChannels+numDOFs;
    Tmax = 30;
    Tmin = 0;
    yLabels=cell(1,numPlots);
    axisHandles=cell(1,numPlots);
    lineHandles=cell(1,numPlots);
    for i=1:numChannels
        yLabels{i}=strcat('voltage',num2str(i),' (V)');
        yLabels{i+numChannels}=strcat('control',num2str(i));
    end
    figHandle=figure('units','normalized'); %open figure
    set(figHandle,'outerposition',[0,0,.5,1])%moveFigure to left half of screen
    for i=1:numPlots
        axisHandles{i}=subplot(numPlots,1,i);
        lineHandles{i}=animatedline;
%         ylim([-1.2,1.2])
        xlim([0 Tmax])
        ylabel(yLabels{i})
        xticks([]);
        if i>numChannels
            ylim([-0.25,1.25]);
            yticks([0,1]);
            yticklabels({'OPEN (0)','CLOSE (1)'})
        else
            ylim([-2.5,2.5]);
        end
        
    end
    linkaxes([axisHandles{:}],'x')
    xlabel('Time (seconds)')
end
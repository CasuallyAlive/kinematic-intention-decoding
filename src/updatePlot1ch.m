function [Tmax, Tmin] = updatePlot1ch(animatedLines, timeStamp, data, control, prevSamp, dataindex, controlindex, Tmax, Tmin)
% [Tmax, Tmin] = updatePlot1ch(animatedLines, timeStamp, data, control, prevSamp, dataindex, controlindex, Tmax, Tmin)
% updatePlot1ch updates the plots for the EMG data and control
% animatedLines are handles for the animated lines returned from
% plotSetup(1ch).m. 
% timeStamp is the current time value and is used as the independent (x)
% variable in the graphs
% data is the whole data vector/matrix and is plotted with the max and min
% values between the previous sample and the current dataindex. 
% control is the whole control vector/matrix and is plotted at timeStamp
% with the value at controlindex
% prevSamp is the last time the graphs were plotted and control sent over
% to the virtual hand. Updated in the EMG_live(_1ch).m file after updating
% the hand.
% dataindex is the current location of emg input
% controlindex is the current index of control
% Tmax is the upper xlimit of the graphs, is updated if timeStamp is more
% than that and shifts the graphs by 5 seconds. This allows the graphs to
% keep running continuously if desired.
% Tmin is the lower xlimit of the graphs. updated similarly to Tmax as
% timeStamp increases passed Tmax
    for i=1:length(animatedLines)
        if i<=1
            addpoints(animatedLines{i},timeStamp,max(data(i,prevSamp:dataindex-1)));
            addpoints(animatedLines{i},timeStamp,min(data(i,prevSamp:dataindex-1)));
        else
            addpoints(animatedLines{i},timeStamp,control(i-1,controlindex));
        end
    end
    if timeStamp>Tmax
        Tmax=Tmax+5;
        Tmin=Tmin+5;
        xlim([Tmin Tmax])
    end
    drawnow %limitrate %update the plot, but limit update rate to 20 Hz
end
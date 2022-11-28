function finalPlot(data,control,tdata,tcontrol)
% this function plots both the data and the control values for each input.
% This allows users to see how they both look after recording them. 
%  = imresize(control,[1 length(data)]);
figure()
subplot(211)
plot(tdata,data(~isnan(data)))
ylabel('Voltage (v)')
xlabel('Time (s)')
subplot(212)

plot(tcontrol,control(~isnan(control)))
ylabel('Control')
xlabel('Time (s)')
end
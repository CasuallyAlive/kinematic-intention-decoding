function [data,control, dataindex, controlindex, prevSamp,previousTimeStamp]=init1ch()
% this function initializes all the variables needed to store the data
% input from the Arduino, and to alter it to control the virtual hand. 
% data is a vector of arbitrarily large size to store the incoming EMG data
% from the arduino. initially set to the value NaN. The values within this 
% vector will range between 0 and 5 for the one channel set up.
% control is a vector set to the same size as data. This will be where the
% values of the what you want the control values to be based on the values
% in data. The values of control should range between -1 and 1.
% dataindex stores the current index of where the most recent EMG data
% received is stored, initially set to 1, but is updated each time new data
% is received.
% control index is the most recent control command will be stored. updated
% each time control value is calculated
% prevSamp stores the value of the previous sample, and will be updated
% each time graphs are updated
% previousTimeStamp is used to limit the rate of control if a delay is
% used. 
nSamp = 1000000; %abritrarily large buffer for data
data = NaN(1,nSamp);
control = NaN(1,nSamp);
dataindex = 1;
controlindex = 0;
prevSamp = 1;
previousTimeStamp = 0;
end
function [uno, ArduinoConnected]=connect_ard1ch(varargin)
% This function sets up the communication between matlab and the arduino,
% for one EMG channel input.
% uno is a serial communication MATLAB object that is used to get the data
% from the arduino, and ArduinoConnected is a flag specifying if the
% connection was made (1) or not (0).

try
    % SET UP ARDUINO COMMUNICATION
    if nargin
        uno=SerialComm(varargin{1});
    else
        uno = SerialComm(); %setup connection to arduino
    end
    ArduinoConnected = 1;
    disp('Arduino connected! :)')
catch
    uno = NaN;
    ArduinoConnected = 0;
    disp('Arduino failed to connect. :(')
end
end
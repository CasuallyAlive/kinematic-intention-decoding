%% test for emg electrodes through arduino connection
try
    uno.close;
catch
end
clear all; clc;
%% Section 1: Set Up Virtual Environment (MuJoCo)
% You should have MuJoCo open with a model loaded and running before
% starting this code!  If your code is crashing during this section, try
% the following: Close MuJoCo, Open MuJoCo, Open Model, Play MuJoCo, Run
% MATLAB Code.

[model_info, movements,command, selectedDigits_Set1, selectedDigits_Set2, VREconnected] = connect_hand;

%% connect to arduino
[uno, ArduinoConnected]=connect_ard1ch();% can put the comport number in as an argument to bypass automatic connection, useful if more than one arduino uno is connected

%% Select Algorithm
alg = menu('Select algorithm to use','Algorithm 1','Algorithm 2', 'Algorithm 3');
%% Set PID Weights and initiate previous error
kp = 0.1;
kd = 0.001;
ki = 0.00000001;
goal = 0;
prev_error = 0;
error = 0;
p = 0; int_g = 0; d = 0;
%% Plot (and control) in real time

% SET UP PLOT
[fig, animatedLines, Tmax, Tmin] = plotSetup1ch();

% INITIALIZATION
[data,control, dataindex, controlindex, prevSamp,previousTimeStamp]=init1ch();
tdata=[0];
tcontrol=[];
pause(0.5)

% our stuff
rest_basev = [];
flex_basev = [];
base_compare_v = [];
rest_base = nan;
flex_base = nan;

i = 1;
check_goal = 100;
goal = 0;
der_peaks_temp_data = zeros(1,10);
window_size = 300;
calibration_step_length = 2000;
axis([Tmin,Tmax, 0,1]);
sinusoid_rt = animatedline('Color','r','LineWidth',3);
sinusoid_rt_data = nan(2,10e6);
%
tic
while(ishandle(fig)) % run or figure closes
    % SAMPLE ARDUINO
    try
        emg = uno.getRecentEMG;% values returned will be between -2.5 and 2.5 , will be a 1 x up to 330
        if ~isempty(emg)
            [~,newsamps] = size(emg); % helps to know how much more data was received
            data(:,dataindex:dataindex+newsamps-1) = emg(1,:); % adds new EMG data to the data vector
            dataindex = dataindex + newsamps; % update sample  
            controlindex = controlindex + 1;
        else
            disp('empty array')
        end
    catch
        disp('error')
    end
    if ~isempty(emg)
        % UPDATE
        timeStamp = toc; %get timestamp
        % CALCULATE CONTROL VALUES
 
        if(dataindex < window_size)
            continue;
        end
        try
            %% start of your code
            temp_data = data(dataindex-window_size:dataindex-1);
            temp_data(temp_data < 0) = 0;
            if dataindex > window_size && dataindex < (calibration_step_length + window_size)
                rest_basev(length(rest_basev)+1) = mean(findpeaks(temp_data));
                disp('Relax hand')
            elseif dataindex > (calibration_step_length + window_size) && dataindex < (2*calibration_step_length + window_size)
                flex_basev(length(flex_basev)+1) = mean(findpeaks(temp_data));
                disp('Flex hand')
            end
            if dataindex > (2*calibration_step_length + window_size)
                if(isnan(flex_base) || isnan(rest_base))
                    rest_base = mean(rest_basev);
                    flex_base = mean(flex_basev);
                end
                switch alg
                    case 1
                        peak_avg = mean(findpeaks(temp_data));
                        base_compare = (peak_avg - rest_base)./(flex_base - rest_base);
                        base_compare_v(length(base_compare_v)+1) = base_compare;
                        base_compare_f = fft(base_compare_v);
                        base_compare_f(50:end) = 0;
                        base_compare_re = ifft(base_compare_f);
                        
                        control(1,controlindex) = real(base_compare_re(end));
                        disp('Ready to record')
                        
                    case 2                 
                        peaks_temp_data = findpeaks(temp_data);
                        peak_avg = mean(peaks_temp_data);
                        base_compare = (((peak_avg - rest_base))./(flex_base - rest_base));

                        % update target every 'check_goal' iterations.
                        if(i >= check_goal)
                            if(base_compare < 0)
                                goal = -1;
                            elseif(base_compare > 0.5)
                                goal = 1;
                            else
                                goal = 0;
                            end
                            i = 1;
                        else
                            i = i + 1;
                        end
                            
                        % pid stuff begin
                        prev_error = error;
                        error = goal - base_compare;
                        dt = timeStamp - tcontrol(controlindex - 1);
                
                        p = kp * error; % proportional gain
                        int_g = int_g + ki * error * dt; % integral gain
                        d = kd *((error - prev_error)./dt); % derivative gain
                
                        control_val = base_compare + p + d;
                        % pid stuff end
                
                        control(1,controlindex) = control_val;
                        disp('Recording')
                    case 3
                
                        peaks_temp_data = findpeaks(temp_data);
                        peak_avg = mean(peaks_temp_data);
                    
                        base_compare = (((peak_avg - rest_base))./(flex_base - rest_base));
                        control(1,controlindex) = base_compare;
                        disp('Recording')
                end
            end
            new_point_sin = 0.5.*sin(timeStamp) + 0.5;
            addpoints(sinusoid_rt,timeStamp, new_point_sin);
            sinusoid_rt_data(1,controlindex - 1) = timeStamp; % first row is time data
            sinusoid_rt_data(2, controlindex - 1) = new_point_sin; % second row is sinusoid
            drawnow limitrate
            %% end of your code
        catch ME
            disp('Something broke in your code!')
        end
        tcontrol(controlindex)=timeStamp;   
        tempStart = tdata(end);
        tdata(prevSamp:dataindex-1)=linspace(tempStart,timeStamp,newsamps);
        % UPDATE PLOT
        [Tmax, Tmin] = updatePlot1ch(animatedLines, timeStamp, data, control, prevSamp, dataindex, controlindex, Tmax, Tmin);
        
        % UPDATE HAND
        if(VREconnected) %if connected
            status = updateHand(control, controlindex, command, selectedDigits_Set1, selectedDigits_Set2);
        end
        previousTimeStamp = timeStamp;
        prevSamp = dataindex;
    end
end
%% Plot the data and control values from the most recent time running the system
data = data(~isnan(data));
control = control(~isnan(control));
finalPlot(data,control,tdata,tcontrol)

%% close the arduino serial connection before closing MATLAB
uno.close; 
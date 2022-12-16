%% test for emg electrodes through arduino connection
try
    uno.close;
catch
end
clear all; clc;

%% Features
featurecount = menu("How many Features?", "Only movmean", "All features");

%% Controller
controllerInput = menu("Which Controller?", "PID", "MPC");
%%
switch(featurecount)
    case 1
        load("..\\DNN_model\\DNN_sEMG_Classifier_1_feature.mat", "model");
        maxFeature = 0.38;
    case 2
        load("..\\DNN_model\\DNN_sEMG_Classifier.mat", "model");
end
% load("..\\DNN_model\\maxVal2.mat", "maxFeature");

%% Section 1: Set Up Virtual Environment (MuJoCo)
% You should have MuJoCo open with a model loaded and running before
% starting this code!  If your code is crashing during this section, try
% the following: Close MuJoCo, Open MuJoCo, Open Model, Play MuJoCo, Run
% MATLAB Code.

[model_info, movements,command, selectedDigits_Set1, selectedDigits_Set2, VREconnected] = connect_hand;

%% connect to arduino
[uno, ArduinoConnected]=connect_ard1ch();% can put the comport number in as an argument to bypass automatic connection, useful if more than one arduino uno is connected

%% Grip Thresholds
%% Linear MPC
x0 = -1;
u0 = 1; % control = 0
Ts = 0.001;
mpc_controller = nlmpc(1,1,1);
mpc_controller.Ts = 0.001;
mpc_controller.PredictionHorizon = 2;
mpc_controller.ControlHorizon = 2;

mpc_controller.Model.StateFcn = @(x,u) myStateFunction(x,u);
mpc_controller.Model.OutputFcn = @(x,u) outputFunction(x,u);

validateFcns(mpc_controller, x0, u0)
%% Set PID Weights and initiate PID specific Variables
kp = 0.008;
kd = 0.001;
ki = 0.006;
% goal = 0;
prev_error = 0;
error = 0;
p = 0; int_g = 0; d = 0;
%% Plot (and control) in real time

% SET UP PLOT
[fig, animatedLines, Tmax, Tmin] = plotSetup1ch();

axis([Tmin,Tmax, 0,1]);
sinusoid_rt = animatedline('Color','r','LineWidth',3);
sinusoid_rt_data = nan(2,10e6);

% INITIALIZATION
[data,control, dataindex, controlindex, prevSamp,previousTimeStamp]=init1ch();
tdata=[0];
tcontrol=[];
pause(0.5)
controlVal = 0;

interval = 1;
checkStateInterval = 25;
currentPred = 0;
featuresEMG = [];
i0 = 1; i1 = 1;

flag = false;
timeElapsedLoop = 0;
loopTime = tic;

featureFig = figure();

while(ishandle(fig)) % run or figure closes
    % SAMPLE ARDUINO
    try
        iterationTime = tic;
        emg = uno.getRecentEMG;% values returned will be between -2.5 and 2.5 , will be a 1 x up to 330
        if ~isempty(emg)
            [~,newsamps] = size(emg); % helps to know how much more data was received
            data(:,dataindex:dataindex+newsamps-1) = emg(1,:); % adds new EMG data to the data vector
            dataindex = dataindex + newsamps; % update sample  
            i1 = dataindex;
            controlindex = controlindex + 1;
        else
            disp('empty array')
        end
    catch
        disp('error')
    end
    if ~isempty(emg)
        % UPDATE
        timeStamp = toc(loopTime); %get timestamp
        % CALCULATE CONTROL VALUES
        try
            switch(controllerInput)
                case 1
                    prev_error = error;
                    error = currentPred - controlVal;
                    try
                        dt = timeStamp - tcontrol(controlindex - 1);
                        d = kd *((error - prev_error)./dt); % derivative gain
                    catch
                        dt = 0;
                        d = 0;
                    end
                    p = kp * error; % proportional gain
                    int_g = int_g + ki * error * dt; % integral gain
                    controlVal = p + d + int_g + controlVal;
                case 2
                    if(currentPred == 0)
                        controlVal = mpc_controller.nlmpcmove(1,controlVal);
                    else
                        controlVal = mpc_controller.nlmpcmove(-1,controlVal);
                    end
            end
            
            if(controlVal > 1)
                controlVal = 1;
            elseif(controlVal < 0)
                controlVal = 0;
            end
            control(1, controlindex) = controlVal;
            % Inference block
            if(mod(interval, checkStateInterval) == 0 && i1 - 1350 > 1)

                switch(featurecount)
                    case 1
                       featuresEMG = getDataFeatures(data(i1 - 1350 : i1-1), 300, 1e3, maxFeature, false);
                    case 2
                       featuresEMG = getDataFeatures(data(i1 - 1350 : i1-1), 300, 1e3, 0.5799, true);
                end

                currentPred = predictedOverallState(testNeuralNetwork(featuresEMG, model));

                plotEMGFeatures(featuresEMG, featureFig);        
                disp(strcat("Inference: ", string(currentPred)));

                i0 = dataindex;
                interval = 1;
                flag = true;
            end
            % end of your code
        catch ME
            disp('Something broke in your code!')
        end

        tcontrol(controlindex)=timeStamp;   
        tempStart = tdata(end);
        tdata(prevSamp:dataindex-1)=linspace(tempStart,timeStamp,newsamps);
        figure(fig);
        
        % Plot RT Sinusoid
        if(isvalid(sinusoid_rt))
            new_point_sin = -0.5.*square(timeStamp/4)+0.5;
            addpoints(sinusoid_rt,timeStamp, new_point_sin);
            sinusoid_rt_data(1,controlindex) = timeStamp; % first row is time data
            sinusoid_rt_data(2, controlindex) = new_point_sin; % second row is sinusoid
            drawnow limitrate
        end

        % UPDATE PLOT
        [Tmax, Tmin] = updatePlot1ch(animatedLines, timeStamp, data, control, prevSamp, dataindex, controlindex, Tmax, Tmin);
        
        % UPDATE HAND
        if(VREconnected) %if connected
            status = updateHand(control, controlindex, command, selectedDigits_Set1, selectedDigits_Set2);
        end
        previousTimeStamp = timeStamp;
        prevSamp = dataindex;
        interval = interval + 1;
        if(flag)
            flag = false;
            timeElapsedLoop = toc(iterationTime);
        end
        if(toc(loopTime) >= 180)
            break;
        end
    end
end
%% Plot the data and control values from the most recent time running the system
data = data(~isnan(data));
control = control(~isnan(control));
finalPlot(data,control,tdata,tcontrol)

%% close the arduino serial connection before closing MATLAB
uno.close; 
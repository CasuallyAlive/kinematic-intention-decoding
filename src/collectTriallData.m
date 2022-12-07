% Author: Jordy A. Larrea Rodriguez
% Data Collection for 1 trial
function [data, tdata, labels] = collectTriallData(uno, timeWindowSize, phaseWindowSize, phasesPerClass)
    loop = tic;
    increments = 1;
    timeStamp = 0;
    warmUpWindowSize = 1000;

    labels = NaN(1,1e6);
    
    restPhase = true;
    class = 1;
    phasesCompleted = 0;

    while increments < warmUpWindowSize
        emg = uno.getRecentEMG;% values returned will be between -2.5 and 2.5 , will be a 1 x up to 330
        pause(0.001);
        increments = increments + 1;
    end
    [~, animatedLines, Tmax, Tmin] = plotSetup1ch();
    [data,control, dataindex, controlindex, prevSamp,~]=init1ch();
    tdata=[0];
    tcontrol=[];
    pause(0.5)

    increments = 1;
    while phasesCompleted < 2*phasesPerClass
        try
            emg = uno.getRecentEMG;% values returned will be between -2.5 and 2.5 , will be a 1 x up to 330
            if(restPhase)
                if(class == 1)
                    disp("Relax, prepare yourself to grasp with your hand.")
                elseif(class == 0)
                    disp("Relax, prepare yourself to completely relax your hand.")
                end
                if(mod(increments,phaseWindowSize) == 0)
                    restPhase = false;
                    increments = 1;
                end
                pause(0.001);
                increments = increments + 1;
                continue;
            end
            if(class == 1)
                disp('Grasp with your hand!')
            elseif(class == 0)
                disp('Relax your hand!')
            end
            if ~isempty(emg)
                [~,newsamps] = size(emg); % helps to know how much more data was received
                data(:,dataindex:dataindex+newsamps-1) = emg(1,:); % adds new EMG data to the data vector
                dataindex = dataindex + newsamps; %update sample count 
                controlindex = controlindex + 1;
            else
                disp('empty array')
            end
        catch m
            disp('error')
        end
        if ~isempty(emg)
         
            tempStart = timeStamp;
            timeStamp = toc(loop);
            tdata(prevSamp:dataindex-1)=linspace(tempStart,timeStamp,newsamps);

            labels(prevSamp:dataindex-1) = class;
            
            if(mod(increments, timeWindowSize) == 0) % conclude phase after a timeWindow has passed
                if(class == 0)
                    class = 1;
                else
                    class = 0;
                end
                disp('Phase Complete!')
                restPhase = true;
                phasesCompleted = phasesCompleted + 1;
                increments = 1;
            end 

            tcontrol(controlindex)=timeStamp;   
            tempStart = tdata(end);
            tdata(prevSamp:dataindex-1)=linspace(tempStart,timeStamp,newsamps);
           
            [Tmax, Tmin] = updatePlot1ch(animatedLines, timeStamp, data, control, prevSamp, dataindex, controlindex, Tmax, Tmin);
    
            prevSamp = dataindex;
        end

        increments = increments + 1;
    end
    disp('Trial Complete!')
end 
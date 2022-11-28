% Author: Jordy A. Larrea Rodriguez
% Data Collection for 1 trial
function [data, tdata, labels] = collectTriallData(uno, dataindex, timeWindowSize, phaseWindowSize, phasesPerClass)
    tic;
    increments = 0;
    restPhase = false;
    class = 1;
    phasesCompleted = 0;

    while phasesCompleted < 2*phasesPerClass
        try
            emg = uno.getRecentEMG;% values returned will be between -2.5 and 2.5 , will be a 1 x up to 330
            if(increments < timeWindowSize || restPhase)
                if(increments < timeWindowSize || class == 1)
                    disp("Relax, prepare yourself to grasp with your hand.")
                elseif(class == 0)
                    disp("Relax, prepare yourself to completely relax your hand.")
                end
                if(restPhase && mod(increments, phaseWindowSize) == 0)
                    restPhase = false;
                end
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
            else
                disp('empty array')
            end
        catch
            disp('error')
        end
        if ~isempty(emg)
            timeStamp = toc;
            tempStart = tdata(end);
            tdata(prevSamp:dataindex-1)=linspace(tempStart,timeStamp,newsamps);

            labels(prevSamp:dataindex-1) = class;
            
            prevSamp = dataindex;
            if(mod(increments, timeWindowSize) == 0) % conclude phase after a timeWindow has passed
                if(class == 0)
                    class = 1;
                else
                    class = 0;
                end
                disp('Phase Complete!')
                restPhase = true;
            end
        end
        increments = increments + 1;
    end
    disp('Trial Complete!')
end 
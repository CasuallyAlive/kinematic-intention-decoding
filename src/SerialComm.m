classdef SerialComm < handle
    % This class for connecting to, reading from, and closing the TASKA fingertip sensors
    %
    % Note: It is currently hard-coded for eight sensors (4 IR, 4 baro),
    % but could be adapted for other sensor counts
    %
    % Example usage:
    % TS = TASKASensors;
    % TS.Status.IR or TS.Status.BARO would display IR or baro data,
    % respectively
    %
    % Version: 20210222
    % Author: Tyler Davis
    
    properties
        ARD; COMStr; Status; Ready; Count; 
        DataBuffer;
    end
    
    methods
        function obj = SerialComm(varargin)
            obj.Ready = false;
            obj.DataBuffer = zeros(1,330);
            obj.Status.ElapsedTime = nan;
            obj.Status.CurrTime = clock;
            obj.Status.LastTime = clock;
            obj.Count=0;
            if nargin
                COMPort=varargin{1};
                init(obj,COMPort);
            else
                init(obj);
            end
        end
        function init(obj,varargin)
            if nargin>1
                COMPort=varargin{1};
                if ~isempty(COMPort)
                    obj.COMStr = sprintf('COM%0.0f',COMPort(1));
                end
            else
                devs = getSerialID;
                if ~isempty(devs)
                    COMPort = cell2mat(devs(~cellfun(@isempty,regexp(devs(:,1),'Arduino Uno')),2));
                    if ~isempty(COMPort)
                        obj.COMStr = sprintf('COM%0.0f',COMPort(1));
                    else
                        COMPort = cell2mat(devs(~cellfun(@isempty,regexp(devs(:,1),'USB-SERIAL CH340')),2));
                        if ~isempty(COMPort)
                            obj.COMStr = sprintf('COM%0.0f',COMPort(1));
                        end
                    end
                end
            end
            delete(instrfind('port',obj.COMStr));
            obj.ARD = serialport(obj.COMStr,9600,'Timeout',1); %9600
            configureCallback(obj.ARD,"terminator",@obj.read);
            flush(obj.ARD);
            pause(0.1);
            obj.Ready = true;
        end
        function close(obj,varargin)
            if isobject(obj.ARD)
                delete(obj.ARD);
            end
        end
        function read(obj,varargin)
            try
                % read data & update status
                obj.Status.Data = sscanf(readline(obj.ARD),'%d %d');
                obj.Status.CurrTime = clock;
                obj.Status.ElapsedTime = etime(obj.Status.CurrTime,obj.Status.LastTime);
                obj.Status.LastTime = obj.Status.CurrTime;
                % store data into buffer
                obj.DataBuffer = circshift(obj.DataBuffer,-1,2);
                obj.DataBuffer(:,end) = obj.Status.Data;
                obj.Count=obj.Count+1;
            catch
                disp('Serial communication error!')
            end
        end
        function EMG = getEMG(obj,varargin)
            EMG=obj.DataBuffer/1024*5-2.5;
        end
        
        function EMG = getRecentEMG(obj,varargin)
            lastIdx = length(obj.DataBuffer);
            startIdx = lastIdx-obj.Count;
            if startIdx<1
                startIdx=1;
            end
%             if startIdx==lastIdx
%                 EMG = [];
%             else
                EMG = obj.DataBuffer(:,startIdx:end)/1024*5-2.5;
                obj.Count=0;
%             end

        end
    end    
end %class
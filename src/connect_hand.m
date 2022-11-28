function [model_info, movements,command, selectedDigits_Set1, selectedDigits_Set2, VREconnected] = connect_hand
% This function gets all the necessary variables to control the MuJoCo hand
% as well as sets up a communication between MATLAB and and the virtual
% hand.
try    
% CONNECT TO MUJOCO
    addpath('apimex')
    hx_close
    hx_connect('')
    model_info = hx_robot_info
    
    % SET UP MOVEMENTS
    movements = [0; ...     %(1) wrist pronation/supination
                 0; ...     %(2) wrist deviation
                 0; ...     %(3) wrist flexion/extension
                 1.62; ...  %(4) thumb abduction/adduction
                 0; ...     %(5) thumb flexion/extension (at base)
                 0; ...     %(6) thumb flexion/extension (at first joint - most proximal)
                 0; ...     %(7) thumb flexion/extension (at last joint - most distal)
                 0; ...     %(8) index abduction/adduction
                 0; ...     %(9) index flexion/extension
                 0; ...     %(10) middle flexion/extension
                 0; ...     %(11) ring flexion/extension
                 0; ...     %(12) pinky abduction/adduction
                 0;];       %(13) pinky flexion/extension

    % SET UP COMMAND
    command = struct('ref_pos', movements, ...        %reference position
                'ref_vel', zeros(13,1), ...
                'gain_pos', zeros(13,1), ...            
                'gain_vel', zeros(13,1), ...
                'ref_pos_enabled', 1, ...
                'ref_vel_enabled', 0, ...
                'gain_pos_enabled', 0, ...
                'gain_vel_enabled', 0);

    % The following code determine what control you provide to the hand model. 
    % Currently it's configured so that you have control over the fingers and
    % the wrist. The value you send to the hand determine the position of the
    % fingers and wrist. A value of 0 for C1 is an open hand (full extension of
    % all fingers) and a value of 1 for C1 is a closed hand (full flexion of all
    % fingers). Similarly, for C2, a value of 0 is an extended wrist, whereas a
    % value of 1 is a fully flexed wrist.

    % SET UP CONTROLLABLE DEGREES OF FREEDOM
    selectedDigits_Set1 = [5,6,7,9,10,11,13]; %fingers only (see indexes above)
    selectedDigits_Set2 = [3];                %wrist flexion only
    VREconnected = 1; %flag showing connection is complete
    disp('VRE connected! :D')
catch
    model_info=NaN;
    movements=NaN;
    command=NaN;
    selectedDigits_Set1=NaN;
    selectedDigits_Set2=NaN;
    VREconnected = 0;
    disp('VRE failed to connect. :(')
end
end
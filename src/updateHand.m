function status = updateHand(control,controlindex, command,selectedDigits_Set1,selectedDigits_Set2)
% status = updateHand(control,controlindex, command,selectedDigits_Set1,selectedDigits_Set2)
% this function updates the virtual MuJoCo hand with the selected degrees
% of freedom.
% control is the control vector, it should have values between -1 and 1 for
% each degree of freedom controlled. 
% controlindex is the current timepoint control index
% command is a struct that was returned from connect_hand.m
% selectedDigits_Set1,selectedDigits_Set2 are the degrees of freedom that
% will be controlled in the virtual hand, they are set up in
% connect_hand.m.
% status is the variable returned
    controlValues = control(:,controlindex);
    controlValues(controlValues>1) = 1; %check bounds
    controlValues(controlValues<-1) = -1; %check bounds
    controlValues(isnan(controlValues)) = 0; %check data
    
    movements(selectedDigits_Set1) = controlValues(1); %set finger control to c1 value
    movements(4)=1.62;% added for demo
    movements(12)=.25;% added for demo
%     movements(selectedDigits_Set2) = .2-controlValues(2); %set wrist control to c2 value
    command.ref_pos = movements; %update command
    status = hx_update(command); %send command to model
end
%{

MIT Motorsports Brake Calculations for MY22
Written by Aaron Becker during 2021-2022 IAP

This file contains several functions used to print out calculated
values when running the biasesMain.m file.

%}


% Export helper functions contained in file to importable scope in main
% file
function [f1, f2] = biasesHelper_PrintFns
    f1 = @printIdealAccel;
    f2 = @printIdealPressuresRatiosBores;
end


%{
printIdealAccel takes the output of calcIdealAccel and prints it nicely.
Arguments:
    ideal_brake_ratio: calculated brake ratio
    maxAccel: calculated maximum deceleration of vehicle
    nF (float), N: normal force when braking, front
    nR (float), N: normal force when braking, rear
    fF (float), N: longitudinal force when braking, front
    fR (float), N: longitudinal force when braking, rear
    longPrint (bool): whether to print out all values, or just a smaller
    subset
%}
function [] = printIdealAccel(ideal_brake_ratio, maxAccel, nF, nR, fF, fR, longPrint)
    if longPrint == 1
        fprintf("Front - Rear Split: %.3f - %.3f\n" + ...
            "ReacFront: %.3f N\n" + ...
            "ReacRear: %.3f N\n" + ...
            "LongForceFront: %.3f N\n" + ...
            "LongForceRear: %.3f N\n" + ...
            "Max Deceleration: %.3f m/s^2\n", 1-ideal_brake_ratio, ideal_brake_ratio, nF, nR, fF, fR, maxAccel);
    else
        fprintf("Front - Rear Split: %.3f - %.3f\n" + ...
            "Max Deceleration: %.3f m/s^2\n", 1-ideal_brake_ratio, ideal_brake_ratio, maxAccel);
    end
end

%{
printIdealPressuresRatiosBores takes the output of
calcIdealPressuresRatiosBores and prints it nicely.
Arguments:
    btF (float), Nm: maximum braking torque, front
    btR (float), Nm: maximum braking torque, rear
    frontPressure (float), Pa: Brake line pressure, front loop
    rearPressure (float), Pa: Brake line pressure, rear loop
    ideal_rear_bore (float), m: Master cylinder rear bore size
    ideal_front_bore (float), m: Master cylinder front bore size
    ideal_bias_ratio (float): Bias bar ratio using above master cylinder sizing (should be close to 0.5)
    ideal_pedal_ratio (float): Pedal ratio of driver input to 
    longPrint (bool): whether to print out all values, or just a smaller
    subset
%}
function [] = printIdealPressuresRatiosBores(btF, btR, frontPressure, rearPressure, ideal_rear_bore, ideal_front_bore, ideal_bias_norm_dist, ideal_pedal_ratio, longPrint)
    pa_to_psi = 0.000145038; % pascal to psi
    m2in = 39.3701; % meters to inches

    if longPrint == 1
        fprintf("Braking torque, front - rear: %.3f Nm - %.3f Nm \n" + ...
            "Front - rear line pressure: %.3f psi - %.3f psi \n" + ...
            "Ideal front - rear master cylinder bore sizes: %.3f in - %.3f in \n" + ...
            "Bias bar normalized distance at ideal MC ratio (~0.5?): %.3f \n" + ...
            "Pedal ratio at ideal MC ratio: %.3f \n", btF, btR, frontPressure*pa_to_psi, rearPressure*pa_to_psi, ideal_front_bore*m2in, ideal_rear_bore*m2in, ideal_bias_norm_dist, ideal_pedal_ratio);
    else
        fprintf("Front - rear line pressure: %.3f psi - %.3f psi \n" + ...
            "Ideal front - rear master cylinder bore sizes: %.3f in - %.3f in \n" + ...
            "Bias bar normalized distance at ideal MC ratio (~0.5?): %.3f \n" + ...
            "Pedal ratio at ideal MC ratio: %.3f \n", frontPressure*pa_to_psi, rearPressure*pa_to_psi, ideal_front_bore*m2in, ideal_rear_bore*m2in, ideal_bias_norm_dist, ideal_pedal_ratio);
    end
end
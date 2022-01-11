%{

MIT Motorsports Brake Calculations for MY22
Written by Aaron Becker during 2021-2022 IAP

This file contains several functions used to calculate ideal parameters for the car, when run in the biasesMain.m file.

%}


% Export helper functions contained in file to importable scope in main
% file
function [f1, f2, f3] = biasesHelper_CalcFns
    f1 = @getSweptAccel;
    f2 = @calcIdealAccel;
    f3 = @calcIdealPressuresRatiosBores;
end

%{
getSweptAccel takes a tire fit, car parameter struct, and brake normal force ratio and gets
the acceleration value given a brake ratio.
Arguments:
    t_coeffs (float): tire normal force vs long braking force coefficients of fit
    ratio (float): brake normal force ratio nF/nR
    c (struct): car parameters struct

Returns:
acceleration - float, max acceleration at this value
no_rot_accel - float, acceleration value required so the car doesn't rotate

Note: the way this works, is that there is actually two acceleration
values, one where there is the car's acceleration from a simple F=MA calculation and
one where the car does not rotate (physical constraint). Both valeus are
calculated given the maximum tire forces for each wheel, which satisfies
the maximum force at each wheel constraint.
The place at which they intersect (maximum acceleration, and no rotation)
is the ideal amount of deceleration.
%}
function [accel, no_rot_accel] = getSweptAccel(t_coeffs, c, ratio)
    g = c.g;
    M = c.m_tot; % mass of car
    H = c.H_cg; % height of CG
    tF = c.l_WB*(1-c.RWB); % wheelbase dist from CM to front
    tR = c.l_WB*c.RWB; % wheelbase dist from CM to rear

    nR = (M*g)*ratio; % normal force, rear
    nF = (M*g)*(1-ratio); % normal force, rear
    fR = 2*polyval(t_coeffs, -nR/2); % long. braking force, rear wheel (+Ihat direction)
    fF = 2*polyval(t_coeffs, -nF/2); % long. braking force, front wheel (+Ihat direction)
    
    accel = (fF+fR)/M; % simple f=ma acceleration
    no_rot_accel = ((nR*tR) - (tF*nF)) / (-M*H); % derived from moments; solves for Izz*alpha=0
end

%{
calcIdealAccel calcuates the ideal brake ratio, normal and longitudinal forces from the calculated accelerations.
Arguments:
    accels (mat): 1d array of acceleration values, from f=ma
    accelsNR (mat): same thing, except gives value where car will not
    rotate

The function works by finding the intersection of both using a
GriddedInterpolant (linear interpolation between each value) and then
computes the acceleration from that intersection.
%}

function [nR, nF, fR, fF, maxAccel, ideal_brake_ratio] = calcIdealAccel(c, t_coeffs, ratios_int, accels, accelsNR)
    accelInt = griddedInterpolant(ratios_int, accels);
    accelNRInt = griddedInterpolant(ratios_int, accelsNR);
    diff = @(x) accelInt(x) - accelNRInt(x);
    ideal_brake_ratio = fzero(diff, 1); % when the values are the same (i.e. zero) we have the ideal acceleration
    
    g = c.g;
    M = c.m_tot;
    nR = (M*g)*ideal_brake_ratio; % normal force, rear
    nF = (M*g)*(1-ideal_brake_ratio); % normal force, front
    fR = 2*polyval(t_coeffs, -nR/2); % braking force, rear wheels
    fF = 2*polyval(t_coeffs, -nF/2); % braking force, front wheels
    maxAccel = (fF+fR)/M;
end

%{
calcIdealBiasAndPedalRatios calculates the ideal line pressure, bore size,
and pedal ratio used in the car from longitudinal forces at maximum
deceleration.

Arguments:
    c (struct): car data
    fR (float), N: rear longitudinal braking force
    fF (float), N: front longitudinal braking force
%}
function [btF, btR, frontPressure, rearPressure, ideal_rear_bore, ideal_front_bore, ideal_bias_norm_dist, ideal_pedal_ratio] = calcIdealPressuresRatiosBores(c, fR, fF)
    % braking torque, front and rear per wheel, Nm
    % we divide by 2 to calculate torque per wheel, not per side
    btR = (c.r_tire*fR)/2;
    btF = (c.r_tire*fF)/2;
    % caliper force on each brake pad, N
    calipFR = btR/c.r_calip;
    calipFF = btF/c.r_calip;
    % caliper normal force, N
    calipNR = calipFR/c.mu_calip;
    calipNF = calipFF/c.mu_calip;
    % front/rear brake line pressure, Pa
    calip_piston_area = pi*(c.r_calip_piston^2)*c.calip_piston_count; % m^2, both sides of caliper
    rearPressure = calipNR/calip_piston_area; % hydraulic line pressure, Pa
    frontPressure = calipNF/calip_piston_area;

    % functions to calculate bore area and pedal ratio
    mcBoreToArea = @(mc_bore_dia) pi .* ((mc_bore_dia ./ 2) .^ 2) .* c.mc_piston_count; % m^2
    mcAreaToPedalRatio = @(mc_area_rear, mc_area_front) ((mc_area_front .* frontPressure) + (mc_area_rear .* rearPressure)) ./ (c.ideal_driver_pedal_force); % unitless ratio

    % create meshgrid for front and rear master cylinder area possibilities
    mc_areas = mcBoreToArea(c.mc_bores); % master cylinder area, m^2
    [mc_areas_R, mc_areas_F] = meshgrid(mc_areas); % generate grid of master cylinder possibilities for rear and front
    
    % calculate pedal ratio combinations for rear and front
    pedal_ratios = mcAreaToPedalRatio(mc_areas_R, mc_areas_F);

    % calculate bias ratio combinations
    bias_constant = (rearPressure .* mc_areas_R) ./ (frontPressure .* mc_areas_F);
    bias_ratios = bias_constant ./ (1 + bias_constant);

    % find ideal bias ratio/pedal ratio and bore sizes
    bias_ratios_error = bias_ratios - c.ideal_bias_ratio;
    min_error = min(bias_ratios_error(:));
    [best_row, best_col] = find(bias_ratios_error == min_error); % column -> front, row -> rear

    % now that we know the minimum error bias ratio, use that to find the
    % best bores and pedal ratio
    ideal_rear_bore = c.mc_bores(best_row);
    ideal_front_bore = c.mc_bores(best_col);
    ideal_bias_norm_dist = bias_ratios(best_col, best_row);
    ideal_pedal_ratio = pedal_ratios(best_col, best_row);
end
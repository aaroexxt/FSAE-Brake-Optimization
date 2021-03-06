%{

MIT Motorsports Brake Calculations for MY22
Written by Aaron Becker during 2021-2022 IAP

%}


% Pull in constant data
clear all;
load("tiremax.mat");
tire_force_f_long = values(2, :);
tire_force_n = values(1, :);

% Pull in car constant data
c = CarParametersMY2021;

% Pull in functions from helpers as global functions
warning('off', "MATLAB:declareGlobalBeforeUse");
global getSweptAccel
global calcIdealAccel
global calcIdealPressuresRatiosBores
global printIdealAccel
global printIdealPressuresRatiosBores
[printIdealAccel, printIdealPressuresRatiosBores] = biasesHelper_PrintFns;
[getSweptAccel, calcIdealAccel, calcIdealPressuresRatiosBores] = biasesHelper_CalcFns;


% Change this to 0 to print and graph true car ideal values, and 1 to run basic
% validation tests that slightly modify the car data and compare the result
VALIDATION_MODE_ACTIVE = 0;

if VALIDATION_MODE_ACTIVE
    % run several validation tests
    fprintf("\nintitial car values:\n")
    calcAndPrintIdealValues(c, tire_force_n, tire_force_f_long, 0);

    % Test 1
    fprintf("\n\nCar is now 1.5x heavier; expecting less deceleration\n")
    c.m_tot = c.m_tot*1.5;
    calcAndPrintIdealValues(c, tire_force_n, tire_force_f_long, 0);
    c.m_tot = c.m_tot/1.5;
    
    % Test 2
    c.l_WB = c.l_WB*1.5;
    fprintf("\n\nCar is now 1.5x longer; expecting more deceleration\n")
    calcAndPrintIdealValues(c, tire_force_n, tire_force_f_long, 0);
    c.l_WB = c.l_WB/1.5;

else
    disp("True car ideal values:");
    calcAndPrintIdealValues(c, tire_force_n, tire_force_f_long, 1); % use mode 2 to graph
end



%{
calcAndPrintIdealValues takes tire and car data and calculates and prints
the ideal car values for that particular combination.
This is useful especially when we need to run a lot of tests with only
minor changes to the parameters (such as for validation).

Arguments:
c (struct) - Car data struct
tire_force_n (mat) - Tire normal forces (just before slip)
tire_force_f_long (mat) - Longitudinal forces generated by tire (just
before slip)
calc_mode (int) - See table below

Calc Mode Setting | What It Does
0 -> Just print basic maximum acceleration and split (for validation)
1 -> Print maximum acceleration and additional parameters, as well as bores,
ideal bias/pedal ratio, and line pressures
2 -> Everything in mode 1, and also graphs acceleration and tire forces

%}
function [] = calcAndPrintIdealValues(c, tire_force_n, tire_force_f_long, calc_mode)
    % use imported functions from other files
    global getSweptAccel
    global calcIdealAccel
    global calcIdealPressuresRatiosBores
    global printIdealAccel
    global printIdealPressuresRatiosBores

    if calc_mode > 2 || calc_mode < 0
        error("Mode "+calc_mode+" invalid, use a value from 0-2")
    end

    % Generate tire normal force vs. long force fit
    if isfile("cached_tire_fit.mat")
        t_coeffs = matfile("cached_tire_fit.mat").t_coeffs;
    else
        % generate coeffs and cache result
        t_coeffs = polyfit(tire_force_n, tire_force_f_long, 3);
        save("cached_tire_fit.mat", "t_coeffs")
    end
    
    % Calculate acceleration on brake ratio interval of 0 to 1 (all rear to
    % all front)
    ratios_int = linspace(0, 1, 1000);
    accels = zeros(size(ratios_int));
    accelsNR = zeros(size(ratios_int));
    for idx = 1 : length(ratios_int)
        ratios = ratios_int(idx);
        [aOut, aNR] = getSweptAccel(t_coeffs, c, ratios);
        accels(idx) = aOut;
        accelsNR(idx) = aNR;
    end
    
    % Get ideal acceleration and vehicle parameters associated with it (in
    % any mode)
    [nR, nF, fR, fF, maxAccel, ideal_brake_ratio] = calcIdealAccel(c, t_coeffs, ratios_int, accels, accelsNR);
    
    % Mode 0, just print basic acceleration and split
    if calc_mode == 0
        printIdealAccel(ideal_brake_ratio, maxAccel, nF, nR, fF, fR, 0)
    else
        % Mode 1 or 2, print pressure ratios and bores
        printIdealAccel(ideal_brake_ratio, maxAccel, nF, nR, fF, fR, 1)
        [btF, btR, frontPressure, rearPressure, ideal_rear_bore, ideal_front_bore, ideal_bias_norm_dist, ideal_pedal_ratio] = calcIdealPressuresRatiosBores(c, fR, fF);
        printIdealPressuresRatiosBores(btF, btR, frontPressure, rearPressure, ideal_rear_bore, ideal_front_bore, ideal_bias_norm_dist, ideal_pedal_ratio, 1)
    end
    
    % Mode 2, graph relevant values
    if calc_mode == 2
        clf;
        tiledlayout(1, 2);
        
        nexttile;
        hold on;
        plot(ratios_int, accels);
        plot(ratios_int, accelsNR);
        title("Acceleration (m/s^2) vs Brake Ratio");
        xlabel("Brake Ratio (nF/nR)");
        ylabel("Acceleration (m/s^2)");
        legend("Acceleration", "Acceleration Without Rotation")
        
        nexttile
        hold on;
        vals = linspace(-3500, 500, 3000);
        plot(vals, polyval(t_coeffs, vals), "r", "LineWidth", 2);
        plot(tire_force_n, tire_force_f_long, "b+", "MarkerSize", 0.5);
        title("Reaction Force (N) vs Longitudinal Braking Force (N)")
        xlabel("Tire Normal Force (N)")
        ylabel("Longitudinal Braking Force (N)")
        legend("Red=fit", "Blue=discrete points")
        hold off;
    end

end

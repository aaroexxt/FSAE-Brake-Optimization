%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Car Parameters File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We'll store the parameters in an structured array
function [CarParameters] = CarParametersMY2021()
    in2m = 0.0254;
%     We will return the car parameters as a structure,
%     This is more performant than reading from disk 
    c = struct();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Mass Properties
    c.m_tot = 340;                       % Total Vehicle Mass (kg)

    c.m_unsprg_f = 20;                      % Front unsprung mass [kg]
    c.m_unsprg_r = 10;                    % Rear unsprung mass [kg]

    c.g = 9.81;                             % Gravitational constant (m/s^2)
    c.I_zz = 180.49;                        % Vehicle Moment of Inertia

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Physical Dimensional Properties 
    c.t_f = 48 * in2m;                    % Track Width, Front (in*m/in)
    c.t_r = c.t_f;                          % Track Width, Rear (m)
    c.l_WB = 60 * in2m;                     % Wheelbase Length (in*m/in)

    c.RWB = 0.50;                        % Rear Weight Bias (%)
    c.RWB_sprg = 0.51;                    % Rear weight Bias of sprung mass only (includes A arms) [%]

    c.H_cg =        10  *in2m;                      % Height to C.G. from ground plane, Z axis (in*m/in)
    c.H_cg_sprg =   10  *in2m;                % Height to the sprung C.G. from ground plane Z axis [in*M/in]
    c.H_cg_unsprg = 8    *in2m;             % Height of unsprung C.G. from ground approximated as middle of wheel Z axis [in*M/in]

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Suspension Properties
    c.z_rc_f = 0.375*in2m;                                              % Front Roll Center Height from ground plane, Z axis (in*m/in)
    c.z_rc_r = 0.361*in2m;                                              % Rear Roll Center Height from ground plane, Z axis (in*m/in)
    
    c.K_roll_total = 42791;                                               % Total Roll Stiffness (Nm/rad)
    c.K_roll_f =  21500;                                                  % Front Roll Stiffness (Nm/rad)       
   
    c.TLLTD_r = 0.5245;                                                     %  Start with a TLLTD_r that is the RWB - 5%
    c.roll_gradient_rad = -deg2rad(.85)/c.g;                                % Start with a desired roll gradient of 1 degree per lateral g.

    c.K_spring_f = 200*175.126835;                                        % Front Spring Rate (lbs/in*(in/lbs*N/m))
    c.K_spring_r = 200*175.126835;                                        % Rear Spring Rate (lbs/in*(in/lbs*N/m))

    c.K_tire = 105000;

    c.IR_f = 0.96;                                                       % Installation Ratio Front
    c.IR_r = 0.96;                                                       % Installation Ratio Rear 
    
    c.camber = [0 0 0 0];


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Aerodynamic Properties
    c.rho_air = 1.1455;             % Density of air at 35 degrees C, (kg/m^3)
    c.C_d_A = 1.64;   % stefan cfd my20                          
    c.C_l_A = 3.27;   % stefan cfd my20
    c.X_cp = 36.5 * .0254; % my19 cfd value from stefan ride height pitch roll study
    c.Y_cp = 23.3 * .0254; % my19 cfd value from stefan ride height pitch roll study

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Wheel/Tire Properties

    c.r_tire = 8 * in2m;       % Radius of tire, m

    c.J =  0.322;
    c.b_viscous = 0.1;
    
    c.ideal_bias_ratio = 0.5; % ideal bias ratio

    %%%% Brake specific values
    c.r_calip = 3.5 * in2m; % Radius of caliper, m
    c.r_calip_piston = 0.625 * in2m; % caliper piston radius, m
    c.calip_piston_count = 2; % caliper piston count
    c.mc_piston_count = 1; % master cylinder piston count
    c.mu_calip = 0.32; % coefficient of friction of brake caliper
    c.ideal_driver_pedal_force = 1000; % ideal driver brake force, N
    c.mc_bores = [(13/16), (15/16), (3/4), (5/8), (7/10), (7/8), 1] .* in2m; % bores of master cylinders, m

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Powertrain Properties
    c.P_max = 80000;
    c.GR = [7 7 48/15 48/15];                                               % Front and rear powertrain gear ratio
    
    c.drive = 'AWD';                                                   % Driven wheel configuration
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
%     Return Car Parameters
    CarParameters = c;
    
end
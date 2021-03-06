%----------------------------------------------------------------
% Template created for the course SD2231 by Mikael Nybacka 2013
% Following file is the start file for the state estimation using
% Uncented Kalman Filter (UKF).
%----------------------------------------------------------------
clear all;
close all;
clc;
addpath('scripts')
addpath('logged_data')
disp(' ');

% Set global variables so that they can be accessed from other matlab
% functions and files
global lf lr Cf Cr mass Iz vbox_file_name

%----------------------------
% LOAD DATA FROM VBOX SYSTEM
%----------------------------
%vbox_file_name='logged_data/Lunda_test_140411/Stand_Still_no2.VBO'; %stand still logging, engine running
vbox_file_name='logged_data/Lunda_test_140411/Circle_left_R13m_no2.VBO'; %circle test left, roughly 13m in radius
%vbox_file_name='logged_data/Lunda_test_140411/Slalom_35kph.VBO'; %slalom entry to the left @ first cone, 35kph
%vbox_file_name='logged_data/Lunda_test_140411/Step_Steer_left_80kph.VBO'; %Step steer to the left in 80kph
%vbox_file_name='logged_data/Lunda_test_140411/SWD_80kph.VBO'; %Sine with dwell, first turn to the right, 80kph

vboload
%  Channel 1  = satellites
%  Channel 2  = time
%  Channel 3  = latitude
%  Channel 4  = longitude
%  Channel 5  = velocity kmh
%  Channel 6  = heading
%  Channel 7  = height
%  Channel 8  = vertical velocity kmh
%  Channel 9  = steerang
%  Channel 10 = vxcorr
%  Channel 11 = slipcorr
%  Channel 12 = event 1 time
%  Channel 13 = rms_hpos
%  Channel 14 = rms_vpos
%  Channel 15 = rms_hvel
%  Channel 16 = rms_vvel
%  Channel 17 = latitude_raw
%  Channel 18 = longitude_raw
%  Channel 19 = speed_raw
%  Channel 20 = heading_raw
%  Channel 21 = height_raw
%  Channel 22 = vertical_velocity_raw
%  Channel 23 = true_head
%  Channel 24 = slip_angle 
%  Channel 25 = pitch_ang. 
%  Channel 26 = lat._vel.
%  Channel 27 = yaw_rate
%  Channel 28 = roll_angle 
%  Channel 29 = lng._vel.
%  Channel 30 = slip_cog
%  Channel 31 = slip_fl
%  Channel 32 = slip_fr
%  Channel 33 = slip_rl
%  Channel 34 = slip_rr
%  Channel 35 = yawrate
%  Channel 36 = x_accel
%  Channel 37 = y_accel
%  Channel 38 = temp
%  Channel 39 = pitchrate
%  Channel 40 = rollrate
%  Channel 41 = z_accel

%-----------------------------------
% SET VEHICLE DATA FOR THE VOLVO V40
%-----------------------------------
Rt=0.312;           % Tyre radius (m)
lf=0.41*2.55;       % Distance from CoG to front axis (m)
lr=2.55-lf;         % Distance from CoG to rear axis (m)
L=lf+lr;            % Wheel base (m)
h=0.2*L;            % Hight from ground to CoG (m)
mass=1435-80;       % Mass (kg)
Iz=2380;            % Yaw inertia (kg-m2)
tw=1.565;           % Track width (m)
Ratio=17;           % Steering gear ratio
Cf=0.7*100000;          % Lateral stiffness front axle (N/rad) [FREE TO TUNE]
Cr=0.7*100000;          % Lateral stiffness rear axle (N/rad) [FREE TO TUNE]
Lx_relax=0.05;      % Longitudinal relaxation lenth of tyre (m)
Ly_relax=0.15;      % Lateral relaxation lenth of tyre (m)
Roll_res=0.01;      % Rolling resistance of tyre
rollGrad=5*(pi/180);% Rollangle rad per g (rad/g)
rx=0.4;             % Distance from IMU to CoG x-axle (m)
ry=0;               % Distance from IMU to CoG y-axle (m)
rz=0;               % Distance from IMU to CoG z-axle (m)

%--------------------------------------
% SET ENVIRONEMNTAL PARAMETERS FOR TEST
%--------------------------------------
Mu=0.95;             % Coefficient of friction
g=9.81;             % Gravity constant (m/s^2)


%--------------------------------------------
% SET VARIABLES DATA FROM DATA READ FROM FILE
%--------------------------------------------
trim_start=1;
trim_end=length(vbo.channels(1, 2).data);

Time=(vbo.channels(1, 2).data(trim_start:trim_end,1) - vbo.channels(1, 2).data(1,1));
yawRate_VBOX = vbo.channels(1, 35).data(trim_start:trim_end,1).*(-pi/180); %signal is inverted hence (-)
vx_VBOX = vbo.channels(1, 5).data(trim_start:trim_end,1)./3.6;
vy_VBOX = vbo.channels(1, 26).data(trim_start:trim_end,1)./3.6;
ax_VBOX = vbo.channels(1, 36).data(trim_start:trim_end,1).*g;
ay_VBOX = vbo.channels(1, 37).data(trim_start:trim_end,1).*g;
Beta_VBOX = vbo.channels(1, 30).data(trim_start:trim_end,1).*(pi/180);
SWA_VBOX=vbo.channels(1, 9).data(trim_start:trim_end,1).*(pi/180)/Ratio;

% Taking away spikes in the data
for i=1:length(Time)
    if (i>1)
        if (abs(SWA_VBOX(i,1)-SWA_VBOX(i-1))>1 || abs(SWA_VBOX(i,1))>7)
            SWA_VBOX(i,1)=SWA_VBOX(i-1);
        end
    end
end
n = length(Time);
dt = Time(2)-Time(1);

%----------------------------------------------
% SET MEASUREMENT AND PROCESS NOICE COVARIANCES
%----------------------------------------------
% Use as starting value 0.1 for each of the states in Q matrix
Q=[ 0.1 0   0;
    0   0.1 0;
    0   0   0.1];

% Use as starting value 0.01 for each of the measurements in R matrix
R=[ 0.01 0   0;
    0   0.01 0;
    0   0   0.01];


%--------------------------------------------------
% SET INITIAL STATE AND STATE ESTIMATION COVARIANCE
%--------------------------------------------------
x_0=[vx_VBOX(1);0;yawRate_VBOX(1)];
P_0= Q;%0.1*eye(3);%[1 1 1;1 1 1;1 1 1];


%-----------------------
% INITIALISING VARIABLES
%-----------------------


%Parameters that might be needed in the measurement and state functions are added to predictParam
predictParam.dt=dt; 
predictParam.Fz = mass*g;
predictParam.mu = Mu;
predictParam.use_tyre_simple = 0; %use the simple tyre model or not


% Handles to state and measurement model functions.
state_func_UKF = @Vehicle_state_eq;
meas_func_UKF = @Vehicle_measure_eq;

%-----------------------
% FILTERING LOOP FOR UKF 
%-----------------------
disp(' ');
disp('Filtering the signal with UKF...');

M = x_0;
P = P_0;
vx = [];
vy = [];


for i = 2:n


    % ad your predict and update functions, see the scripts ukf_predict1.m
    % and ukf_update1.m
    predictParam.delta = SWA_VBOX(i);
    Y = [vx_VBOX(i);ay_VBOX(i)+rx*yawRate_VBOX(i);yawRate_VBOX(i)];
    [M,P] = ukf_predict1(M,P,state_func_UKF,Q,predictParam);%,alpha,beta,kappa,0);
    [M,P,K,MU,S,LH] = ukf_update1(M,P,Y,meas_func_UKF,R,predictParam);%,alpha,beta,kappa,0);

    
    
    if i==round(n/4)
        disp(' ');
        disp('1/4 of the filtering done...');
        disp(' ');
    end
    if i==round(n/2)
        disp(' ');
        disp('1/2 of the filtering done...');
        disp(' ');
    end
    if i==round(n*(3/4))
        disp(' ');
        disp('3/4 of the filtering done... Stay tuned for the results...');
        disp(' ');
    end
    
    vx = [vx;M(1,:)];
    vy = [vy;M(2,:)];
end

%----------------------------------------
% CALCULATE THE SLIP ANGLE OF THE VEHICLE
%----------------------------------------
mybeta = atan(vy./vx);
washout = 0;
if washout == 1
    %Estimation
    %Init_for_washout_filter
    vx2 = vx_VBOX;
    SWA = SWA_VBOX;
    vy_mod = vx2.*(lr*(lf+lr)*Cf*Cr-lf*Cf*mass.*vx2.*vx2)./(((lf+lr)^2*Cr*Cf+mass.*vx2.*vx2*(lr*Cr-lf*Cf))).*SWA;
    beta_mod = atan(vy_mod./vx_VBOX);


    %Measurment
    ay_m.time = Time;
    ay_m.signals.values = ay_VBOX;%+rx.*yawRate_VBOX;
    yawRate_m.time = Time;
    yawRate_m.signals.values = yawRate_VBOX;
    vx_m.time = Time;
    vx_m.signals.values = vx_VBOX;%-ry*yawRate_VBOX;
    sim measurments

    %Wash-out
    %T = abs((yawRate_VBOX)).*3;%50;%+3*abs(yawRate_VBOX);%0.4;
    %T_m.time = Time;
    %T_m.signals.values = T;

    SWA_m.time = Time;
    SWA_m.signals.values = SWA;

    T = 0.4;%0.4
    K_yaw_diff = 0.15/10*3*5;
    K_yaw_diff2 = 1*45.2489;
    K_smooth = 1*15;%10 for circle
    K_smooth_2 = 1*0.5*2;
    K_smooth_3 = 10*1;
    vy_mod_m.time = Time;
    vy_mod_m.signals.values = vy_mod;
    power = 8.4;

    vy_mod_m.time = Time;
    vy_mod_m.signals.values = vy_mod;


    sim washout
end

%---------------------------------------------------------
% CALCULATE THE ERROR VALES FOR THE ESTIMATE OF SLIP ANGLE
%---------------------------------------------------------
Beta_VBOX_smooth=smooth(Beta_VBOX,0.01,'rlowess'); 
[e_beta_mean,e_beta_max,time_at_max,error] = errorCalc(mybeta(1:end-1),Beta_VBOX_smooth(1:end-2));
disp(' ');
fprintf('The MSE of Beta estimation is: %d \n',e_beta_mean);
fprintf('The Max error of Beta estimation is: %d \n',e_beta_max);

%-----------------
% PLOT THE RESULTS
%-----------------
if 1
    figure('Position', [100, 100, 600, 200]);
    plot(Time,Beta_VBOX,'Color','g','LineWidth',1.5,'DisplayName','True');
    hold on;
    grid on;
    plot(Time(1:end-1),mybeta,'Color','k','LineWidth',1.1,'DisplayName','UKF');
    if washout == 1
        plot(Time,beta_mod,'Color','b','LineWidth',1.5,'DisplayName','beta^{mod}');
        plot(vy_kin.time,beta_kin.Data,'Color','m','LineWidth',1.5,'DisplayName','beta^{kin}');
        plot(vy_wo.time,beta_wo.Data,'Color','r','LineWidth',1.5,'DisplayName','Washout');
    end
    xlim([0,Time(end)])
    legend('show','Location','NorthWest');
    xlabel('Time [sec]');
    ylabel('Slip [1]');
end

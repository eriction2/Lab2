%%
clear all


%change parameters to decide which case shall be simulated
%e.g. (i=2:4 will play case2,3 and 4)
for i = 2:3
%Estimation
if i == 1
Init_for_washout_filter %Circle
end
if i == 2
Init_for_washout_filter2 %Slalom
end
if i == 3
Init_for_washout_filter3 %SS
end
if i == 4
Init_for_washout_filter4  %SWD
end

%Model-based estimator
vx = vx_VBOX;
SWA = SWA_VBOX;
vy_mod = vx.*(lr*(lf+lr)*Cf*Cr-lf*Cf*mass.*vx.*vx)./(Ratio*((lf+lr)^2*Cr*Cf+mass.*vx.*vx*(lr*Cr-lf*Cf))).*SWA;
beta_mod = atan(vy_mod./vx_VBOX);
%Cr = 100000; %For the inital case
%Cf = Cr;
%vy_mod2 = vx.*(lr*(lf+lr)*Cf*Cr-lf*Cf*mass.*vx.*vx)./(Ratio*((lf+lr)^2*Cr*Cf+mass.*vx.*vx*(lr*Cr-lf*Cf))).*SWA;
%beta_mod2 = atan(vy_mod2./vx_VBOX);


%Measurment based estimator
ay_m.time = Time;
ay_m.signals.values = ay_VBOX;
yawRate_m.time = Time;
yawRate_m.signals.values = yawRate_VBOX;
vx_m.time = Time;
vx_m.signals.values = vx_VBOX;
sim measurments

%Wash-out estimator
SWA_m.time = Time;
SWA_m.signals.values = SWA;

T = 0.4;%0.4
K_yaw_diff = 0.15/10*3*5; %Set this to 0 to disable dynamic T
K_yaw_diff2 = 1*45.2489;
K_smooth = 1*15;%10 for circle
K_smooth_2 = 1*0.5*2;
K_smooth_3 = 10*1;
vy_mod_m.time = Time;
vy_mod_m.signals.values = vy_mod;
power = 8.4;
sim washout



%plot the estimator result in beta
if 1
    figure;
    plot(Time,Beta_VBOX,'Color','g','LineWidth',1.5,'DisplayName','True');
    hold on;
    grid on;
    %plot(Time,beta_mod,'Color','b','LineWidth',1.5,'DisplayName','beta^{mod} new');
    %plot(Time,beta_mod2,'Color','c','LineWidth',1.5,'DisplayName','beta^{mod} old');
    %plot(vy_kin.time,beta_kin.Data,'Color','m','LineWidth',1.5,'DisplayName','beta^{kin}');
    plot(vy_wo.time,beta_wo.Data,'Color','r','LineWidth',1.5,'DisplayName','Washout');
    xlim([0,Time(end)])
    legend('show','Location','NorthWest');
    xlabel('Time [sec]');
    ylabel('Slip [1]');
end

%plot error for the estimators
if 0
    plot(Time,abs(Beta_VBOX-beta_mod),'Color','b','LineWidth',1.5,'DisplayName','True');
    hold on;
    grid on;
    plot(Time,abs(Beta_VBOX-beta_wo.Data),'Color','r','LineWidth',1.5,'DisplayName','beta^{mod} new');
    %plot(Time,beta_mod2,'Color','c','LineWidth',1.5,'DisplayName','beta^{mod} old');
    plot(vy_kin.time,abs(Beta_VBOX-beta_kin.Data),'Color','m','LineWidth',1.5,'DisplayName','beta^{kin}');
    plot(vy_kin.time,vx./100,'Color','r','LineWidth',1.5,'DisplayName','beta^{kin}');
    xlim([16,Time(end)])
    legend('show','Location','NorthWest');
    xlabel('Time [sec]');
    ylabel('Slip [1]');
end


%MSE and max error
[e_beta_mean,e_beta_max,time_at_max,error] = errorCalc(beta_mod, Beta_VBOX);
disp(' ');
fprintf('The MSE of Beta estimation mod is: %d \n',e_beta_mean);
fprintf('The Max error of Beta estimation mod is: %d \n',e_beta_max);
[e_beta_mean,e_beta_max,time_at_max,error] = errorCalc(beta_kin.Data, Beta_VBOX);
disp(' ');
fprintf('The MSE of Beta estimation kin is: %d \n',e_beta_mean);
fprintf('The Max error of Beta estimation kin is: %d \n',e_beta_max);
[e_beta_mean,e_beta_max,time_at_max,error] = errorCalc(beta_wo.Data, Beta_VBOX);
disp(' ');
fprintf('The MSE of Beta estimation Wash-out is: %d \n',e_beta_mean);
fprintf('The Max error of Beta estimation Wash-out is: %d \n',e_beta_max);
%%

end



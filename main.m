%%
clear all
clf
close all




%Estimation
Init_for_washout_filter
vx = vx_VBOX;
SWA = SWA_VBOX;
vy_mod = vx.*(lr*(lf+lr)*Cf*Cr-lf*Cf*mass.*vx.*vx)./(Ratio*((lf+lr)^2*Cr*Cf+mass.*vx.*vx*(lr*Cr-lf*Cf))).*SWA;
beta_mod = atan(vy_mod./vx_VBOX);
Cr = 100000;
Cf = Cr;
vy_mod2 = vx.*(lr*(lf+lr)*Cf*Cr-lf*Cf*mass.*vx.*vx)./(Ratio*((lf+lr)^2*Cr*Cf+mass.*vx.*vx*(lr*Cr-lf*Cf))).*SWA;
beta_mod2 = atan(vy_mod2./vx_VBOX);


%Measurment
ay_m.time = Time;
ay_m.signals.values = ay_VBOX+rx.*yawRate_VBOX;
yawRate_m.time = Time;
yawRate_m.signals.values = SWA_VBOX;%yawRate_VBOX;
vx_m.time = Time;
vx_m.signals.values = vx_VBOX-ry*yawRate_VBOX;
sim measurments

%Wash-out
%T = abs((yawRate_VBOX)).*3;%50;%+3*abs(yawRate_VBOX);%0.4;
%T_m.time = Time;
%T_m.signals.values = T;
T = 0.4;
K_yaw_diff = 0;
K_smooth = 5;
vy_mod_m.time = Time;
vy_mod_m.signals.values = vy_mod;


sim washout




if 1
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




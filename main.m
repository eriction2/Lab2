%%
clear all
clf
close all

%Estimation
Init_for_washout_filter
vx = vx_VBOX;
SWA = SWA_VBOX;
vy_mod = vx.*(lr*(lf+lr)*Cf*Cr-lf*Cf*mass.*vx.*vx)./(Ratio*((lf+lr)^2*Cr*Cf+mass.*vx.*vx*(lr*Cr-lf*Cf))).*SWA;


%Measurment
ay_m.time = Time;
ay_m.signals.values = ay_VBOX+rx.*yawRate_VBOX;
yawRate_m.time = Time;
yawRate_m.signals.values = yawRate_VBOX;
vx_m.time = Time;
vx_m.signals.values = vx_VBOX-ry*yawRate_VBOX;
sim measurments

%Wash-out
T = 0.7;
vy_mod_m.time = Time;
vy_mod_m.signals.values = vy_mod;
sim washout

plot(Time,vy_mod,'Color','r','LineWidth',1.5);
hold on;
grid on;
plot(vy_kin.time,vy_kin.Data,'Color','b','LineWidth',1.5);
plot(vy_wo.time,vy_wo.Data,'Color','y','LineWidth',1.5);
plot(Time,vy_VBOX+rx.*yawRate_VBOX,'Color','g','LineWidth',1.5);




%%




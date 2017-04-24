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



plot(Time,vy_mod,'r');
hold on;
plot(vy_kin.time,vy_kin.Data,'b');
plot(Time,vy_VBOX+rx.*yawRate_VBOX,'g');




%%




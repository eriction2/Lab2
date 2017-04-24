%%
clear all
clf
close all
Init_for_washout_filter
vx = vx_VBOX;
SWA = SWA_VBOX;
vy_mod = vx.*(lr*(lf+lr)*Cf*Cr-lf*Cf*mass.*vx.*vx)./(Ratio*((lf+lr)^2*Cr*Cf+mass.*vx.*vx*(lr*Cr-lf*Cf))).*SWA;




plot(Time,vy_mod,'r');
hold on;
plot(Time,vy_VBOX);




%%




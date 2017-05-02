Init_for_washout_filter

angle = [];
anglemeas = [];
anglehat = [];
biashat = [];


angle_noise = 0.0021;
yawRate_noise = 0.0056;
dt = 0.01;
bias_noise = 0.03;

a = [1 -dt; 0 1];
b = [dt;0];
c = [1 0];

R = angle_noise^2;
Q = [(yawRate_noise^2)*(dt^2) 0;
        0 (bias_noise^2)];
P = Q;

xhat = [0;0];
for i = 1 : 1 : length(ay_VBOX),
    u = SAW_VBOX(i);
    y = atan((ay_VBOX(i,1))/(ax_VBOX(i,1)));%*(180/pi);
    
    xhat = a * xhat + b * u;
    
    Inn = y - c * xhat;
    
    s = c * P * c' + R;
    
    K = P * c' * inv(s);
    
    xhat = xhat + K * Inn;
    
    P = a * P * a' - a * P * c' * inv(s) * c * P * a' + Q;
    
    angle = [angle; Beta_VBOX(i)];
    anglemeas = [anglemeas; y];
    anglehat = [anglehat; xhat(1)];
    biashat = [biashat; xhat(2)];
end


if 1
    plot(Time,angle,'Color','g','LineWidth',1.5,'DisplayName','True');
    hold on;
    grid on;
    %plot(Time,beta_mod,'Color','b','LineWidth',1.5,'DisplayName','beta^{mod} new');
    %plot(Time,beta_mod2,'Color','c','LineWidth',1.5,'DisplayName','beta^{mod} old');
    %plot(vy_kin.time,beta_kin.Data,'Color','m','LineWidth',1.5,'DisplayName','beta^{kin}');
    plot(Time,anglehat,'Color','r','LineWidth',1.5,'DisplayName','Washout');
    xlim([0,Time(end)])
    legend('show','Location','NorthWest');
    xlabel('Time [sec]');
    ylabel('Slip [1]');
end

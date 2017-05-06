function x_n = Vehicle_state_eq(x,param)
% ADDME Dynamic model function
%    x = the states
%    param = parameters that you might need, such as vehicle parameters.

global lf lr mass Iz Cf Cr
a12 = atan((x(2,:)+x(3,:).*lf)./x(1,:))-param.delta;
a34 = atan((x(2,:)-x(3,:).*lr)./x(1,:));
if param.use_tyre_simple
    F12 = -Cf.*a12;
    F34 = -Cr.*a34;
else  
    f_delta12 = param.Fz*param.mu/(2*Cf*abs(tan(a12)));
    f_delta34 = param.Fz*param.mu/(2*Cr*abs(tan(a34)));
    if f_delta12 > 1
        f_delta12 = 1;
    else
        f_delta12 = f_delta12*(2-f_delta12);
    end 
    if f_delta34 > 1
        f_delta34 = 1;
    else
        f_delta34 = f_delta34*(2-f_delta34);
    end 
    F12 = -Cf.*tan(a12)*f_delta12;
    F34 = -Cr.*tan(a34)*f_delta34;
end

f_x = [(-F12.*sin(param.delta))./mass+x(2,:).*x(3,:);
    (F34+F12.*cos(param.delta))./mass+x(1,:).*x(3,:);
    (lf.*F12.*cos(param.delta)-lr.*F34)/Iz];

% Integrate using Runge Kutta (in the script folder) or simple euler forward

f = @(x)[f_x(1,:);f_x(2,:);f_x(3,:)];
x_n = rk4(f,param.dt,x(1:3,:));
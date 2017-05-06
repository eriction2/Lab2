function y_n = Vehicle_measure_eq(x,param)
% ADDME Measurement function
%    x = the states
%    param = parameters that you might need, such as vehicle parameters.

global lf lr mass Cf Cr
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
y_n = [x(1,:);
    (F34+F12.*cos(param.delta))./mass;
    x(3,:)];



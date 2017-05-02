function y_n = Vehicle_measure_eq(x,param)
% ADDME Measurement function
%    x = the states
%    param = parameters that you might need, such as vehicle parameters.

global lf lr mass Cf Cr
a12 = atan((x(2,:)+x(3,:)*lf)/x(1,:))-param.delta;
a34 = atan((x(2,:)-x(3,:)*lr)/x(1,:));
F12 = -Cf*a12;
F34 = -Cr*a34;


y_n = [x(1,:);
    (F34+F12*cos(param.delta))/mass;
    x(3,:)];



clear
clc

%%
Gs = tf(21.14,[1 0 2.114e4]);
Gz = c2d(Gs,1e-4,'tustin');
Gz_zoh = c2d(Gs,1e-4,'zoh');
pidTuner(Gz_zoh,'PID')

%%
z = tf([1 0],1,1e-4);
base_tustin = 2*(z-1)/(1e-4*(z+1));
%default
% Kp = 1.196e4;
% Ki = 7.284e5;
% Kd = 49.09;

%1
% Kp = 7574;
% Ki = 4.087e5;
% Kd = 27.42;

%2
% Kp = 3345;
% Ki = 1.793e5;
% Kd = 15.6;

%3
% Kp = 1611;
% Ki = 8.43e4;
% Kd = 7.695;

%4
Kp = 1090;
Ki = 5.2e4;
Kd = 5.712;


Tp = Kd;
Ti = Ki/base_tustin;
Td = Kd/(1.6e-3+1/base_tustin);

Cd = Tp+Ti+Td;

% TF_mf = Gz_zoh*Cd/(1+Gz_zoh*Cd);
% bode(TF_mf)

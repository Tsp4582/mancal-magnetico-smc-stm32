clear 
clc
%% Modelo
%PARAMETROS [SI]

% Rotor e mancais
Tq=0.001; % Torque
g=9.81; % acelerac¸˜ao da gravidade
dia=0.01428; % diˆametro do rotor
L=0.4; % comprimento
m=1; % massa do rotor
dm=0.001; % massa de desbalanceamento
e=[0.005 0.005 0.02]; % posic¸˜ao da massa de desbalanceamento
a=-0.315/2; b=0.315/2; % posic¸˜ao dos mancais
c=-0.300/2; d=0.300/2; % posic¸˜ao dos sensores
% Atuadores
mi0=pi*4e-7; % permeabilidade magn´etica absoluta
miR=8e3; % permeabilidade magn´etica relativa
l=0.115; % caminho do campo magn´etico
Ar=2*0.0077*0.0165*cos(pi/8); %area´de atuac¸˜ao dos im˜as
n=260; % n´umero de voltas da bobina
s0e=0.001; % folga estacion´aria
i0e=1; % corrente de base
res=1.2; % resistˆencia total da bobina
% -----------------------------------------------
% PROPRIEDADES
mT=m+dm;
CM=(dm/m)*e;
Ix = 1/12*m*(L^2 +3*(dia/2)^2);%Momento de inércia em relação ao eixo x
Iy = Ix;
Iz = m*(dia/2)^2/2;            %Momento de inércia em relação ao eixo z

Ine1=[Ix 0 0;0 Iy 0;0 0 Iz]; % Mom. de in´ercia do eixo balanceado no CG.
Ine2=dm*[e(2)^2+e(3)^2 -e(1)*e(2) -e(1)*e(3)
-e(1)*e(2) e(1)^2+e(3)^2 -e(2)*e(3)
-e(1)*e(3) -e(2)*e(3) e(1)^2+e(2)^2]; % Mom. de in´ercia do desbalanceamento no CG.
Ine3=mT*[CM(2)^2+CM(3)^2 -CM(1)*CM(2) -CM(1)*CM(3)
-CM(1)*CM(2) CM(1)^2+CM(3)^2 -CM(2)*CM(3)
-CM(1)*CM(3) -CM(2)*CM(3) CM(1)^2+CM(2)^2]; % Transferˆencia do mom. ine. para o CM.
IneS=Ine1+Ine2-Ine3; % Momento de in´ercia do rotor no centro de massa
aa=Tq/Iz; % acelerac¸˜ao angular
omega=0;
% Atuador
ks = -2.114*10^(4);       %rigidez em laço aberto
ki = 21.14;              %ganho do atuador
Ki = ki*eye(4); % Ki estimado N/A
Ks = ks*eye(4); % Ks estimado N/mm
L=2e-2*eye(4); % indutˆancia H
igrav = g*m/ki;
% -----------------------------------------------
% DINˆAMICA
% rotac¸˜ao ser´a implementada nas matrizes pelo simulink
M=[IneS(2,2) 0 0 0;
0 m 0 0;
0 0 IneS(1,1) 0;
0 0 0 m];
G=[ 0 0 IneS(3,3) 0;
0 0 0 0;
-IneS(3,3) 0 0 0;
0 0 0 0]; % Matriz G sem o Omega
C=[c 1 0 0; d 1 0 0; 0 0 c 1; 0 0 d 1];
B=[a b 0 0; 1 1 0 0; 0 0 a b; 0 0 1 1];
Kss=B*Ks*B';
AA=[zeros(4) eye(4);
-inv(M)*Kss -inv(M)*G]; % Matriz A sem o G
BB=[zeros(4); inv(M)*B*Ki];
CC=[C zeros(4)
    zeros(4) C];
U=[IneS(2,3)+b*CM(2)*mT, IneS(3,1)-b*CM(1)*mT;
-IneS(2,3)-a*CM(2)*mT, -IneS(3,1)+a*CM(1)*mT;
IneS(3,1)-b*CM(1)*mT, IneS(2,3)-b*CM(2)*mT;
-IneS(3,1)+a*mT*CM(1), a*mT*CM(2)-IneS(2,3)];
% U=[IneS(2,3)+b*e(2)*m, IneS(3,1)-b*e(1)*m;
% -IneS(2,3)+a*e(2)*m, -IneS(3,1)+a*e(1)*m;
% IneS(3,1)-b*e(1)*m, IneS(2,3)-b*e(2)*m;
% -IneS(3,1)+a*m*e(1), a*m*e(2)-IneS(2,3)]; % forca de desbalanceamento sem o Omega2
UU=omega^2/(a-b)*U;

% Discretiza sistema
Ts =1e-4; %tempo de amostragem
%posição inicial da simulação
y0=-5e-4;

%% Controlador
Type=2; %tipo 1 é PID, tipo 2 é smc, tipo 3 é smc estimator

%PID 
PID_Type=2; %tipo 1 é backward euler e tipo 2 é tustin
Kp_pid = 1.2e4;%7574; %ganho proporcional
Ki_pid = 4e4; % ganho integral valor recom = 4e4
Kd_pid = 49;%27.5; %ganho derivativo
% Kp_pid = 1800; %ganho proporcional
% Ki_pid = 300; % ganho integral valor recom = 4e4
% Kd_pid = 15;%27.5; %ganho derivativo


alpha = 0.8819; % constante de tempo do filtro


%SMC

%% carrega sinais de input
sinais_FK = load("sinais_sem_filtrokalman_ruidoso.mat");

Ax_FK = sinais_FK.data{1};
Ay_FK = sinais_FK.data{2};
Bx_FK = sinais_FK.data{4};
By_FK = sinais_FK.data{3};
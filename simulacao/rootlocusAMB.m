clc
clear
%% 
%define variavel laplace
s=tf('s');
%define planta
Gc = 21.14/(s^2-2.114*(10^4));
%plota lugar das raizes
figure;
rlocusplot(Gc);
title('Lugar das Raízes da Planta em Malha Aberta');
fontsize(20, "points");
%% 
Cc = 1.2e4 + 49*s;
%Cc = C;
%Malha aberta
MA = Cc*Gc;
%Malha fechada
MF = feedback(MA,1);
%Step
figure;
step(MF);
title('Resposta ao degrau em Malha Fechada');
fontsize(20, "points");

%Bode
figure;
margin(MA);
title('Diagrama de Bode em Malha Aberta');
fontsize(20, "points");

%root locus
figure;
rlocus(MA);
title('Lugar das Raízes em Malha Aberta');
fontsize(20, "points");

% mapa de polos e zeros
figure;
pzmap(MF);
title('Polos e Zeros do Sistema em Malha Fechada');
fontsize(20, "points");

%% discretização
Cd = c2d(Cc,1e-2,'tustin')
Gd = c2d(Gc,1e-2,'tustin')

%% 
pid(Cd)
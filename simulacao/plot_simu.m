clear
clc
%% carrega sinais de input
pid1 = load("simu_pid1_30_07.mat");%entrada degrau e PID
pid2 = load("simu_pid2_30_07.mat");%entrada degrau+ruido PID
pid3 = load("simu_pid3_30_07.mat");%entrada degrau+ruido e força externa de -10N PID

smc1 = load("simu_smc1_30_07.mat");%entrada degrau e SMC
smc2 = load("simu_smc2_30_07.mat");%entrada degrau+ruido SMC
smc3 = load("simu_smc3_30_07.mat");%entrada degrau+ruido e força externa de -10N SMC


%% 
%simulacao degrau PID
t1 = pid1.data{8}.Values.Time(:,1);
posicao1_Ay = pid1.data{8}.Values.Data(:,3);
referencia1_Ay = pid1.data{12}.Values.Data(:,3);
corrente1_Ay = pid1.data{1}.Values.Data(:,3);
%simulacao degrau+ruido PID
t2 = pid2.data{8}.Values.Time(:,1);
posicao2_Ay = pid2.data{8}.Values.Data(:,3);
referencia2_Ay = pid2.data{12}.Values.Data(:,3);
corrente2_Ay = pid2.data{1}.Values.Data(:,3);
%simulacao degrau+ruido e força externa PID
t3 = pid3.data{8}.Values.Time(:,1);
posicao3_Ay = pid3.data{8}.Values.Data(:,3);
referencia3_Ay = pid3.data{12}.Values.Data(:,3);
corrente3_Ay = pid3.data{1}.Values.Data(:,3);

%%
%simulacao degrau SMC
t4 = smc1.data{3}.Values.Time(:,1);
posicao4_Ay = smc1.data{3}.Values.Data(:,3);
referencia4_Ay = smc1.data{7}.Values.Data(:,3);
corrente4_Ay = smc1.data{1}.Values.Data(:,3);
%simulacao degrau+ruido PID
t5 = smc2.data{3}.Values.Time(:,1);
posicao5_Ay = smc2.data{3}.Values.Data(:,3);
referencia5_Ay = smc2.data{7}.Values.Data(:,3);
corrente5_Ay = smc2.data{1}.Values.Data(:,3);
%simulacao degrau+ruido e força externa PID
t6 = smc3.data{3}.Values.Time(:,1);
posicao6_Ay = smc3.data{3}.Values.Data(:,3);
referencia6_Ay = smc3.data{7}.Values.Data(:,3);
corrente6_Ay = smc3.data{1}.Values.Data(:,3);


%% 
% PID entrada degrau
% plot posição
figure
plot(t1,referencia1_Ay,t1,posicao1_Ay,'LineWidth',3);
title("Posição do Mancal A eixo Y com entrada Degrau");
xlabel("Tempo [s]");
ylabel("Posição [m]");
legend("referência","posição Ay");
fontsize(20, "points");
%ylim([-6e-4,1e-4]);

%plot corrente
figure
plot(t1,corrente1_Ay,'LineWidth',3);
title("Sinal de Corrente no Mancal A eixo Y com entrada Degrau");
xlabel("Tempo [s]");
ylabel("Corrente [A]");
ylim([-1.2,1.2]);
fontsize(20, "points");

%% 
% PID entrada degrau+ruido
% plot posição
figure
plot(t2,referencia2_Ay,t2,posicao2_Ay,'LineWidth',3);
title("Posição do Mancal A eixo Y com entrada Degrau com Ruído");
xlabel("Tempo [s]");
ylabel("Posição [m]");
legend("referência","posição Ay");
fontsize(20, "points");
%ylim([-6e-4,1e-4]);

%plot corrente
figure
plot(t2,corrente2_Ay,'LineWidth',3);
title("Sinal de Corrente no Mancal A eixo Y com entrada Degrau com Ruído");
xlabel("Tempo [s]");
ylabel("Corrente [A]");
ylim([-1.2,1.2]);
fontsize(20, "points");

%% 
% PID entrada degrau+ruido com força externa
% plot posição
figure
plot(t3,referencia3_Ay,t3,posicao3_Ay,'LineWidth',3);
title("Posição do Mancal A eixo Y com entrada Degrau com Ruído e Força Externa");
xlabel("Tempo [s]");
ylabel("Posição [m]");
legend("referência","posição Ay");
fontsize(20, "points");
%ylim([-6e-4,1e-4]);

%plot corrente
figure
plot(t3,corrente3_Ay,'LineWidth',3);
title("Sinal de Corrente no Mancal A eixo Y com entrada Degrau com Ruído e Força Externa");
xlabel("Tempo [s]");
ylabel("Corrente [A]");
ylim([-1.2,1.2]);
fontsize(20, "points");

%% Plot XY PID
% ---- orbitas com reconstrucao para altas rotacoes ----
arq = {
        "simu_smc_w500_30_07.mat",   500;
        "simu_smc_w1000_30_07.mat", 1000;
        "simu_smc_w2000_30_07.mat", 2000;
        "simu_smc_w3000_30_07.mat", 3000;
        "simu_smc_w4000_30_07.mat", 4000;
        "simu_smc_w9000_30_07.mat", 9000;
        "simu_smc_w15000_30_07.mat", 15000;
        "simu_smc_w25000_30_07.mat", 25000;             
        };
nrev  = 10;      % voltas mostradas
t_ini = 1.5;     % descarta transitorio
alvo  = 200;     % pontos por volta desejados no grafico

figure; hold on; grid on
cores = lines(size(arq,1));

for k = 1:size(arq,1)
    S  = load(arq{k,1});
    om = arq{k,2};

    t  = S.data{8}.Values.Time(:,1);
    xA = S.data{8}.Values.Data(:,1);
    yA = S.data{8}.Values.Data(:,3);

    dt  = t(2) - t(1);
    sel = t >= t_ini & t <= t_ini + nrev*2*pi/om;

    xs = xA(sel)*1e6;  xs = xs - mean(xs);
    ys = yA(sel)*1e6;  ys = ys - mean(ys);

    % pontos por volta que existem hoje
    ppv = 2*pi/(om*dt);

    if ppv < alvo
        n  = round(numel(xs) * alvo/ppv);
        xs = interpft(xs, n);      % interpolacao de Fourier
        ys = interpft(ys, n);
        m0 = round(0.02*n);        % descarta as bordas (efeito de janela)
        xs = xs(m0+1:end-m0);
        ys = ys(m0+1:end-m0);
    end

    plot(xs, ys, 'LineWidth', 2.5, 'Color', cores(k,:), ...
         'DisplayName', sprintf('\\Omega = %d rad/s', om));
end

axis equal
xlabel("Deslocamento X [\mum]");
ylabel("Deslocamento Y [\mum]");
title("Órbita do Mancal A para diferentes velocidades de rotação");
legend('Location','bestoutside');
fontsize(20,"points");

%% 
% SMC entrada degrau
% plot posição
figure
plot(t4,referencia4_Ay,t4,posicao4_Ay,'LineWidth',3);
title("Posição do Mancal A eixo Y com entrada Degrau e controle SMC");
xlabel("Tempo [s]");
ylabel("Posição [m]");
legend("referência","posição Ay");
fontsize(20, "points");
%ylim([-6e-4,1e-4]);

%plot corrente
figure
plot(t4,corrente4_Ay,'LineWidth',3);
title("Sinal de Corrente no Mancal A eixo Y com entrada Degrau e controle SMC");
xlabel("Tempo [s]");
ylabel("Corrente [A]");
ylim([-1.2,1.2]);
fontsize(20, "points");

%% 
% SMC entrada degrau+ruido
% plot posição
figure
plot(t5,referencia5_Ay,t5,posicao5_Ay,'LineWidth',3);
title("Posição do Mancal A eixo Y com entrada Degrau com Ruído e controle SMC");
xlabel("Tempo [s]");
ylabel("Posição [m]");
legend("referência","posição Ay");
fontsize(20, "points");
%ylim([-6e-4,1e-4]);

%plot corrente
figure
plot(t5,corrente5_Ay,'LineWidth',3);
title("Sinal de Corrente no Mancal A eixo Y com entrada Degrau com Ruído e controle SMC");
xlabel("Tempo [s]");
ylabel("Corrente [A]");
ylim([-1.2,1.2]);
fontsize(20, "points");

%% 
% SMC entrada degrau+ruido com força externa
% plot posição
figure
plot(t6,referencia6_Ay,t6,posicao6_Ay,'LineWidth',3);
title("Posição do Mancal A eixo Y com entrada Degrau com Ruído e Força Externa e controle SMC");
xlabel("Tempo [s]");
ylabel("Posição [m]");
legend("referência","posição Ay");
fontsize(20, "points");
%ylim([-6e-4,1e-4]);

%plot corrente
figure
plot(t6,corrente6_Ay,'LineWidth',3);
title("Sinal de Corrente no Mancal A eixo Y com entrada Degrau com Ruído e Força Externa e controle SMC");
xlabel("Tempo [s]");
ylabel("Corrente [A]");
ylim([-1.2,1.2]);
fontsize(20, "points");

%% Plot XY SMC
% ---- orbitas com reconstrucao para altas rotacoes ----
arq = {
        "simu_w500_30_07.mat",   500;
        "simu_w1000_30_07.mat", 1000;
        "simu_w2000_30_07.mat", 2000;
        "simu_w3000_30_07.mat", 3000;
        "simu_w4000_30_07.mat", 4000;
        "simu_w9000_30_07.mat", 9000;
        "simu_w15000_30_07.mat", 15000;
        "simu_w25000_30_07.mat", 25000;             
        };
nrev  = 10;      % voltas mostradas
t_ini = 1.5;     % descarta transitorio
alvo  = 200;     % pontos por volta desejados no grafico

figure; hold on; grid on
cores = lines(size(arq,1));

for k = 1:size(arq,1)
    S  = load(arq{k,1});
    om = arq{k,2};

    t  = S.data{3}.Values.Time(:,1);
    xA = S.data{3}.Values.Data(:,1);
    yA = S.data{3}.Values.Data(:,3);

    dt  = t(2) - t(1);
    sel = t >= t_ini & t <= t_ini + nrev*2*pi/om;

    xs = xA(sel)*1e6;  xs = xs - mean(xs);
    ys = yA(sel)*1e6;  ys = ys - mean(ys);

    % pontos por volta que existem hoje
    ppv = 2*pi/(om*dt);

    if ppv < alvo
        n  = round(numel(xs) * alvo/ppv);
        xs = interpft(xs, n);      % interpolacao de Fourier
        ys = interpft(ys, n);
        m0 = round(0.02*n);        % descarta as bordas (efeito de janela)
        xs = xs(m0+1:end-m0);
        ys = ys(m0+1:end-m0);
    end

    plot(xs, ys, 'LineWidth', 2.5, 'Color', cores(k,:), ...
         'DisplayName', sprintf('\\Omega = %d rad/s', om));
end

axis equal
xlabel("Deslocamento X [\mum]");
ylabel("Deslocamento Y [\mum]");
title("Órbita do Mancal A para diferentes velocidades de rotação");
legend('Location','bestoutside');
fontsize(20,"points");




% %%
% % plot força externa
% figure
% plot(t,posicao_Ay,'LineWidth',3);
% title("Posição do Mancal A eixo Y Após Força Externa");
% xlabel("Tempo [s]");
% ylabel("Posição [m]");
% %legend("referência","posição Ay");
% %ylim([-6e-4,1e-4]);
% fontsize(20, "points");
% 
% %% 
% %plot derivativo
% figure
% plot(t,derivativo_euler_sem_filt,'LineWidth',3);
% title("Sinal de Corrente do Termo Derivativo, Usando Euler, sem Filtro, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% %ylim([0,0.005]);
% 
% 
% figure
% plot(t,derivativo_euler_com_filt,'LineWidth',3);
% title("Sinal de Corrente do Termo Derivativo, Usando Euler, com Filtro, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% %ylim([0,0.005]);
% 
% figure
% plot(t,derivativo_euler_sem_filt,t,derivativo_euler_com_filt,'LineWidth',3);
% title("Sinal de Corrente do Termo Derivativo, com e sem Filtro, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% legend('sem filtro','com filtro')
% %ylim([0,0.005]);
% 
% 
% 
% figure
% plot(t,derivativo_tustin_sem_filt,'LineWidth',3);
% title("Sinal de Corrente do Termo Derivativo, Usando Tustin, sem Filtro, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% %ylim([0,0.01]);
% 
% figure
% plot(t,derivativo_tustin_com_filt,'LineWidth',3);
% title("Sinal de Corrente do Termo Derivativo, Usando Tustin, com Filtro, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% %ylim([0,0.01]);
% 
% %% 
% %plot corrente total
% figure
% plot(t,corrente_controle_euler,'LineWidth',3);
% title("Sinal de Corrente Total, Usando Euler, sem Saturação, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% %ylim([-1.2,1.2]);
% 
% figure
% plot(t,corrente_controle_sat_euler,'LineWidth',3);
% title("Sinal de Corrente Total, Usando Euler, com Saturação, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% ylim([-1.2,1.2]);
% 
% figure
% plot(t,corrente_controle_tustin,'LineWidth',3);
% title("Sinal de Corrente Total, Usando Tustin, sem Saturação, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% %ylim([-1.2,1.2]);
% 
% figure
% plot(t,corrente_controle_sat_tustin,'LineWidth',3);
% title("Sinal de Corrente Total, Usando Tustin, com Saturação, no Mancal A eixo Y");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% %ylim([-1.2,1.2]);
% 
% %%
% %atraso entre termos proporc e derivativo
% figure
% plot(t,proporcional,t,derivativo_euler_com_filt,'LineWidth',3);
% title("Atraso Comparando Correntes do Termo Proporcional e Derivativo");
% xlabel("Tempo [s]");
% ylabel("Corrente [A]");
% legend('corrente do termo proporcional','corrente do termo derivativo')
% 
% 
% 

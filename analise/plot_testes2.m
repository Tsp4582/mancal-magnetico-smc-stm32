clear
clc

% =========================================================================
%  ENSAIO teste_pid1_01_08  —  PID Kp=1600, Kd=15, Ki=300
%
%  Gera 6 figuras:
%     1) posicao  — partida (saida do repouso ate operacao em zero)
%     2) posicao  — durante a rotacao
%     3) posicao  — resposta a um impulso
%     4) corrente — partida
%     5) corrente — durante a rotacao
%     6) corrente — resposta ao impulso
%
%  OBS sobre o arquivo: ele tem log MULTITAXA. As colunas 'time',
%  'corrente_bobinas' e 'duty_cycle' sao gravadas a 42 Hz e ficam com
%  NaN na maioria das linhas. Posicao, referencia e i_controle usam
%  'time.1' (no MATLAB: time_1), a 425 Hz. Por isso usamos time_1.
% =========================================================================

%% ------------------------- carregar -------------------------------------
pid1 = readtable(fullfile("..","dados","teste_pid1_01_08.xlsx"));

t      = pid1.time_1;             % base de tempo do grupo rapido [s]
pos_Ay = pid1.posicao_1_  * 1e6;  % canal 1 = Ya  [um]
pos_Ax = pid1.posicao_2_  * 1e6;  % canal 2 = Xa  [um]
ref_Ay = pid1.ref_1_1_    * 1e6;  % referencia de Ya [um]
i_Ay   = pid1.i_controle_1_1_;    % corrente de controle Ya [A]
i_Ax   = pid1.i_controle_2_1_;    % corrente de controle Xa [A]

%% ------------------------- janelas --------------------------------------
% Eventos localizados nos dados:
%   t = 20.84 s  -> enable liga (rampa do softstart de 0.1 s)
%   t = 53.20 s  -> impulso 1 (para baixo, pico -87 um)
%   t = 56.50 s  -> impulso 2 (para baixo, pico -68 um)
%   t = 59.42 s  -> impulso 3 (para cima,  pico +56 um)
%   t = 62.69 s  -> impulso 4 (para cima,  pico +146 um)  <- o maior
%   t = 71 a 136 s -> rotacao (subida ate 80 s, regime ~1700 rpm,
%                     desaceleracao a partir de 128 s)
%   t = 200 s    -> queda / desligamento da fonte

jan_partida  = [20.5  30.0];      % figura 1 e 4
jan_rotacao  = [95.0 115.0];      % figura 2 e 5  (regime de rotacao)
t_impulso    = 62.69;             % figura 3 e 6  (trocar por 53.20, 56.50
                                  %                ou 59.42 se preferir)
jan_impulso  = t_impulso + [-0.3  0.9];

LW = 2;      % espessura das linhas
FS = 20;     % tamanho da fonte

%% =========================== FIGURA 1 ===================================
%  posicao na partida
m = t >= jan_partida(1) & t <= jan_partida(2);

figure('Name','1 - posicao partida');
plot(t(m), ref_Ay(m), '--', 'LineWidth', LW); hold on
plot(t(m), pos_Ay(m), 'LineWidth', LW); grid on
xlim(jan_partida);
title("Partida: transiente e operação em zero — Mancal A, eixo Y");
xlabel("Tempo [s]"); ylabel("Posição [\mum]");
legend("referência","posição Ay",'Location','best');
fontsize(FS,"points");

%% =========================== FIGURA 2 ===================================
%  posicao durante a rotacao
m = t >= jan_rotacao(1) & t <= jan_rotacao(2);

figure('Name','2 - posicao rotacao');
plot(t(m), pos_Ay(m), 'LineWidth', 1.2); grid on
xlim(jan_rotacao);
title("Rotação em regime (\approx1700 rpm) — Mancal A, eixo Y");
xlabel("Tempo [s]"); ylabel("Posição [\mum]");
fontsize(FS,"points");

% ---- zoom de 0.5 s, para enxergar os ciclos individuais ----
jan_zoom = [jan_rotacao(1)+5, jan_rotacao(1)+5.5];
m = t >= jan_zoom(1) & t <= jan_zoom(2);

figure('Name','2b - posicao rotacao (zoom)');
plot(t(m), pos_Ay(m), 'LineWidth', LW); grid on
xlim(jan_zoom);
title("Rotação — detalhe de 0,5 s");
xlabel("Tempo [s]"); ylabel("Posição [\mum]");
fontsize(FS,"points");

%% =========================== FIGURA 3 ===================================
%  posicao na resposta ao impulso
m = t >= jan_impulso(1) & t <= jan_impulso(2);

figure('Name','3 - posicao impulso');
plot(t(m), pos_Ay(m), 'LineWidth', LW); grid on
xlim(jan_impulso);
xline(t_impulso, ':k', 'LineWidth', 1.5, 'HandleVisibility','off');
yline(0, ':k', 'HandleVisibility','off');
title(sprintf("Resposta ao impulso (t = %.2f s) — Mancal A, eixo Y", t_impulso));
xlabel("Tempo [s]"); ylabel("Posição [\mum]");
fontsize(FS,"points");

%% =========================== FIGURA 4 ===================================
%  corrente na partida
m = t >= jan_partida(1) & t <= jan_partida(2);

figure('Name','4 - corrente partida');
plot(t(m), i_Ay(m), 'LineWidth', LW); grid on
xlim(jan_partida);
title("Partida: corrente de controle — Mancal A, eixo Y");
xlabel("Tempo [s]"); ylabel("Corrente [A]");
fontsize(FS,"points");

%% =========================== FIGURA 5 ===================================
%  corrente durante a rotacao
m = t >= jan_rotacao(1) & t <= jan_rotacao(2);

figure('Name','5 - corrente rotacao');
plot(t(m), i_Ay(m), 'LineWidth', 1.2); grid on
xlim(jan_rotacao);
title("Rotação em regime — corrente de controle, Mancal A, eixo Y");
xlabel("Tempo [s]"); ylabel("Corrente [A]");
fontsize(FS,"points");

%% =========================== FIGURA 6 ===================================
%  corrente na resposta ao impulso
m = t >= jan_impulso(1) & t <= jan_impulso(2);

figure('Name','6 - corrente impulso');
plot(t(m), i_Ay(m), 'LineWidth', LW); grid on
xlim(jan_impulso);
xline(t_impulso, ':k', 'LineWidth', 1.5, 'HandleVisibility','off');
title(sprintf("Resposta ao impulso (t = %.2f s) — corrente de controle", t_impulso));
xlabel("Tempo [s]"); ylabel("Corrente [A]");
fontsize(FS,"points");

%% =========================== FIGURA 7 ===================================
%  orbita XY do rotor durante a rotacao
%
%  Canal 1 = Ya (vertical), canal 2 = Xa (horizontal).
%  Orbita do mancal A  = Xa vs Ya
%  Orbita do mancal B  = Xb vs Yb

pos_By = pid1.posicao_3_ * 1e6;   % canal 3 = Yb
pos_Bx = pid1.posicao_4_ * 1e6;   % canal 4 = Xb

jan_orb = [100 110];              % 10 s dentro do regime de rotacao
f_rot   = 28.3;                   % rotacao medida [Hz]
filtrar = true;                   % true = passa-faixa na sincrona

m  = t >= jan_orb(1) & t <= jan_orb(2);
xA = pos_Ax(m); yA = pos_Ay(m);
xB = pos_Bx(m); yB = pos_By(m);

% centra as orbitas (compara a forma, nao a posicao media)
xA = xA - mean(xA,'omitnan');  yA = yA - mean(yA,'omitnan');
xB = xB - mean(xB,'omitnan');  yB = yB - mean(yB,'omitnan');

if filtrar
    fs = 1/mean(diff(t),'omitnan');
    d  = designfilt('bandpassiir','FilterOrder',4, ...
                    'HalfPowerFrequency1', f_rot*0.6, ...
                    'HalfPowerFrequency2', f_rot*1.4, ...
                    'SampleRate', fs);
    xA = filtfilt(d,xA);  yA = filtfilt(d,yA);
    xB = filtfilt(d,xB);  yB = filtfilt(d,yB);
end

figure('Name','7 - orbita XY');
tiledlayout(1,2,'TileSpacing','compact');

nexttile
plot(xA, yA, 'LineWidth', 1); grid on; axis equal
xlabel("X [\mum]"); ylabel("Y [\mum]");
title("Órbita — Mancal A");
fontsize(FS,"points");

nexttile
plot(xB, yB, 'LineWidth', 1, 'Color', [0.85 0.33 0.10]); grid on; axis equal
xlabel("X [\mum]"); ylabel("Y [\mum]");
title("Órbita — Mancal B");
fontsize(FS,"points");

sgtitle(sprintf("Órbita do rotor a \\approx%.0f rpm", f_rot*60), 'FontSize', FS);

%% ------------------- metricas do ensaio ---------------------------------
m   = t >= jan_impulso(1) & t <= jan_impulso(2);
tt  = t(m); pp = pos_Ay(m); ii = i_Ay(m);
[~,k] = max(abs(pp));
fprintf('\n--- resposta ao impulso em t = %.2f s ---\n', t_impulso);
fprintf('  desvio de pico      : %+.1f um\n', pp(k));
fprintf('  corrente de pico    : %.3f A\n', max(abs(ii)));

m = t >= jan_rotacao(1) & t <= jan_rotacao(2);
fprintf('\n--- rotacao em regime (%.0f a %.0f s) ---\n', jan_rotacao);
fprintf('  posicao media       : %+.1f um\n', mean(pos_Ay(m),'omitnan'));
fprintf('  desvio padrao       : %.1f um\n',  std(pos_Ay(m),'omitnan'));
fprintf('  pico a pico         : %.1f um\n',  max(pos_Ay(m))-min(pos_Ay(m)));
fprintf('  corrente: media %+.3f A, desvio %.3f A\n', ...
        mean(i_Ay(m),'omitnan'), std(i_Ay(m),'omitnan'));

m = t >= 40 & t <= 52;
fprintf('\n--- regime parado, antes dos impulsos (40 a 52 s) ---\n');
fprintf('  posicao media       : %+.1f um\n', mean(pos_Ay(m),'omitnan'));
fprintf('  desvio padrao       : %.1f um\n',  std(pos_Ay(m),'omitnan'));
fprintf('  corrente media Xa   : %+.3f A  (mede o quanto o Xa esta fora do centro)\n', ...
        mean(i_Ax(m),'omitnan'));
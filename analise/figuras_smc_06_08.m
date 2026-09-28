clear
clc

% =========================================================================
%  FIGURAS DO ENSAIO teste_smc1_06_08  —  controlador SMC
%
%  Parametros do ensaio:
%     C=97.7  C_I=36.3  G_TOT=111.5  EPS=2  PHI=0.01
%     B=13.5  RAZAO=790  I_MAX=2.0  EI_MAX=0.01
%
%  Gera e SALVA os 9 arquivos com os nomes exatos usados no cap6:
%     1 - posicao partida SMC.png
%     2 - posicao rotacao SMC.png
%     2b - posicao rotacao (zoom) SMC.png
%     3 - posicao impulso SMC.png
%     4 - corrente SMC.png
%     5 - corrente SMC.png            (rotacao)
%     6 - corrente SMC.png            (impulso)
%     7 - orbita XY SMC.png
%     8 - superficie de deslizamento SMC.png
%
%  ATENCAO: no cap6 as figuras 4, 5 e 6 tem o MESMO nome de arquivo
%  ("4 - corrente SMC", "5 - corrente SMC", "6 - corrente SMC"), o que
%  esta certo porque o numero as distingue. Confira ao subir no Overleaf.
% =========================================================================

PHI      = 0.01;                  % camada limite do ensaio
SALVAR   = true;                  % true = grava os PNG
PASTA    = "figs_smc";            % pasta de saida
if SALVAR && ~isfolder(PASTA), mkdir(PASTA); end

%% ------------------------- carregar -------------------------------------
S = load(fullfile("..","dados","teste_smc1_06_08.mat"));
d = S.data;

POS = mat2d(d.getElement('posicao').Values);
IC  = mat2d(d.getElement('i_controle').Values);
SUP = mat2d(d.getElement('superficie').Values);
REF = mat2d(d.getElement('ref').Values);

t      = d.getElement('posicao').Values.Time(:,1);
pos_Ay = POS(:,1) * 1e6;    % canal 1 = Ya [um]
pos_Ax = POS(:,2) * 1e6;    % canal 2 = Xa
pos_By = POS(:,3) * 1e6;    % canal 3 = Yb
pos_Bx = POS(:,4) * 1e6;    % canal 4 = Xb
ref_Ay = REF(:,1) * 1e6;
i_Ay   = IC(:,1);
s_Ay   = SUP(:,1);

%% ------------------------- janelas do ensaio ----------------------------
%  enable liga em t = 11.67 s (rampa do softstart de 0.1 s)
%  impulsos: t = 41.364 (-121 um) | 43.566 (-118 um)
%            t = 46.411 (+101 um) | 48.335 (+149 um)
%  rotacao : 55 a 86 s, regime de 60 a 84 s, 18.85 Hz = 1131 rpm
%  queda   : 106 s

jan_partida = [11.4  21.0];
jan_rotacao = [60.0  80.0];
jan_zoom    = [65.0  65.5];
t_impulso   = 48.335;          % trocar por 41.364, 43.566 ou 46.411
jan_impulso = t_impulso + [-0.3 0.9];
jan_orbita  = [65.0  75.0];
f_rot       = 18.85;           % [Hz]

LW = 2; FS = 20;

%% =========================== 1 — posicao partida ========================
m = t >= jan_partida(1) & t <= jan_partida(2);
f1 = figure('Name','1 - posicao partida SMC');
plot(t(m), ref_Ay(m), '--', 'LineWidth', LW); hold on
plot(t(m), pos_Ay(m), 'LineWidth', LW); grid on; xlim(jan_partida)
title("SMC — partida: transiente e operação em zero");
xlabel("Tempo [s]"); ylabel("Posição [\mum]");
legend("referência","posição Ay",'Location','best'); fontsize(FS,"points");
grava(f1, SALVAR, PASTA, "1 - posicao partida SMC.png");

%% =========================== 2 — posicao rotacao ========================
m = t >= jan_rotacao(1) & t <= jan_rotacao(2);
f2 = figure('Name','2 - posicao rotacao SMC');
plot(t(m), pos_Ay(m), 'LineWidth', 1.2); grid on; xlim(jan_rotacao)
title(sprintf("SMC — rotação de regime (\\approx%.0f rpm)", f_rot*60));
xlabel("Tempo [s]"); ylabel("Posição [\mum]"); fontsize(FS,"points");
grava(f2, SALVAR, PASTA, "2 - posicao rotacao SMC.png");

%% =========================== 2b — zoom da rotacao =======================
m = t >= jan_zoom(1) & t <= jan_zoom(2);
f2b = figure('Name','2b - posicao rotacao (zoom) SMC');
plot(t(m), pos_Ay(m), 'LineWidth', LW); grid on; xlim(jan_zoom)
title("SMC — rotação, detalhe de 0,5 s");
xlabel("Tempo [s]"); ylabel("Posição [\mum]"); fontsize(FS,"points");
grava(f2b, SALVAR, PASTA, "2b - posicao rotacao (zoom) SMC.png");

%% =========================== 3 — posicao impulso ========================
m = t >= jan_impulso(1) & t <= jan_impulso(2);
f3 = figure('Name','3 - posicao impulso SMC');
plot(t(m), pos_Ay(m), 'LineWidth', LW); grid on; xlim(jan_impulso)
xline(t_impulso, ':k', 'LineWidth', 1.5); yline(0, ':k');
title(sprintf("SMC — resposta ao impulso (t = %.2f s)", t_impulso));
xlabel("Tempo [s]"); ylabel("Posição [\mum]"); fontsize(FS,"points");
grava(f3, SALVAR, PASTA, "3 - posicao impulso SMC.png");

%% =========================== 4, 5, 6 — correntes ========================
janelas = {jan_partida, jan_rotacao, jan_impulso};
titulos = {"SMC — partida: corrente de controle", ...
           sprintf("SMC — rotação de regime (\\approx%.0f rpm): corrente de controle", f_rot*60), ...
           sprintf("SMC — impulso (t = %.2f s): corrente de controle", t_impulso)};
arqs    = ["4 - corrente SMC.png", "5 - corrente SMC.png", "6 - corrente SMC.png"];
larg    = [LW, 1.2, LW];

for k = 1:3
    m = t >= janelas{k}(1) & t <= janelas{k}(2);
    fk = figure('Name', char(arqs(k)));
    plot(t(m), i_Ay(m), 'LineWidth', larg(k)); grid on; xlim(janelas{k})
    title(titulos{k});
    xlabel("Tempo [s]"); ylabel("Corrente [A]"); fontsize(FS,"points");
    grava(fk, SALVAR, PASTA, arqs(k));
end

%% =========================== 7 — orbita XY ==============================
fs = 1/median(diff(t));
tu = (t(1):1/fs:t(end))';
xA = interp1(t, pos_Ax, tu); yA = interp1(t, pos_Ay, tu);
xB = interp1(t, pos_Bx, tu); yB = interp1(t, pos_By, tu);

try
    dfi = designfilt('bandpassiir','FilterOrder',4, ...
                     'HalfPowerFrequency1', f_rot*0.6, ...
                     'HalfPowerFrequency2', f_rot*1.4, 'SampleRate', fs);
    xA = filtfilt(dfi,xA); yA = filtfilt(dfi,yA);
    xB = filtfilt(dfi,xB); yB = filtfilt(dfi,yB);
catch
    warning("designfilt indisponivel: orbita sem filtro (mais irregular).");
    xA = xA - mean(xA,'omitnan'); yA = yA - mean(yA,'omitnan');
    xB = xB - mean(xB,'omitnan'); yB = yB - mean(yB,'omitnan');
end
mu = tu >= jan_orbita(1) & tu <= jan_orbita(2);

f7 = figure('Name','7 - orbita XY SMC');
tiledlayout(1,2,'TileSpacing','compact');
nexttile
plot(xA(mu), yA(mu), 'LineWidth', 1); grid on; axis equal
xlabel("X [\mum]"); ylabel("Y [\mum]"); title("Mancal A"); fontsize(FS,"points");
nexttile
plot(xB(mu), yB(mu), 'LineWidth', 1, 'Color', [0.85 0.33 0.10]); grid on; axis equal
xlabel("X [\mum]"); ylabel("Y [\mum]"); title("Mancal B"); fontsize(FS,"points");
sgtitle(sprintf("SMC — órbita a \\approx%.0f rpm", f_rot*60), 'FontSize', FS);
grava(f7, SALVAR, PASTA, "7 - orbita XY SMC.png");

%% =========================== 8 — superficie =============================
f8 = figure('Name','8 - superficie de deslizamento SMC');
plot(t, s_Ay, 'LineWidth', 1); hold on; grid on
yline( PHI, '--r', 'LineWidth', 2);
yline(-PHI, '--r', 'LineWidth', 2, 'HandleVisibility','off');
ylim([-0.06 0.06]);
title("SMC — superfície de deslizamento e camada limite");
xlabel("Tempo [s]"); ylabel("s  [m/s]");
legend("s(t)","\pm\Phi",'Location','best'); fontsize(FS,"points");
grava(f8, SALVAR, PASTA, "8 - superficie de deslizamento SMC.png");

%% ------------------- numeros para o texto do capitulo -------------------
fprintf('\n===== NUMEROS DO ENSAIO SMC 06/08 =====\n');

m = t >= 15 & t <= 38;
fprintf('\nRegime parado (15 a 38 s):\n');
fprintf('  posicao Ya : media %+.1f um, desvio %.1f um, pico a pico %.1f um\n', ...
        mean(pos_Ay(m),'omitnan'), std(pos_Ay(m),'omitnan'), range(pos_Ay(m)));
fprintf('  corrente Ya: media %+.3f A, desvio %.3f A\n', ...
        mean(i_Ay(m),'omitnan'), std(i_Ay(m),'omitnan'));

m = t >= jan_rotacao(1) & t <= jan_rotacao(2);
fprintf('\nRotacao de regime (%.0f a %.0f s, %.0f rpm):\n', jan_rotacao, f_rot*60);
fprintf('  posicao Ya : media %+.1f um, desvio %.1f um, pico a pico %.1f um\n', ...
        mean(pos_Ay(m),'omitnan'), std(pos_Ay(m),'omitnan'), range(pos_Ay(m)));
fprintf('  corrente Ya: media %+.3f A, desvio %.3f A\n', ...
        mean(i_Ay(m),'omitnan'), std(i_Ay(m),'omitnan'));

fprintf('\nImpulsos:\n');
base = mean(pos_Ay(t>=15 & t<=38),'omitnan');
for tc = [41.364 43.566 46.411 48.335]
    m  = t >= tc-0.3 & t <= tc+0.9;
    tt = t(m); pp = pos_Ay(m) - base; ii = i_Ay(m);
    [~,k] = max(abs(pp));
    aft = tt > tt(k);
    idx = find(abs(pp(aft)) < 15, 1);
    if isempty(idx), rec = NaN; else, rec = (tt(find(aft,1)+idx-1) - tt(k))*1000; end
    fprintf('  t=%7.3f s: pico %+7.1f um, recuperacao %5.0f ms, corrente pico %.3f A\n', ...
            tc, pp(k), rec, max(abs(ii)));
end

fprintf('\nChaveamento (|s| acima de Phi = %.3f):\n', PHI);
for cond = ["parado" "impulsos" "rotacao"]
    switch cond
        case "parado",   m = t>=15 & t<=38;
        case "impulsos", m = t>=40 & t<=50;
        case "rotacao",  m = t>=jan_rotacao(1) & t<=jan_rotacao(2);
    end
    fprintf('  %-9s: |s| mediana %.4f, maximo %.4f, tempo acima de Phi %.1f %%\n', ...
            cond, median(abs(s_Ay(m))), max(abs(s_Ay(m))), 100*mean(abs(s_Ay(m))>PHI));
end

%% ------------------------- funcoes auxiliares ---------------------------
function M = mat2d(ts)
% Normaliza o Data para [nAmostras x nCanais], seja qual for o layout.
%   dimensao [n]    -> Data ja vem N x n
%   dimensao [n 1]  -> Data vem n x 1 x N (3-D)
D = double(ts.Data);
if ndims(D) == 3
    D = permute(D, [3 1 2]);
end
M = reshape(D, size(D,1), []);
end

function grava(fig, salvar, pasta, nome)
if ~salvar, return; end
caminho = fullfile(pasta, nome);
try
    exportgraphics(fig, caminho, 'Resolution', 200);
catch
    saveas(fig, caminho);
end
fprintf('  gravado: %s\n', caminho);
end

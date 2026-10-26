clear
clc

% =========================================================================
%  ENSAIO teste_smc1_06_08 — corrente de controle registrada x corrente
%  prevista pela parcela linear da lei de controle (Mancal A, eixo Y)
%
%  Dentro da camada limite, a lei de controle de smc_mancal.m e linear:
%     u = (kappa_ef*s + C*vf + C_I*e)/B + RAZAO*e
%  Como s = vf + C*e + C_I*ei, substituindo vf = s - C*e - C_I*ei:
%     u = (kappa_ef + C)/B*s + (RAZAO + (C_I - C^2)/B)*e - C*C_I/B*ei
%  O termo em ei varia lentamente e e tratado como constante no trecho,
%  estimado pela media do residuo. Os demais termos usam apenas sinais
%  registrados no mesmo instante (posicao, referencia e s).
%
%  Executar a partir da pasta analise/.
% =========================================================================

SALVAR = true;
PASTA  = "figs_smc";
ARQ    = "9 - comparacao corrente lei linear SMC.png";
if SALVAR && ~isfolder(PASTA), mkdir(PASTA); end

% parametros do controlador (Tabela de parametros do ensaio)
C = 97.7; C_I = 36.3; KAPPA_EF = 111.5; B = 13.5; RAZAO = 790;

% trecho de 0,3 s em rotacao de regime
JANELA = [65.0 65.3];

%% ------------------------- carregar -------------------------------------
S = load(fullfile("..","dados","teste_smc1_06_08.mat"));
d = S.data;
t   = d.getElement('posicao').Values.Time(:,1);
POS = mat2d(d.getElement('posicao').Values);
IC  = mat2d(d.getElement('i_controle').Values);
SUP = mat2d(d.getElement('superficie').Values);
REF = mat2d(d.getElement('ref').Values);

ch = 1;                                  % canal 1 = Ya
e = REF(:,ch) - POS(:,ch);  s = SUP(:,ch);  i = IC(:,ch);

%% ------------------------- previsao pela lei linear ---------------------
m  = t >= JANELA(1) & t <= JANELA(2);
ul = (KAPPA_EF + C)/B*s(m) + (RAZAO + (C_I - C^2)/B)*e(m);
c0 = mean(i(m) - ul);                    % termo -C*C_I*ei/B (lento)
ul = ul + c0;
rms_err = sqrt(mean((i(m) - ul).^2));
fprintf('Trecho %.2f-%.2f s: %d amostras, %d cruzamentos de zero de s\n', ...
        JANELA, nnz(m), sum(abs(diff(sign(s(m)))) > 0));
fprintf('Erro RMS entre corrente registrada e prevista: %.2f mA\n', 1e3*rms_err);

%% ------------------------- figura ---------------------------------------
LW = 2; FS = 20;
tt = t(m) - t(find(m,1));
f9 = figure('Name', ARQ, 'Position', [100 100 1100 750]);
tiledlayout(2,1,'TileSpacing','compact');

nexttile
plot(tt, i(m), 'k.-', 'LineWidth', LW, 'MarkerSize', 12); hold on
plot(tt, ul, '--', 'Color', [0 0.45 0.74], 'LineWidth', LW);
grid on; ylabel("Corrente [A]");
title("SMC — corrente de controle em rotação");
legend("registrada", "prevista (lei linear, \kappa_{ef} = 111,5 s^{-1})", 'Location','northoutside', 'Orientation','horizontal');

nexttile
plot(tt, s(m), 'LineWidth', LW); hold on; yline(0, ':k', 'LineWidth', 1);
grid on; xlabel("Tempo [s]"); ylabel("s  [m/s]");
title("Função de deslizamento");
fontsize(f9, FS, "points");
grava(f9, SALVAR, PASTA, ARQ);

%% ------------------------- funcoes auxiliares ---------------------------
function M = mat2d(ts)
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

clear
clc

% =========================================================================
%  METRICAS DA TABELA DE COMPARACAO PID x SMC (Mancal A)
%
%  Ensaios: teste_pid1_01_08 (PID) e teste_smc1_06_08 (SMC).
%  - partida: tempo da habilitacao ate |Ya| < 50 um, permanecendo assim por 1 s
%  - regime sem rotacao: trecho entre (habilitacao + 5 s) e o inicio da
%    rotacao, excluindo 0,5 s antes e 2 s depois de cada perturbacao
%    (desvios de Ya maiores que 50 um)
%  - rotacao de regime: janelas de 2 s com frequencia dominante a +-3% da
%    mediana; amplitudes pico a pico entre os percentis 1 e 99
%
%  Executar a partir da pasta analise/.
% =========================================================================

E = struct();
S = load(fullfile("..","dados","teste_smc1_06_08.mat")); d = S.data;
E(1).nome = "PID";
P = readtable(fullfile("..","dados","teste_pid1_01_08.xlsx"));
ok = ~isnan(P.time_1);
E(1).t   = P.time_1(ok);
E(1).pos = [P.posicao_1_(ok) P.posicao_2_(ok) P.posicao_3_(ok) P.posicao_4_(ok)]*1e6;
E(1).i   = [P.i_controle_1_1_(ok) P.i_controle_2_1_(ok)];
E(1).ten = 20.84;                          % habilitacao (softstart)
E(2).nome = "SMC";
E(2).t   = d.getElement('posicao').Values.Time(:,1);
E(2).pos = mat2d(d.getElement('posicao').Values)*1e6;
E(2).i   = mat2d(d.getElement('i_controle').Values);
en       = mat2d(d.getElement('enable').Values);
E(2).ten = E(2).t(find(en > 0.5, 1));

for k = 1:2
    t = E(k).t; pos = E(k).pos; ic = E(k).i; ten = E(k).ten;

    % --- rotacao: componente dominante em janelas de 2 s
    dt = 0.002; tu = (t(1):dt:t(end))';
    yu = interp1(t, pos(:,1), tu);
    w = round(2/dt); nw = floor(numel(tu)/w);
    fr = zeros(nw,1); am = fr; tc = fr;
    for j = 1:nw
        seg = yu((j-1)*w+1:j*w); seg = seg - mean(seg,'omitnan'); seg(isnan(seg)) = 0;
        Y = abs(fft(seg)); f = (0:w-1)'/(w*dt); sel = f > 5 & f < 60;
        [pk,ix] = max(Y.*sel); fr(j) = f(ix); am(j) = 2*pk/w; tc(j) = tu(round((j-0.5)*w));
    end
    rot  = am > 15;
    frot = median(fr(rot));
    reg  = rot & abs(fr - frot) < 0.03*frot;
    trot = [min(tc(reg)) max(tc(reg))];

    % --- regime sem rotacao, sem perturbacoes
    mP = t > ten + 5 & t < min(tc(rot)) - 3;
    yP = pos(mP,1); tp = t(mP); dev = abs(yP - median(yP));
    picos = []; ult = -inf;
    for j = find(dev > 50)'
        if tp(j) - ult > 1, picos(end+1) = tp(j); ult = tp(j); end %#ok<AGROW>
    end
    calmo = mP;
    for p = picos, calmo = calmo & ~(t > p - 0.5 & t < p + 2); end

    % --- partida
    mS = t > ten & t < ten + 20; ts = t(mS); ys = pos(mS,1);
    dentro = abs(ys) < 50; tpart = NaN;
    for j = 1:numel(ts)
        if dentro(j) && all(dentro(ts >= ts(j) & ts <= ts(j) + 1)), tpart = ts(j) - ten; break; end
    end

    amp = @(v) prctile(v,99) - prctile(v,1);
    m = t >= trot(1) & t <= trot(2);
    fprintf('\n===== %s =====\n', E(k).nome);
    fprintf('Posicao inicial Ya (rotor apoiado): %.0f um\n', median(pos(t < ten - 0.2 & t > ten - 2, 1)));
    fprintf('Tempo de partida ate |Ya| < 50 um: %.1f s\n', tpart);
    fprintf('Pico de corrente na partida: %.2f A\n', max(abs(ic(mS,1))));
    fprintf('Sem rotacao: desvio padrao Ya %.1f um, Xa %.1f um\n', std(pos(calmo,1)), std(pos(calmo,2)));
    fprintf('Sem rotacao: corrente media Ya %.2f A, Xa %.2f A\n', mean(ic(calmo,1)), mean(ic(calmo,2)));
    fprintf('Rotacao de regime: %.1f Hz (%.0f rpm)\n', frot, 60*frot);
    fprintf('Em rotacao: Ya %.0f um pp, Xa %.0f um pp, corrente Ya %.2f A pp\n', ...
            amp(pos(m,1)), amp(pos(m,2)), amp(ic(m,1)));
end

function M = mat2d(ts)
D = double(ts.Data);
if ndims(D) == 3
    D = permute(D, [3 1 2]);
end
M = reshape(D, size(D,1), []);
end

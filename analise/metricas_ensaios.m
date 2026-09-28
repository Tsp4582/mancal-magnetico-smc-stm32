% Metricas dos ensaios de bancada
% (partida, regime, rotacao, orbitas, impulsos e funcao de deslizamento).
% Executar a partir da pasta analise/.
%% ---------- PID ----------
P = readtable(fullfile("..","dados","teste_pid1_01_08.xlsx"));
t = P.time_1; ok = ~isnan(t);
t = t(ok);
pos = [P.posicao_1_(ok) P.posicao_2_(ok) P.posicao_3_(ok) P.posicao_4_(ok)]*1e6; % Ya Xa Yb Xb
ic  = [P.i_controle_1_1_(ok) P.i_controle_2_1_(ok)];
R.pid = relat('PID', t, pos, ic, 20.84, [30 50], [95 115], 28.3, [53.20 56.50 59.42 62.69]);
%% ---------- SMC ----------
S = load(fullfile("..","dados","teste_smc1_06_08.mat")); d = S.data;
POS = m2(d.getElement('posicao').Values)*1e6; IC = m2(d.getElement('i_controle').Values);
t2  = d.getElement('posicao').Values.Time(:,1);
SUP = m2(d.getElement('superficie').Values); ts = d.getElement('superficie').Values.Time(:,1);
R.smc = relat('SMC', t2, POS, IC(:,1:2), 11.67, [20 40], [60 80], 18.84, [41.364 43.566 46.411 48.335]);
% SMC: s e sat com PHI = 0.01
PHI = 0.01; s = SUP(:,1);
for w = {[13 40],[40 50],[60 84],[88 106]}
  m = ts>=w{1}(1) & ts<=w{1}(2); sk = s(m);
  fprintf('SMC s em [%g %g]: med|s|=%.4f  %%|s|>PHI=%.1f  %%s>0=%.1f  cruzamentos/s=%.1f  max|s|=%.3f\n', w{1}, ...
     median(abs(sk)), 100*mean(abs(sk)>PHI), 100*mean(sk>0), sum(abs(diff(sign(sk)))>0)/diff(w{1}), max(abs(sk)));
end

function r = relat(nome, t, pos, ic, t_en, jan_reg, jan_rot, frot, timp)
fprintf('\n===== %s =====\n', nome);
fs = 1/median(diff(t)); fprintf('fs ~ %.0f Hz\n', fs);
% partida
m = t>=t_en-0.5 & t<=t_en+10;
tt = t(m); y = pos(m,1); i1 = ic(m,1);
fprintf('pos Ya antes do enable: %.0f um\n', median(pos(t>=t_en-2 & t<t_en,1)));
dentro = abs(y) <= 25;
k = find(tt>t_en & ~dentro, 1, 'last');
if isempty(k), ta = NaN; else, ta = tt(min(k+1,end)) - t_en; end
fprintf('partida: tempo ate ficar em +-25um: %.3f s; overshoot/pico apos enable: max %.0f min %.0f um\n', ta, max(y(tt>t_en)), min(y(tt>t_en)));
fprintf('partida: pico corrente Ya %.3f A (min %.3f)\n', max(i1(tt>t_en)), min(i1(tt>t_en)));
% regime sem rotacao
m = t>=jan_reg(1) & t<=jan_reg(2);
fprintf('regime [%g %g]: Ya media %.1f um, desvio padrao %.1f um, pp %.0f um | Xa media %.1f dp %.1f\n', jan_reg, mean(pos(m,1)), std(pos(m,1)), range(pos(m,1)), mean(pos(m,2)), std(pos(m,2)));
fprintf('regime: i Ya media %.3f A, dp %.3f A | i Xa media %.3f\n', mean(ic(m,1)), std(ic(m,1)), mean(ic(m,2)));
% rotacao
m = t>=jan_rot(1) & t<=jan_rot(2);
fprintf('rotacao [%g %g]: Ya media %.1f, pp %.0f um (p1-p99 %.0f) | i Ya media %.3f A, pp %.3f (p1-p99 %.3f) A\n', jan_rot, ...
   mean(pos(m,1)), range(pos(m,1)), prctile(pos(m,1),99)-prctile(pos(m,1),1), mean(ic(m,1)), range(ic(m,1)), prctile(ic(m,1),99)-prctile(ic(m,1),1));
% frequencia dominante
tu = (t(find(m,1)):1/fs:t(find(m,1,'last')))'; yu = interp1(t(m), pos(m,1)-mean(pos(m,1)), tu);
Y = abs(fft(yu)); f = (0:numel(Y)-1)'/(numel(Y)/fs); sel = f>3 & f<fs/2;
[~,ix] = max(Y.*sel); fprintf('rotacao: freq dominante Ya %.2f Hz (%.0f rpm)\n', f(ix), 60*f(ix));
% orbitas filtradas na sincrona
bp = designfilt('bandpassiir','FilterOrder',4,'HalfPowerFrequency1',frot*0.6,'HalfPowerFrequency2',frot*1.4,'SampleRate',fs);
Q = zeros(numel(tu),4);
for c = 1:4, Q(:,c) = filtfilt(bp, interp1(t(m), pos(m,c)-mean(pos(m,c)), tu)); end
amp = @(v) prctile(v,99)-prctile(v,1);
fprintf('orbita sincrona pp (um): Ya %.0f Xa %.0f | Yb %.0f Xb %.0f\n', amp(Q(:,1)), amp(Q(:,2)), amp(Q(:,3)), amp(Q(:,4)));
cY = corrcoef(Q(:,1),Q(:,3)); cX = corrcoef(Q(:,2),Q(:,4));
fprintf('correlacao A-B: Y %.2f  X %.2f (+1 em fase, -1 oposicao)\n', cY(1,2), cX(1,2));
% forma da orbita A e B: razao eixos (PCA)
for b = [1 3]
  M = Q(:,[b+1 b]); [~,Sg] = eig(cov(M)); ev = sort(diag(Sg));
  [V,~] = eig(cov(M)); [~,imx] = max(diag(Sg)); ang = atan2d(V(2,imx),V(1,imx));
  fprintf('  mancal %s: razao eixo menor/maior %.2f, inclinacao eixo maior %.0f graus\n', char('A'+(b==3)), sqrt(ev(1)/ev(2)), ang);
end
% impulsos
for ti = timp
  m = t>=ti-0.3 & t<=ti+1.5; tt = t(m); y = pos(m,1); i1 = ic(m,1);
  base = median(pos(t>=ti-1 & t<ti-0.1,1));
  [~,ip] = max(abs(y-base)); pk = y(ip)-base;
  k = find(abs(y-base) > 25, 1, 'last'); trec = tt(k) - tt(ip);
  fprintf('impulso %.2f: pico %.0f um, retorno a +-25um em %.3f s apos pico, corrente pico %.2f/%.2f A\n', ti, pk, trec, max(i1), min(i1));
end
r = [];
end
function M = m2(ts)
D = double(ts.Data); if ndims(D)==3, D = permute(D,[3 1 2]); end
M = reshape(D, size(D,1), []);
end

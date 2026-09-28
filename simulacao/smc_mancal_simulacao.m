function [i_ctrl, s_out] = smc_mancal_simulacao(pos, ref, enable)
%#codegen
% -----------------------------------------------------------------
% Controle por Modos Deslizantes (SMC) para o mancal magnetico ativo
%
% ENTRADAS
%   pos    : 4x1 [Ya; Xa; Yb; Xb] em METROS
%   ref    : 4x1 referencia, mesma ordem e unidade
%   enable : 0 desliga e zera os estados, 1 controla
%
% SAIDAS
%   i_ctrl : 4x1 corrente de controle comandada [A]
%   s_out  : 4x1 superficie de deslizamento
% -----------------------------------------------------------------

% ===================== PARAMETROS =====================
    Ts     = single(1e-4);      % periodo de amostragem         [s]

    % --- superficie de deslizamento
    C      = single(300);       % inclinacao da superficie      [1/s]
    C_I    = single(5000);      % termo integral da superficie  [1/s^2]

    % --- lei de controle
    K      = single(400);       % ganho de aproximacao          [1/s]
    EPS    = single(25);        % ganho do termo descontinuo    [m/s^2]
    PHI    = single(0.1);       % camada limite                 [m/s]

    % --- modelo da planta
    B      = single(21.14);     % ki/m                          [N/(A*kg)]
    RAZAO  = single(1000);      % |ks|/ki do feedforward        [A/m]

    % --- limites
    I_MAX  = single(1.0);       % saturacao da corrente         [A]
    EI_MAX = single(0.01);      % limite do integrador          [m*s]

    % --- derivada filtrada em 200 Hz (Tustin), nao alterar
    BV     = single(1182.35);
    AV     = single(0.88177);
% ======================================================

persistent ep vf ei
if isempty(ep)
    ep = single(zeros(4,1));   % erro no passo anterior
    vf = single(zeros(4,1));   % velocidade do erro, filtrada
    ei = single(zeros(4,1));   % integral do erro
end

i_ctrl = single(zeros(4,1));
s_out  = single(zeros(4,1));

% ---- desabilitado: zera os estados e a saida
if enable < 0.5
    for j = 1:4
        ep(j) = single(ref(j)) - single(pos(j));
        vf(j) = single(0);
        ei(j) = single(0);
    end
    return;
end

% ---- um eixo de cada vez
for j = 1:4

    e = single(ref(j)) - single(pos(j));

    % 1) velocidade do erro (derivada filtrada em 200 Hz)
    vf(j) = AV*vf(j) + BV*(e - ep(j));
    ep(j) = e;

    % 2) integral do erro, com limite
    ei_try = ei(j) + Ts*e;
    if ei_try >  EI_MAX
        ei_try =  EI_MAX;
    end
    if ei_try < -EI_MAX
        ei_try = -EI_MAX;
    end

    % 3) superficie de deslizamento
    s = vf(j) + C*e + C_I*ei_try;

    % 4) termo descontinuo suavizado: sat(s/PHI) no lugar de sign(s)
    r = s/PHI;
    if r >  1
        r =  single(1);
    end
    if r < -1
        r = -single(1);
    end

    % 5) lei de controle
    u = (K*s + C*vf(j) + C_I*e + EPS*r)/B + RAZAO*e;

    % 6) saturacao com anti-windup por integracao condicional
    if u > I_MAX
        u = I_MAX;
    elseif u < -I_MAX
        u = -I_MAX;
    else
        ei(j) = ei_try;
    end

    i_ctrl(j) = u;
    s_out(j)  = s;
end
end

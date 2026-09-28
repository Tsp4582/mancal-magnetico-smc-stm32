function [i_ctrl, s_out] = smc_mancal(pos, ref, enable)
%#codegen
% -----------------------------------------------------------------
% Controle por Modos Deslizantes (SMC) para o mancal magnetico ativo
%
% Equivale a um PID com Kp=1600, Kd=15.5, Ki=300 quando EPS = 0.
% Subir o EPS acrescenta o chaveamento SEM alterar esses ganhos.
%
% ENTRADAS
%   pos    : 4x1 [Ya; Xa; Yb; Xb] em METROS
%   ref    : 4x1 referencia, mesma ordem e unidade
%            ATENCAO: Xa = +220e-6 e Xb = +45e-6, nao zero
%   enable : 0 desliga e zera os estados, 1 controla
%
% SAIDAS
%   i_ctrl : 4x1 corrente de controle comandada [A]
%   s_out  : 4x1 superficie de deslizamento     -> LOGAR SEMPRE
% -----------------------------------------------------------------

% ===================== PARAMETROS =====================
    Ts     = single(1e-4);      % periodo de amostragem [s]

    % --- superficie de deslizamento
    C      = single(97.7);      % inclinacao da superficie      [1/s]
    C_I    = single(36.3);      % termo integral da superficie  [1/s^2]

    % --- lei de controle
    G_TOT  = single(111.5);     % ganho total de aproximacao (K + EPS/PHI)
    EPS    = single(2.0);       % ganho do termo descontinuo    [m/s^2]
                                % COMECAR EM 0. Depois 0.4 e 0.8
    PHI    = single(0.01);       % camada limite                 [m/s]


    % --- modelo da planta (medido na bancada)
    B      = single(13.5);      % ki/m                          [N/(A*kg)]
    RAZAO  = single(790);       % |ks|/ki MEDIDO                [A/m]

    % --- limites
    I_MAX  = single(2.0);       % saturacao da corrente         [A]
    EI_MAX = single(0.01);    % limite do integrador          [m*s]


    % --- derivada filtrada em 200 Hz, nao alterar
    BV     = single(1182.35);
    AV     = single(0.88177);
% ======================================================

% O K se ajusta sozinho: subir EPS nao muda o ganho linear
    K = G_TOT - EPS/PHI;
    if K < 0
        K = single(0);
    end

persistent ep vf ei
if isempty(ep)
    ep = single(zeros(4,1));
    vf = single(zeros(4,1));
    ei = single(zeros(4,1));
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

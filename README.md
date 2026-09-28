# Implementação Embarcada de Controle por Modos Deslizantes em Mancal Magnético Ativo com Microcontrolador STM32

Material complementar do Projeto de Graduação em Engenharia de Controle e Automação (Escola Politécnica, UFRJ, 2026).

- **Autora:** Thatyanne Silva do Prado
- **Orientadores:** Prof. Ramon Romankevicius Costa, D.Sc., e Prof. Fernando A. N. Castro Pinto, Dr.-Ing.
- **Bancada experimental:** Laboratório de Acústica e Vibrações (LAVI), COPPE/UFRJ

O repositório reúne os modelos Simulink, os scripts MATLAB e os dados de ensaio usados na monografia. Nele estão o controlador PID descentralizado e o controlador por modos deslizantes (SMC) embarcados em uma placa NUCLEO-G474RE (STM32G474RE), além dos modelos de simulação da planta não linear.

## Estrutura

```
firmware/     modelos Simulink embarcados e configuração do microcontrolador
simulacao/    modelo não linear da planta, scripts de configuração e resultados de simulação
dados/        registros dos ensaios de bancada apresentados no Capítulo 6
analise/      scripts que geram as figuras e as métricas dos ensaios
```

### firmware/

| Arquivo | Conteúdo |
|---|---|
| `nucleo_stm32g474_pid_v3_19_05.slx` | Modelo embarcado com o controlador PID (ensaio de 01/08) |
| `nucleo_stm32g474_smc_v4_01_08.slx` | Modelo embarcado com o controlador SMC (ensaio de 06/08) |
| `smc_mancal.m` | Função MATLAB do SMC usada nos ensaios (Apêndice da monografia) |
| `parametros_temporeal_nucleostm32g4.m` | Script de parâmetros para os modelos embarcados |
| `stm32g4_testeextmode_18_01.ioc` | Configuração do STM32CubeMX: relógios, ADCs com *oversampling*, OPAMPs, temporizadores, DMA e LPUART |

Principais características da implementação:

- passo de controle de 100 µs (10 kHz), com aritmética em precisão simples;
- quatro ADCs independentes disparados pelo TIM3 (17 kHz), com transferência por DMA e *oversampling* de 32 amostras;
- monitoramento e ajuste de parâmetros em tempo real por *external mode* (XCP sobre LPUART1 a 1 Mbaud).

### simulacao/

| Arquivo | Conteúdo |
|---|---|
| `configura_planta_simulacao2.m` | Parâmetros do rotor, dos atuadores e dos controladores; executar antes da simulação |
| `smc_AMB_digital_v2.slx` | Modelo não linear do rotor-mancal com os controladores PID e SMC discretos |
| `smc_mancal_simulacao.m` | Função do SMC com os parâmetros usados nas simulações |
| `sinais_sem_filtrokalman_ruidoso.mat` | Sinais de ruído medidos, usados como entrada nas simulações |
| `simu_pid{1,2,3}_30_07.mat`, `simu_smc{1,2,3}_30_07.mat` | Resultados das simulações: degrau, degrau com ruído e força externa de −10 N |
| `plot_simu.m` | Gera as figuras de simulação do Capítulo 4 |
| `rootlocusAMB.m`, `pid_tuner_discrete.m` | Lugar das raízes e sintonia do PID |

As varreduras de órbita em diferentes velocidades de rotação (arquivos `simu_*_w*_30_07.mat`) não foram incluídas por causa do tamanho. Para gerá-las novamente, execute o modelo com as velocidades indicadas em `plot_simu.m`.

### dados/

| Arquivo | Ensaio |
|---|---|
| `teste_pid1_01_08.xlsx` | Controlador PID: partida, regime, quatro impulsos manuais e rotação a ~1700 rpm |
| `teste_smc1_06_08.mat` | Controlador SMC: partida, regime, quatro impulsos manuais e rotação a ~1130 rpm |

Os sinais foram registrados por *external mode*. Como muitos sinais foram monitorados ao mesmo tempo, a taxa efetiva de registro é bem menor que a taxa de controle e há intervalos sem dados entre as rajadas. Canais de posição e de corrente: `[Ya, Xa, Yb, Xb]`, em metros e ampères.

### analise/

| Arquivo | Conteúdo |
|---|---|
| `figuras_pid_01_08.m` | Figuras do ensaio com PID (Capítulo 6) |
| `figuras_smc_06_08.m` | Figuras do ensaio com SMC, incluindo a função de deslizamento s(t) |
| `metricas_ensaios.m` | Métricas citadas no Capítulo 6: desvio em regime, correntes, órbitas, impulsos e função de deslizamento |

Execute os scripts a partir da própria pasta `analise/`, já que os caminhos dos dados são relativos.

## Requisitos

- MATLAB e Simulink (desenvolvido no R2025b), com Simulink Coder, Embedded Coder e Signal Processing Toolbox
- Embedded Coder Support Package for STMicroelectronics STM32 Processors
- STM32CubeMX, para abrir e regenerar o arquivo `.ioc`
- Placa NUCLEO-G474RE

## Observação sobre os ensaios com SMC

No ensaio de 06/08, a camada limite foi Φ = 0,01 m/s. Como ε/Φ = 200 s⁻¹ supera o ganho de aproximação total κ_ef = 111,5 s⁻¹, a função `smc_mancal.m` limita κ a zero. Com isso, o controlador operou fora da camada limite na maior parte do ensaio e não chegou ao modo deslizante. Essa situação é discutida no Capítulo 6 da monografia.

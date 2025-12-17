% LTE Toolbox Parameters Configuration
% This file sets up parameters for LTE Toolbox SISO simulation

%% eNodeB Configuration
enb.NDLRB = 50;              % Number of downlink resource blocks (50 for 10MHz)
enb.CellRefP = 1;           % Number of cell-specific reference signals (1 for SISO)
enb.CyclicPrefix = 'Normal'; % Cyclic prefix type
enb.DuplexMode = 'FDD';      % Duplex mode
enb.TotSubframes = 1;       % Total subframes to generate (for waveform generation)

%% PDSCH Configuration
pdsch.Modulation = '16QAM'; % Modulation scheme ('QPSK', '16QAM', '64QAM')
pdsch.RNTI = 1;             % Radio network temporary identifier
pdsch.NLayers = 1;          % Number of layers (1 for SISO)
pdsch.TxScheme = 'Port0';   % Transmission scheme ('Port0' for SISO)

%% DLSCH Configuration
% Instead of a hardcoded transport block size, we now define a target 
% coding rate. The transport block size will be calculated dynamically 
% from this, the RB count, and the modulation scheme.
cRate = 1/3;                % Target coding rate

%% Channel Configuration
snrdB = 16;                 % Signal-to-noise ratio in dB for the demo
chanMdl = 'EPA 5Hz';        % Channel model profile ('EPA 5Hz', 'EVA 70Hz', 'ETU 300Hz')

%% Simulation Parameters
visualsOn = 1;              % Enable/disable visualizations in the demo
maxNumErrs = 100;          % Maximum number of errors for BER test before stopping
maxNumBits = 1e6;           % Maximum number of bits for BER test before stopping

%% BER Test Configuration
% This range is used by the lte_tool_ber_test script
snrValues = 0:2:20;         % SNR values to test (dB)

%% Channel Estimation Configuration
cec.PilotAverage = 'TestEVM'; % Pilot averaging method
cec.FreqWindow = 9;           % Frequency averaging window size
cec.TimeWindow = 9;           % Time averaging window size

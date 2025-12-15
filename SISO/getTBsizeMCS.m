function [tbSize, actualRate] = getTBsizeMCS(modType, TCR, Nrb, numLayers, numPDSCHBits)
% New implementation without TBSTable.mat
% Uses LTE Toolbox official TBS lookup: lteMCSInfo / lteTBS

%% Mapping modulation → possible MCS ranges (3GPP TS 36.213 Table 7.1.7.1-1)
switch modType
    case 1 % QPSK
        mcsList = 0:9;     % QPSK supports MCS 0–9
    case 2 % 16QAM
        mcsList = 10:16;   % 16QAM supports MCS 10–16
    case 3 % 64QAM
        mcsList = 17:28;   % 64QAM supports MCS 17–28
    otherwise
        error('modType must be 1(QPSK),2(16QAM),3(64QAM)');
end

%% Compute #bits per layer
numBitsPerLayer = numPDSCHBits / numLayers;

%% Compute transport block size for each MCS in the set
tbSizes = zeros(length(mcsList), 1);
rates   = zeros(length(mcsList), 1);

for i = 1:length(mcsList)
    mcs = mcsList(i);

    % Use LTE Toolbox to get TBS from standard table
    info = lteMCS(mcs);     % includes Qm, R, TBS, etc.
    tbs  = lteTBS(Nrb, info);    % A.3.3.2.2 in 36.101; includes CRC
    tbSizes(i) = tbs;

    % Compute actual code rate (36.101 Table A.3.1)
    rates(i) = (tbs + 24) / numBitsPerLayer;
end

%% Select MCS whose rate best matches target code rate
rateError = abs(rates - TCR);
[~, idx] = min(rateError);

tbSize = tbSizes(idx);

%% Multi-layer correction (36.213 7.1.7.2.2 / 7.1.7.2.5)
if numLayers == 2
    % Official rule: TBS is taken from lteTBS(mcs, 2*Nrb)
    tbSize = lteTBS(mcsList(idx), 2*Nrb);
elseif numLayers == 4
    tbSize = lteTBS(mcsList(idx), 4*Nrb);
end

%% Compute final achieved rate
actualRate = (tbSize + 24) / numPDSCHBits;

end

function [rmc, trBlkSize] = lte_tool_configure(enb, pdsch, cRate)
%LTE_TOOL_CONFIGURE Create RMC config and calculate transport block size.
%   [RMC, TRBLKSIZE] = LTE_TOOL_CONFIGURE(ENB, PDSCH, CRATE) takes the
%   eNodeB, PDSCH, and coding rate parameters to create a full RMC
%   (Reference Measurement Channel) configuration structure and calculates
%   a valid transport block size.
%
%   This centralizes the configuration logic used by the main demo and BER
%   test scripts.

% Validate key input parameters before proceeding
validate_params(enb, pdsch);

% Create a baseline RMC structure for SISO ('R.0')
rmc = lteRMCDL('R.0');

% Apply parameters from the main configuration file
rmc.NDLRB = enb.NDLRB;
rmc.CellRefP = enb.CellRefP;
rmc.PDSCH.Modulation = pdsch.Modulation;
rmc.PDSCH.RNTI = pdsch.RNTI;
rmc.PDSCH.NLayers = pdsch.NLayers;
rmc.PDSCH.TxScheme = pdsch.TxScheme;

% Get PDSCH indices and capacity info
% ltePDSCHIndices requires: enb, chs, prbset
% PRBSet from lteRMCDL defines the PRB allocation for the RMC
[~, pdschInfo] = ltePDSCHIndices(rmc, rmc.PDSCH, rmc.PDSCH.PRBSet);
G = pdschInfo.G;  % Total coded bits capacity for PDSCH

% Calculate target TBS based on capacity and code rate
% Relationship: G ≈ TBS / cRate, so targetTBS ≈ G * cRate
targetTBS = floor(G * cRate);

% Find the nearest valid TBS from the TBS table
% The number of PRBs allocated to PDSCH
nPRB = numel(unique(pdschInfo.PRBSet));
trBlkSize = findValidTBS(nPRB, targetTBS);

% Assign the calculated size back to the RMC structure
rmc.PDSCH.TrBlkSizes = trBlkSize;

end

function validate_params(enb, pdsch)
    % Validate Number of Downlink Resource Blocks (NDLRB)
    validNDLRB = [6, 15, 25, 50, 75, 100];
    if ~ismember(enb.NDLRB, validNDLRB)
        error('lte_tool:invalidNDLRB', ...
            'Invalid NDLRB value: %d. Must be one of [%s].', ...
            enb.NDLRB, num2str(validNDLRB));
    end
    
    % Validate Modulation Scheme
    validModulations = {'QPSK', '16QAM', '64QAM', '256QAM'};
    if ~ismember(pdsch.Modulation, validModulations)
        error('lte_tool:invalidModulation', ...
            'Invalid modulation: ''%s''. Must be one of [%s].', ...
            pdsch.Modulation, strjoin(validModulations, ', '));
    end
end

function tbs = findValidTBS(nPRB, targetTBS)
%FINDVALIDTBS Find the nearest valid TBS from the LTE TBS table.
%   TBS = FINDVALIDTBS(NPRB, TARGETTBS) searches the TBS table for the
%   closest valid transport block size that is >= targetTBS.
%
%   NPRB is the number of Physical Resource Blocks allocated.
%   TARGETTBS is the desired transport block size.
%
%   The TBS index (ITBS) ranges from 0 to 26 in the LTE standard.

    % Search TBS table for the smallest TBS >= targetTBS
    for itbs = 0:26
        tbs = lteTBS(nPRB, itbs);
        if tbs >= targetTBS
            return;
        end
    end

    % If no TBS found >= targetTBS, use the maximum available
    tbs = lteTBS(nPRB, 26);
end

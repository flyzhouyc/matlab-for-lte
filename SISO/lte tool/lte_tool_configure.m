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

% Calculate a valid transport block size (TBS) for the current configuration.
% Step 1: Get PDSCH capacity info using ltePDSCHIndices (requires: enb, chs, prbset)
% The info structure contains G (total coded bits capacity)
[~, pdschInfo] = ltePDSCHIndices(rmc, rmc.PDSCH, rmc.PDSCH.PRBSet);
G = pdschInfo.G;  % Total coded bits capacity

% Step 2: Calculate target TBS based on capacity and code rate
% Relationship: cRate ≈ TBS / G, so targetTBS ≈ G * cRate
targetTBS = floor(G * cRate);

% Step 3: Find the nearest valid TBS from the TBS table
% lteTBS(nprb, itbs) returns TBS for given PRB count and TBS index
nPRB = numel(rmc.PDSCH.PRBSet);  % Number of PRBs allocated
trBlkSize = findValidTBS(nPRB, targetTBS, pdsch.NLayers);

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

function tbs = findValidTBS(nPRB, targetTBS, nLayers)
%FINDVALIDTBS Find the nearest valid TBS from the LTE TBS table.
%   TBS = FINDVALIDTBS(NPRB, TARGETTBS, NLAYERS) searches the TBS table
%   for the closest valid transport block size that is >= targetTBS.
%
%   NPRB is the number of Physical Resource Blocks allocated.
%   TARGETTBS is the desired transport block size.
%   NLAYERS is the number of spatial multiplexing layers.
%
%   The TBS index (ITBS) ranges from 0 to 26 in the LTE standard.
%   lteTBS syntax: lteTBS(nprb, itbs) or lteTBS(nprb, itbs, nLayers)

    % Search TBS table for the smallest TBS >= targetTBS
    for itbs = 0:26
        % Use 3-parameter syntax: lteTBS(nprb, itbs, smnlayer)
        tbs = lteTBS(nPRB, itbs, nLayers);
        if tbs >= targetTBS
            return;
        end
    end

    % If no TBS found >= targetTBS, use the maximum available
    tbs = lteTBS(nPRB, 26, nLayers);
end


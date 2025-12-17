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

% Get PDSCH info required for Transport Block Size (TBS) calculation
pdschInfo = ltePDSCHInfo(rmc, rmc.PDSCH);

% Calculate a valid transport block size for the given parameters
trBlkSize = lteTBS(rmc.NDLRB, pdschInfo.PRBSet, rmc.PDSCH.Modulation, rmc.PDSCH.NLayers, cRate);

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

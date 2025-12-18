function [grid] = lte_tool_resource_grid(rmc, subframe, pdschSymbols)
%LTE_TOOL_RESOURCE_GRID Create a resource grid and map symbols.
%   GRID = LTE_TOOL_RESOURCE_GRID(RMC, SUBFRAME, PDSCHSYMBOLS) creates an
%   empty downlink resource grid, maps the Physical Downlink Shared
%   Channel (PDSCH) symbols, and adds the Cell-Specific Reference Signals
%   (CSR) for a given subframe.
%
%   RMC is the Reference Measurement Channel configuration structure.
%   SUBFRAME is the subframe number.
%   PDSCHSYMBOLS are the PDSCH complex symbols to be mapped.
%
%   GRID is the populated resource grid.

% Set subframe number in RMC structure for LTE Toolbox functions
rmc.NSubframe = subframe;

% Create empty grid
grid = lteDLResourceGrid(rmc);
    % Get PDSCH indices (requires: enb, chs, prbset; subframe is in rmc.NSubframe)
    pdschIndices = ltePDSCHIndices(rmc, rmc.PDSCH, rmc.PDSCH.PRBSet);

    % Map PDSCH symbols to the grid
    grid(pdschIndices) = pdschSymbols;

    % Generate and get indices for cell-specific reference signals
    % lteCellRS and lteCellRSIndices use NSubframe from the rmc structure
    csr = lteCellRS(rmc);
    csrIndices = lteCellRSIndices(rmc);

    % Map CSR symbols to the grid
    grid(csrIndices) = csr;
    
end

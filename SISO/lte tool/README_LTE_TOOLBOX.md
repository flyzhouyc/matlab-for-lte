# LTE Toolbox Refactored Project

This directory contains a refactored version of the LTE SISO simulation that uses MATLAB's **LTE Toolbox** instead of the custom implementation in the parent directory.

## Project Overview

This project demonstrates LTE Downlink SISO (Mode 1) transmission using the official MATLAB LTE Toolbox functions. It provides the same functionality as the original custom implementation but leverages the optimized and standardized 3GPP-compliant functions from the toolbox.

## Key Differences from Custom Implementation

### Custom Implementation (../SISO/)
- **Manual implementation** of all LTE processing functions
- Uses lower-level Communications Toolbox functions combined with custom code
- Pure educational implementation showing inner workings
- Flat structure with one function per processing stage

### LTE Toolbox Implementation (this directory)
- **Uses standardized LTE Toolbox functions** compliant with 3GPP specs
- Higher-level, optimized functions for each processing stage
- Built-in functionality for channel estimation, equalization, error handling
- Cleaner, more maintainable code using toolbox abstractions

## Files Structure

```
lte tool/
├── README_LTE_TOOLBOX.md      This file
├── lte_tool_params.m          Parameter configuration script
├── lte_tool_demo.m            Main demo with real-time visualization
├── lte_tool_ber_test.m        BER performance testing script
├── lte_tool_step.m            Core processing function
└── lte_tool_visualize.m       Visualization function
```

## Requirements

- **MATLAB** R2015b or later (LTE Toolbox was introduced in R2015b)
- **LTE Toolbox** (http://www.mathworks.com/products/lte/)

### Checking Toolbox Installation

To verify you have the LTE Toolbox installed:
```matlab
>> ver
```

Look for "LTE Toolbox" in the list. Alternatively:
```matlab
>> which lteRMCDL
```

If the toolbox is not installed, you can:
1. Install it via MATLAB Add-Ons
2. Download from MathWorks: http://www.mathworks.com/products/lte/
3. Use the original custom implementation in the parent directory

## Usage

### 1. Interactive Visualization Demo

Run the main demo to visualize transmitted/received signals:
```matlab
>> addpath('./lte tool');
>> lte_tool_params;  % Load parameters
>> lte_tool_demo;     % Run demo
```

This will:
- Generate LTE downlink waveforms
- Simulate channel effects (fading + AWGN)
- Display signal spectra and constellations
- Show real-time BER measurement

### 2. BER Performance Testing

Run comprehensive BER tests across SNR values:
```matlab
>> addpath('./lte tool');
>> lte_tool_params;       % Load parameters
>> lte_tool_ber_test;     % Run BER tests
```

This will:
- Test BER across multiple SNR values (configurable in lte_tool_params.m)
- Generate BER vs SNR plots
- Show CRC failure rates
- Measure performance for different modulation schemes

### 3. Customizing Parameters

Edit `lte_tool_params.m` to change:
- **Channel bandwidth**: `enb.NDLRB` (6, 15, 25, 50, 75, 100 RBs)
- **Modulation scheme**: `pdsch.Modulation` ('QPSK', '16QAM', '64QAM', '256QAM')
- **SNR values**: `snrValues` array
- **Coding rate**: `cRate`
- **Channel model**: `chanMdl`, `delayProfile`, `maxDoppler`
- **Stopping criteria**: `maxNumErrs`, `maxNumBits`

## Mapping Between Custom and LTE Toolbox Functions

| Custom Function | LTE Toolbox Equivalent | Description |
|----------------|----------------------|-------------|
| `lteTbChannelCoding()` | `lteDLSCH()` | DL-SCH encoding |
| `lteTbChannelDecoding()` | `lteDLSCHDecode()` | DL-SCH decoding |
| custom PDSCH processing | `ltePDSCH()` | PDSCH symbol generation |
| custom PDSCH decode | `ltePDSCHDecode()` | PDSCH decoding |
| `OFDMTx()` / `OFDMRx()` | `lteOFDMModulate()` / `lteOFDMDemodulate()` | OFDM modulation/demodulation |
| `ChanEstimate()` | `lteDLChannelEstimate()` | Channel estimation |
| `Equalizer()` | Built into `ltePDSCHDecode()` | Equalization |
| `Modulator()` | `lteSymbolModulate()` | Symbol modulation |
| `DemodulatorSoft()` | Built into `ltePDSCHDecode()` | Soft demodulation |
| `CSRgenerator()` | `lteCellRS()` | Cell-specific reference signals |
| `lteScramble()` / `lteDescramble()` | Built into toolbox functions | Scrambling |

## Technical Details

### Key LTE Toolbox Functions Used

1. **`lteRMCDL`** - Creates Reference Measurement Channel (RMC) configuration
2. **`lteDLSCH`** - Performs DL-SCH encoding (CRC, turbo coding, rate matching)
3. **`lteDLSCHDecode`** - Performs DL-SCH decoding
4. **`ltePDSCH`** - Generates PDSCH symbols
5. **`ltePDSCHDecode`** - Decodes PDSCH with channel estimation and equalization
6. **`lteOFDMModulate`** / **`lteOFDMDemodulate`** - OFDM processing
7. **`lteDLChannelEstimate`** - Channel estimation using reference signals
8. **`lteCellRS`** - Generate cell-specific reference signals

### Processing Chain

**Transmitter:**
1. Transport block generation → `lteDLSCH`
2. PDSCH processing → `ltePDSCH`
3. Resource element mapping → Implicit in toolbox
4. OFDM modulation → `lteOFDMModulate`

**Channel:**
1. Fading channel → `comm.LTEChannel` / `comm.RicianChannel`
2. AWGN → `comm.AWGNChannel`

**Receiver:**
1. OFDM demodulation → `lteOFDMDemodulate`
2. Channel estimation → `lteDLChannelEstimate`
3. PDSCH decoding → `ltePDSCHDecode`
4. DL-SCH decoding → `lteDLSCHDecode`

### Configuration Reference

The project uses **RMC (Reference Measurement Channel) R.0** which is designed for SISO transmission (single antenna port 0). This corresponds to:
- TM1 (Transmission Mode 1)
- Single antenna port
- No MIMO or diversity

For different configurations, you can use other RMCs:
- **R.1**: SIMO with 2 receive antennas
- **R.2**: SIMO with 4 receive antennas
- **R.4**: Transmit diversity with 2 antennas
- **R.5-R.11**: Various MIMO configurations

## Performance Considerations

- LTE Toolbox functions are **vectorized and optimized** for performance
- Channel estimation uses **frequency-domain processing** for efficiency
- Codeword processing supports **early termination** for faster simulations
- Reference signals are **efficiently generated** using built-in algorithms

## Troubleshooting

### Common Issues

1. **"function not found" errors**: Ensure LTE Toolbox is installed
2. **Slow simulations**: Reduce `maxNumBits` in lte_tool_params.m
3. **Out of memory**: Decrease `enb.NDLRB` (smaller bandwidth)
4. **Visualization errors**: Ensure figures are open/close properly

### Channel Model Selection

Available channel model profiles in lte_tool_params.m:
- `'EPA'`: Extended Pedestrian A (0Hz to 5Hz Doppler)
- `'EVA'`: Extended Vehicular A (5Hz to 70Hz Doppler)
- `'ETU'`: Extended Typical Urban (70Hz to 300Hz Doppler)

See `lteFadingChannel` documentation for more options.

## References

- **LTE Toolbox Documentation**: https://www.mathworks.com/help/lte/
- **3GPP TS 36.211**: Physical channels and modulation
- **3GPP TS 36.212**: Multiplexing and channel coding
- **Original Book**: "Understanding LTE with MATLAB" by Houman Zarrinkoub

## Examples

### Testing Different Modulation Schemes
```matlab
% Test QPSK
rmc.PDSCH.Modulation = 'QPSK';
lte_tool_ber_test;

% Test 64QAM
rmc.PDSCH.Modulation = '64QAM';
lte_tool_ber_test;
```

### Testing Different Channel Conditions
```matlab
% Static channel (no fading, just AWGN)
delayProfile = 'None';
maxDoppler = 0;
lte_tool_demo;

% High mobility (70 Hz Doppler)
delayProfile = 'EVA';
maxDoppler = 70;
lte_tool_ber_test;
```

### Comparing with Original Implementation
```matlab
% Run both implementations with same parameters
% and compare the results
disp('Custom implementation:');
cd ../;
commlteSISO_params;
commlteSISO_test_timing_ber;

disp('LTE Toolbox implementation:');
cd lte\ tool;
lte_tool_params;
lte_tool_ber_test;
```

## Limitations

This refactored implementation:
- Focuses on **SISO only** (Transmission Mode 1)
- Uses **single cell-specific reference signal** pattern
- Does not include **hybrid-ARQ** functionality
- Assumes **perfect synchronization** (no timing offset)
- Does not model **frequency offset** or phase noise

For more advanced features (MIMO, CA, CoMP, etc.), consult the LTE Toolbox documentation.

## License

This code is for educational purposes demonstrating LTE Toolbox capabilities. MATLAB and LTE Toolbox are products of The MathWorks, Inc.

## Support

For issues with the refactored code:
1. Check this README first
2. Review the original implementation in ../SISO/
3. Consult MATLAB LTE Toolbox documentation
4. Check your MATLAB version and toolbox installation

---

**Author**: Claude Code (refactored from original by other contributors)
**Date**: 2025-12-17
**MATLAB Version**: R2020a or later recommended

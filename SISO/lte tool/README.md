# LTE Toolbox SISO Simulation - Usage and Testing Guide

This document provides comprehensive guidance for using and testing the LTE SISO (Single Input Single Output) downlink simulation tool built on MATLAB's LTE Toolbox.

## Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Quick Start](#quick-start)
4. [File Structure](#file-structure)
5. [Configuration](#configuration)
6. [Running Simulations](#running-simulations)
7. [Understanding the Output](#understanding-the-output)
8. [Testing](#testing)
9. [Customization](#customization)
10. [Troubleshooting](#troubleshooting)

---

## Overview

This toolset simulates LTE downlink transmission in SISO mode (Transmission Mode 1). It implements the complete physical layer processing chain:

**Transmitter:**
- Transport block generation
- DL-SCH encoding (CRC, turbo coding, rate matching)
- PDSCH modulation (QPSK, 16QAM, 64QAM, 256QAM)
- Resource element mapping with Cell-Specific Reference Signals
- OFDM modulation

**Channel:**
- Fading channel models (EPA, EVA, ETU)
- Configurable Doppler frequency
- AWGN noise addition

**Receiver:**
- OFDM demodulation
- Channel estimation using pilot signals
- MMSE equalization
- PDSCH decoding
- DL-SCH decoding with CRC check

---

## Requirements

- MATLAB R2018b or later
- LTE Toolbox
- Communications Toolbox (for `comm.ErrorRate` and `awgn`)

To verify toolbox installation:
```matlab
>> ver('lte')
>> ver('comm')
```

---

## Quick Start

### Run a Single Simulation with Visualization

```matlab
>> cd 'path/to/lte tool'
>> lte_tool_demo
```

This runs 10 subframes and displays:
- Transmitted/received signal spectra
- Channel frequency and impulse responses
- Transmitted and received constellations

### Run BER Performance Test

```matlab
>> cd 'path/to/lte tool'
>> lte_tool_ber_test
```

This sweeps through SNR values (default: 0-20 dB) and generates BER curves.

### Run Unit Tests

```matlab
>> cd 'path/to/lte tool'
>> runtests('lte_tool_tests')
```

---

## File Structure

| File | Description |
|------|-------------|
| `lte_tool_params.m` | Configuration parameters (modulation, SNR, channel model, etc.) |
| `lte_tool_configure.m` | Creates RMC structure and calculates transport block size |
| `lte_tool_step.m` | Processes one subframe through the transceiver chain |
| `lte_tool_resource_grid.m` | Creates resource grid and maps PDSCH/CSR symbols |
| `lte_tool_apply_channel.m` | Applies fading channel and AWGN |
| `lte_tool_demo.m` | Main demo script with visualization |
| `lte_tool_ber_test.m` | BER performance testing across SNR range |
| `lte_tool_visualize.m` | Generates spectrum and constellation plots |
| `lte_tool_tests.m` | Unit test suite |

---

## Configuration

All parameters are defined in `lte_tool_params.m`:

### eNodeB Configuration

```matlab
enb.NDLRB = 50;              % Resource blocks: 6, 15, 25, 50, 75, or 100
enb.CellRefP = 1;            % Reference signal ports (1 for SISO)
enb.CyclicPrefix = 'Normal'; % 'Normal' or 'Extended'
enb.DuplexMode = 'FDD';      % 'FDD' or 'TDD'
```

**Bandwidth Mapping:**
| NDLRB | Bandwidth |
|-------|-----------|
| 6     | 1.4 MHz   |
| 15    | 3 MHz     |
| 25    | 5 MHz     |
| 50    | 10 MHz    |
| 75    | 15 MHz    |
| 100   | 20 MHz    |

### PDSCH Configuration

```matlab
pdsch.Modulation = '16QAM';  % 'QPSK', '16QAM', '64QAM', or '256QAM'
pdsch.RNTI = 1;              % Radio Network Temporary Identifier
pdsch.NLayers = 1;           % Number of layers (1 for SISO)
pdsch.TxScheme = 'Port0';    % Transmission scheme for SISO
```

### Channel Configuration

```matlab
snrdB = 16;                  % Signal-to-noise ratio (dB)
chanMdl = 'EPA 5Hz';         % Channel model: 'EPA 5Hz', 'EVA 70Hz', 'ETU 300Hz'
```

**Channel Model Profiles:**
| Profile | Description | Typical Use |
|---------|-------------|-------------|
| EPA     | Extended Pedestrian A | Low delay spread, pedestrian |
| EVA     | Extended Vehicular A | Medium delay spread, vehicular |
| ETU     | Extended Typical Urban | High delay spread, urban |

### Simulation Control

```matlab
visualsOn = 1;               % Enable (1) or disable (0) plots
maxNumErrs = 100;            % Stop after this many errors
maxNumBits = 1e6;            % Stop after this many bits
cRate = 1/3;                 % Target coding rate
```

### BER Test Configuration

```matlab
snrValues = 0:2:20;          % SNR points to test (dB)
```

---

## Running Simulations

### Demo Mode

```matlab
>> lte_tool_demo
```

**Output:**
```
LTE SISO Simulation
===================
Channel Bandwidth: 9.00 MHz
Modulation: 16QAM
Target Code Rate: 0.33
Transport Block Size: 6456 bits
Channel Model: EPA 5Hz
SNR: 16 dB

Starting simulation (up to 10 subframes for visualization)...
  Subframe 0: Errors = 0, Cumulative BER = 0.0000e+00
  Subframe 1: Errors = 0, Cumulative BER = 0.0000e+00
  ...

Simulation Complete
===================
Bit Error Rate: 0.0000e+00
Number of Errors: 0
Total Bits: 64560
SNR: 16 dB
```

### BER Testing Mode

```matlab
>> lte_tool_ber_test
```

**Output:**
```
LTE SISO BER Performance Test
=============================
Channel Bandwidth: 9.00 MHz
Modulation: 16QAM
Target Code Rate: 0.33
Transport Block Size: 6456 bits
Channel Model: EPA 5Hz
SNR Range: 0 to 20 dB

Testing SNR = 0 dB...
  BER = 2.3456e-01 (1523 errors / 6456 bits)
  CRC failures = 1
  Subframes processed = 1

Testing SNR = 2 dB...
...
```

### Programmatic Usage

Process a single subframe:

```matlab
% Load parameters
lte_tool_params;

% Configure RMC
[rmc, trBlkSize] = lte_tool_configure(enb, pdsch, cRate);

% Generate random data
dataIn = randi([0 1], trBlkSize, 1);

% Process one subframe (basic output)
[dataOut, crcError] = lte_tool_step(0, dataIn, rmc, snrdB, chanMdl, cec);

% Process with visualization data
[dataOut, crcError, txWaveform, rxWaveform, rxData, channelSpec] = ...
    lte_tool_step(0, dataIn, rmc, snrdB, chanMdl, cec);
```

---

## Understanding the Output

### Visualization Plots

The demo generates a 2x3 subplot figure:

| Position | Plot | Description |
|----------|------|-------------|
| (1,1) | Transmitted Spectrum | Power spectral density of TX waveform |
| (2,1) | Received Spectrum | Power spectral density of RX waveform (after channel) |
| (1,2) | Channel Frequency Response | Estimated channel magnitude vs subcarrier |
| (2,2) | Channel Impulse Response | Path gain magnitudes |
| (1,3) | TX Constellation | Ideal transmitted PDSCH symbols |
| (2,3) | RX Constellation | Equalized received symbols |

### BER Curves

The BER test generates:
1. **BER vs SNR plot** - Log-scale BER against SNR in dB
2. **CRC Failure Rate plot** - Transport block error rate (if failures occur)
3. **Summary table** - Tabulated results for all SNR points

### Key Metrics

| Metric | Description |
|--------|-------------|
| BER | Bit Error Rate = Errors / Total Bits |
| CRC Error | 1 if transport block failed CRC check, 0 otherwise |
| Subframes | Number of 1ms subframes processed |

---

## Testing

### Running All Tests

```matlab
>> results = runtests('lte_tool_tests');
>> disp(results)
```

### Test Cases

| Test | Description |
|------|-------------|
| `testValidConfiguration` | Verifies RMC structure creation with valid parameters |
| `testInvalidNDLRB` | Confirms error thrown for invalid NDLRB values |
| `testStepFunction` | Tests single subframe processing |
| `testDemoSmoke` | Verifies demo runs without errors |

### Running Individual Tests

```matlab
>> runtests('lte_tool_tests', 'ProcedureName', 'testValidConfiguration')
```

### Test Mode

When running tests, `LTE_TOOL_TEST_MODE` is set to:
- Skip `clear`/`clc` commands
- Disable visualization (no figure windows)

---

## Customization

### Change Modulation Scheme

Edit `lte_tool_params.m`:
```matlab
pdsch.Modulation = '64QAM';  % Higher order = higher throughput, more errors
```

### Change Channel Model

```matlab
chanMdl = 'EVA 70Hz';        % More challenging vehicular channel
```

### Change Bandwidth

```matlab
enb.NDLRB = 100;             % 20 MHz bandwidth (maximum LTE)
```

### Disable Visualization for Faster Testing

```matlab
visualsOn = 0;
```

### Custom SNR Range for BER Tests

```matlab
snrValues = -5:1:25;         % Wider range, finer steps
```

### Increase Simulation Accuracy

```matlab
maxNumErrs = 1000;           % More errors for statistical accuracy
maxNumBits = 1e7;            % More bits per SNR point
```

---

## Troubleshooting

### Common Errors

**"Invalid NDLRB value"**
```
Error using lte_tool_configure (line 40)
Invalid NDLRB value: 99. Must be one of [6 15 25 50 75 100].
```
*Solution:* Use a valid LTE bandwidth configuration.

**"Invalid modulation"**
```
Error using lte_tool_configure (line 49)
Invalid modulation: 'QAM16'. Must be one of [QPSK, 16QAM, 64QAM, 256QAM].
```
*Solution:* Use exact modulation string (case-sensitive).

**Toolbox not found**
```
Undefined function 'lteRMCDL' for input arguments of type 'char'.
```
*Solution:* Install LTE Toolbox: `>> matlab.addons.install('LTE Toolbox')`

### Performance Tips

1. **Disable visualization** for BER tests: `visualsOn = 0`
2. **Reduce maxNumBits** for quick tests: `maxNumBits = 1e5`
3. **Use parallel computing** (modify loop in `lte_tool_ber_test.m` to use `parfor`)

### Reproducibility

Results are reproducible due to:
- Fixed fading channel seed (73)
- Controlled AWGN RNG with counter-based seeding
- Channel state reset at each SNR point in BER tests

To get different random sequences, modify in `lte_tool_apply_channel.m`:
```matlab
chanCfg.Seed = randi(1000);  % Random seed each run
```

---

## API Reference

### lte_tool_configure

```matlab
[rmc, trBlkSize] = lte_tool_configure(enb, pdsch, cRate)
```
Creates RMC configuration and calculates transport block size.

### lte_tool_step

```matlab
% Basic usage
[dataOut, crcError] = lte_tool_step(subframe, dataIn, rmc, snrdB, chanMdl, cec)

% Extended output for visualization
[dataOut, crcError, txWaveform, rxWaveform, rxData, channelSpec] = ...
    lte_tool_step(subframe, dataIn, rmc, snrdB, chanMdl, cec)
```
Processes one subframe through the complete transceiver chain.

### lte_tool_apply_channel

```matlab
[rxWaveform, chanInfo, fadingChannel] = lte_tool_apply_channel(txWaveform, snrdB, chanMdl, samplingRate)
```
Applies fading channel and AWGN to a waveform.

### lte_tool_visualize

```matlab
lte_tool_visualize(rmc, txWaveform, rxWaveform, rxData, channelSpec, subframe)
```
Creates visualization plots for spectrum and constellation analysis.

---

## Version History

- **v1.0** - Initial release with basic SISO simulation
- **v1.1** - Bug fixes from Codex review:
  - Fixed BER loop control using `Measures` vector
  - Replaced `comm.LTEChannel` with `lteFadingChannel`
  - Added missing config parameters (`NLayers`, `TxScheme`, `CellRefP`)
  - Added test mode guard for `clear`/`clc`
  - Added MMSE equalization for constellation display
  - Implemented continuous fading with `InitTime` tracking
  - Added controlled AWGN RNG for reproducibility
  - Added channel state reset for independent test/BER runs
  - Improved PathGains dimension handling

---

## License

This project is for educational purposes, demonstrating LTE physical layer concepts using MATLAB's LTE Toolbox.

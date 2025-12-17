# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an LTE (Long Term Evolution) physical layer simulation project focused on SISO (Single Input Single Output) transmission mode 1. Based on Chapter 5 of "Understanding LTE with MATLAB", this codebase simulates LTE Downlink signal transmission and reception.

## Running the Simulations

This is a pure MATLAB project requiring no build process or compilation. Run simulations directly from MATLAB command prompt:

**Primary Simulation (with visualization):**
```matlab
>> commlteSISO
```
This runs a single simulation with real-time visualization of transmitted/received signal spectra and constellations.

**BER Performance Testing:**
```matlab
>> commlteSISO_test_timing_ber
```
This performs multiple simulations across different SNR values to generate BER (Bit Error Rate) curves.

## Key Architecture

### Simulation Flow Control
1. `commlteSISO_params.m` - Sets experiment parameters (modulation, SNR, channel model, limits)
2. `commlteSISO_initialize.m` - Initializes LTE transceiver parameter structures
3. `commlteSISO_step.m` - Processes one subframe of data (called in loop)
4. `zVisualize.m` - Generates signal spectrum and constellation plots

### Transceiver Processing Pipeline
The signal processing follows LTE physical layer procedures:

**Transmitter chain (within commlteSISO_step.m):**
- Transport block generation → CRC attachment → Channel coding → Scrambling → Modulation → Resource element mapping → OFDM modulation

**Receiver chain:**
- OFDM demodulation → Resource element demapping → Channel estimation → Equalization → Demodulation → Descrambling → Channel decoding → CRC detection

### Core Component Categories

**Coding/Modulation:**
- Channel coding: `lteTbChannelCoding.m`/`lteTbChannelDecoding.m`
- Modulation: `Modulator.m`, `DemodulatorSoft.m`
- Turbo decoding: `commLTETurboDecoder.m`

**OFDM Processing:**
- OFDM modulation: `OFDMTx.m`
- OFDM demodulation: `OFDMRx.m`

**Resource Management:**
- Resource element mapping: `REmapper_1Tx.m`
- Resource element demapping: `REdemapper_1Tx.m`

**Channel Handling:**
- Channel estimation: `ChanEstimate_1Tx.m`
- Equalization: `Equalizer.m`
- Channel models: `AWGNChannel.m`, `MIMOFadingChan.m`

**Reference Signals:**
- Cell-specific RS: `CSRgenerator.m`
- Channel estimation ID: `lteIdChEst.m`

## Configuration Parameters

Key parameters in `commlteSISO_params.m`:
- `chanBW` - Channel bandwidth (1.4M to 20MHz)
- `modType` - Modulation scheme ('QPSK', '16QAM', '64QAM')
- `snrdB` - Signal-to-noise ratio
- `Eqmode` - Equalizer type ('ZF', 'MMSE')
- `maxNumErrs`, `maxNumBits` - Simulation stopping criteria

## Important Notes

- Flat directory structure - all MATLAB files in root directory
- No external dependencies beyond MATLAB (no toolboxes required)
- No automated testing framework - manual MATLAB execution only
- Chinese comments in some functions - context from original development
- No file I/O - parameters and output stored in MATLAB workspace

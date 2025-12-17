# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LTE SISO downlink simulation using MATLAB's LTE Toolbox. Implements complete physical layer processing chain for Transmission Mode 1 (single antenna).

**Requirements:** MATLAB R2018b+, LTE Toolbox, Communications Toolbox

## Running Simulations

```matlab
% Demo with visualization (10 subframes)
>> lte_tool_demo

% BER performance test across SNR range
>> lte_tool_ber_test

% Run unit tests
>> runtests('lte_tool_tests')
```

## Architecture

### Processing Flow

`lte_tool_params.m` → `lte_tool_configure.m` → `lte_tool_step.m` (loop) → `lte_tool_visualize.m`

### Core Function: lte_tool_step.m

Single subframe processing through complete TX/RX chain:

**TX:** `lteDLSCH` → `ltePDSCH` → `lte_tool_resource_grid` → `lteOFDMModulate`

**Channel:** `lte_tool_apply_channel` (fading + AWGN)

**RX:** `lteOFDMDemodulate` → `lteDLChannelEstimate` → `ltePDSCHDecode` → `lteDLSCHDecode`

Returns basic `[dataOut, crcError]` or extended output with waveforms for visualization.

### Key Configuration (lte_tool_params.m)

- `enb.NDLRB`: Bandwidth (6/15/25/50/75/100 RBs = 1.4/3/5/10/15/20 MHz)
- `pdsch.Modulation`: 'QPSK', '16QAM', '64QAM', '256QAM'
- `chanMdl`: 'EPA 5Hz', 'EVA 70Hz', 'ETU 300Hz'
- `cRate`: Target coding rate (TBS calculated dynamically)

## Key Differences from Parent SISO Directory

This subdirectory uses **MATLAB LTE Toolbox functions** (`lteDLSCH`, `ltePDSCH`, `lteOFDMModulate`, etc.) while the parent SISO directory contains **custom implementations** of these algorithms based on "Understanding LTE with MATLAB".

## Test Mode

Set `LTE_TOOL_TEST_MODE = true` to skip `clear`/`clc` and disable visualization during automated testing.

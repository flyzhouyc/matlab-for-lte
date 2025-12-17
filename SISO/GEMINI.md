# LTE SISO Transceiver Models (MATLAB)

This directory contains two MATLAB implementations of a Single-Input Single-Output (SISO) LTE transceiver model, both focusing on the downlink (PDSCH) processing chain.

---

## 1. Custom Implementation

This section describes the MATLAB implementation that uses custom-developed functions, primarily as described in Chapter 5 of "Understanding LTE with MATLAB". The project allows for simulation and analysis of various aspects of an LTE system, including channel coding, modulation, OFDM transmission, channel effects (fading and AWGN), equalization, and demodulation/decoding.

### Project Overview

The project simulates a simplified LTE SISO (Mode 1) system. It demonstrates the full physical layer processing from the transport block generation to bit error rate (BER) calculation. Key features include:

*   **Configurable Parameters:** Various simulation parameters such as channel bandwidth, control region size, modulation type (QPSK, 16QAM, 64QAM), coding rate, channel model (e.g., EPA 0Hz), equalizer type (ZF, MMSE), and channel estimation methods can be configured.
*   **Two Main Demos:**
    *   `commlteSISO.m`: A real-time simulation that processes one subframe at a time, allowing visualization of transmitted/received signals and constellations.
    *   `commlteSISO_test_timing_ber.m`: A batch simulation for computing Bit Error Rate (BER) versus Signal-to-Noise Ratio (SNR) curves.
*   **Modular Design:** The system is broken down into numerous MATLAB functions, each handling a specific part of the LTE physical layer (e.g., `genPayload`, `lteTbChannelCoding`, `Modulator`, `OFDMTx`, `MIMOFadingChan`, `Equalizer`, `lteTbChannelDecoding`).

### Building and Running

This project is implemented in MATLAB. To run the simulations:

1.  **Open MATLAB:** Launch MATLAB and ensure your current working directory is `C:\Users\zycuxa\matlab-for-lte\SISO`.

2.  **Running the Visualization Demo (`commlteSISO.m`):**
    *   Type `commlteSISO` at the MATLAB command prompt.
    *   This script will set up parameters from `commlteSISO_params.m`, initialize the transceiver with `commlteSISO_initialize.m`, and then run a loop calling `commlteSISO_step.m` for each subframe.
    *   `zVisualize.m` will display magnitude spectra and constellations after each subframe.
    *   **Exploration:** Modify parameters in `commlteSISO_params.m` (e.g., `modType`, `snrdB`, `maxNumErrs`, `maxNumBits`, `visualsOn`) to observe their effects on the system's performance and visualizations.

3.  **Running the BER Test Demo (`commlteSISO_test_timing_ber.m`):**
    *   Type `commlteSISO_test_timing_ber` at the MATLAB command prompt.
    *   This script iterates through a range of SNR values (defined within `commlteSISO_initialize.m` based on `modType`) and computes the BER for each SNR point.
    *   For accurate BER results, ensure `maxNumErrs` and `maxNumBits` in `commlteSISO_params.m` are set to sufficiently large values (e.g., `1e4` and `1e7` respectively).
    *   **Exploration:** Change `modType`, `Eqmode`, and `chEstOn` in `commlteSISO_params.m` to analyze the impact of different modulation schemes, equalization methods, and channel estimation on BER performance.

### Development Conventions

*   **MATLAB Functions:** The project extensively uses self-contained `.m` files for functions, with clear inputs and outputs.
*   **Parameter Files:** `commlteSISO_params.m` acts as a central configuration file for simulation parameters.
*   **Naming Conventions:** Files generally follow a descriptive naming convention (e.g., `commlteSISO_step.m`, `ChanEstimate_1Tx.m`).
*   **No explicit build system:** As a MATLAB project, compilation is typically handled implicitly by the MATLAB environment.

---

## 2. LTE Toolbox Implementation

This section describes a refactored version of the LTE SISO simulation that leverages MATLAB's **LTE Toolbox** instead of the custom implementation. It provides the same functionality as the original custom implementation but uses optimized and standardized 3GPP-compliant functions from the toolbox.

### Project Overview

This project demonstrates LTE Downlink SISO (Mode 1) transmission using the official MATLAB LTE Toolbox functions. It leverages higher-level, optimized functions for each processing stage, resulting in cleaner and more maintainable code through toolbox abstractions.

### Key Differences from Custom Implementation

| Feature                  | Custom Implementation (`../SISO/`)                     | LTE Toolbox Implementation (`./lte tool/`)                                |
| :----------------------- | :----------------------------------------------------- | :------------------------------------------------------------------------ |
| **Implementation**       | Manual implementation of all LTE processing functions. | Uses standardized LTE Toolbox functions compliant with 3GPP specs.        |
| **Function Abstraction** | Uses lower-level Communications Toolbox functions.       | Higher-level, optimized functions for each processing stage.              |
| **Educational Focus**    | Pure educational, showing inner workings.              | Built-in functionality for channel estimation, equalization, error handling. |
| **Structure**            | Flat structure with one function per processing stage. | Cleaner, more maintainable code using toolbox abstractions.                 |

### Requirements

*   **MATLAB** R2015b or later.
*   **LTE Toolbox**.

To verify LTE Toolbox installation, type `ver` at the MATLAB command prompt and look for "LTE Toolbox".

### Usage

To use this implementation, first ensure the `lte tool` directory is added to your MATLAB path:
```matlab
>> addpath('./lte tool');
```

1.  **Interactive Visualization Demo (`lte_tool_demo.m`):**
    *   Run the main demo to visualize transmitted/received signals:
        ```matlab
        >> lte_tool_params;  % Load parameters
        >> lte_tool_demo;     % Run demo
        ```
    *   This will generate LTE downlink waveforms, simulate channel effects (fading + AWGN), display signal spectra and constellations, and show real-time BER measurement.

2.  **BER Performance Testing (`lte_tool_ber_test.m`):**
    *   Run comprehensive BER tests across SNR values:
        ```matlab
        >> lte_tool_params;       % Load parameters
        >> lte_tool_ber_test;     % Run BER tests
        ```
    *   This will test BER across multiple SNR values (configurable in `lte_tool_params.m`), generate BER vs SNR plots, show CRC failure rates, and measure performance for different modulation schemes.

### Customizing Parameters

Edit `lte_tool_params.m` to change:

*   **Channel bandwidth**: `enb.NDLRB` (e.g., 6, 15, 25, 50, 75, 100 RBs)
*   **Modulation scheme**: `pdsch.Modulation` ('QPSK', '16QAM', '64QAM', '256QAM')
*   **SNR values**: `snrValues` array
*   **Coding rate**: `cRate`
*   **Channel model**: `chanMdl`, `delayProfile`, `maxDoppler`
*   **Stopping criteria**: `maxNumErrs`, `maxNumBits`

### Mapping Between Custom and LTE Toolbox Functions

| Custom Function          | LTE Toolbox Equivalent              | Description                  |
| :----------------------- | :---------------------------------- | :--------------------------- |
| `lteTbChannelCoding()`   | `lteDLSCH()`                        | DL-SCH encoding              |
| `lteTbChannelDecoding()` | `lteDLSCHDecode()`                  | DL-SCH decoding              |
| custom PDSCH processing  | `ltePDSCH()`                        | PDSCH symbol generation      |
| custom PDSCH decode      | `ltePDSCHDecode()`                  | PDSCH decoding               |
| `OFDMTx()` / `OFDMRx()`  | `lteOFDMModulate()` / `lteOFDMDemodulate()` | OFDM modulation/demodulation |
| `ChanEstimate()`         | `lteDLChannelEstimate()`            | Channel estimation           |
| `Equalizer()`            | Built into `ltePDSCHDecode()`       | Equalization                 |
| `Modulator()`            | `lteSymbolModulate()`               | Symbol modulation            |
| `DemodulatorSoft()`      | Built into `ltePDSCHDecode()`       | Soft demodulation            |
| `CSRgenerator()`         | `lteCellRS()`                       | Cell-specific reference signals |
| `lteScramble()` / `lteDescramble()` | Built into toolbox functions | Scrambling                   |

### Key LTE Toolbox Functions Used

1.  **`lteRMCDL`**: Creates Reference Measurement Channel (RMC) configuration.
2.  **`lteDLSCH`**: Performs DL-SCH encoding (CRC, turbo coding, rate matching).
3.  **`lteDLSCHDecode`**: Performs DL-SCH decoding.
4.  **`ltePDSCH`**: Generates PDSCH symbols.
5.  **`ltePDSCHDecode`**: Decodes PDSCH with channel estimation and equalization.
6.  **`lteOFDMModulate` / `lteOFDMDemodulate`**: OFDM processing.
7.  **`lteDLChannelEstimate`**: Channel estimation using reference signals.
8.  **`lteCellRS`**: Generate cell-specific reference signals.

### Limitations

This refactored implementation:

*   Focuses on **SISO only** (Transmission Mode 1).
*   Uses **single cell-specific reference signal** pattern.
*   Does not include **hybrid-ARQ** functionality.
*   Assumes **perfect synchronization** (no timing offset).
*   Does not model **frequency offset** or phase noise.

For more advanced features (MIMO, CA, CoMP, etc.), consult the LTE Toolbox documentation.

---

This `GEMINI.md` serves as instructional context for future interactions with this MATLAB-based LTE SISO simulation project, covering both the custom and LTE Toolbox implementations.
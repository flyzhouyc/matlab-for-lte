# Repository Guidelines

## Project Structure
- `SISO/`: single-antenna LTE simulations.
  - `SISO/lte tool/`: LTE Toolbox-based SISO implementation (`lte_tool_*.m`).
  - Other `.m` files in `SISO/` are the original/custom educational implementation.
- `SIMO/`: multi-receive-antenna experiments.
- `ChannelModeling/`: channel model utilities and examples.
- `backup/`: archived snapshots.

## Setup & Running
- Requires MATLAB plus Communications Toolbox; `SISO/lte tool/` additionally requires **LTE Toolbox**.
- Add paths (example from repo root):
  - MATLAB: `addpath(genpath(pwd))`
  - Or just LTE tool: `addpath('SISO/lte tool')`

## Common Commands
- Run the LTE Toolbox demo (plots/visualizations): `cd('SISO/lte tool'); lte_tool_demo`
- Run BER sweep: `cd('SISO/lte tool'); lte_tool_ber_test`
- Run unit tests: `runtests('SISO/lte tool/lte_tool_tests.m')`
- Batch mode (CI/local): `matlab -batch "addpath(genpath(pwd)); runtests('SISO/lte tool/lte_tool_tests.m');"`

## Coding Style & Naming
- MATLAB style: 4-space indentation, descriptive variable names, and vectorized operations where practical.
- Naming: functions/scripts use `lower_snake_case` with `lte_tool_` prefix (e.g., `lte_tool_step.m`).
- Prefer functions over scripts for reusable logic; keep scripts as entry points only.

## Testing Guidelines
- Tests use `matlab.unittest` (`SISO/lte tool/lte_tool_tests.m`).
- Add new tests for bug fixes and edge cases (invalid configs, channel string parsing, determinism with fixed seeds).

## Commits & Pull Requests
- Git history is mixed (short imperative English and occasional non-English messages). For new work, use short imperative subjects with scope when useful (e.g., `SISO: fix BER loop termination`).
- PRs should include: a brief description, MATLAB/toolbox versions tested, and screenshots for visualization changes.

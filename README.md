# NatComms 2023 Agency fMRI Pipeline

MATLAB analysis pipeline for:

> Karakose-Akbiyik, S., Caramazza, A., & Wurm, M.F. (2023). A shared neural code for the physics of actions and object events. *Nature Communications*, 14(1), 3316. https://doi.org/10.1038/s41467-023-39062-8

**Data:** https://osf.io/h4mtp/

## Overview

Two fMRI sessions (video and sentence), 25 participants. Conditions: 12 action conditions (agent animacy × recipient animacy × action type: hit / jump-over / pass-by) + 1 catch trial condition.

Analyses include MVPA searchlight decoding, GLM-based RSA searchlight, univariate contrasts, and ROI analyses.

## Requirements

- [BrainVoyager QX](https://www.brainvoyager.com/) — preprocessing, GLM, file I/O
- [CoSMoMVPA](https://www.cosmomvpa.org/) — MVPA and RSA searchlight
- [NeuroElf](https://neuroelf.net/) — BrainVoyager file I/O from MATLAB
- [libsvm](https://www.csie.ntu.edu.tw/~cjlin/libsvm/) — SVM classifier

## Getting started

1. Set all paths in `config.m` before running anything
2. Run sections of `analysis_pipeline.m` sequentially

## Attribution

Parts of this pipeline are adapted from code by Angelika Lingnau and Moritz Wurm.

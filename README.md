# Electro-Physiology analysis

The purpose of this code is to analyze electro-physiology signals (XXX) and 
identify features of biological significance.

## Requirements

  - MATLAB (tested with 2014b)
  - MATLAB Curve Fitting 

## Installation

Dowload and unzip into directory of choice, then add that path to MATLAB.

## Running

Run `AutomaticEPanalysis.m` to analyze a single file. It will prompt for a tab-separated file (by default it expects a file with the `.atf` extension) containing timestamps in the first column and measurements for different sweeps in the remaining columns.

Run `AutomaticEPanalysis_multipleFiles.m` to analyze multiple files in a directory. All files are expected be `.atf` files.

## Outputs

The scripts generate an HTML report for each analyzed file. 
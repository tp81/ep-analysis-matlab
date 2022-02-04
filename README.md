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

## Acknowledgment and authorship

This code was developed by Thomas Pengo (U of Minnesota Informatics 
Institute, tpengo@umn.edu) for Prof. Susan Keirstead (U of Minnesota Stem Cell Institute).



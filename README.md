# Electro-Physiology analysis

The purpose of this code is to analyze electro-physiology signals and 
identify features of biological significance.

## Requirements

  - MATLAB (tested with 2014b)
  - MATLAB Curve Fitting 

## Installation

Dowload and unzip into directory of choice, then add that path to MATLAB.

For example, if you unzipped into `C:\ep-analysis-matlab` then:

```MATLAB
>> addpath('C:\ep-analysis-matlab');
```

## Running

Run `AutomaticEPanalysis.m` to analyze a single file. It will prompt for a tab-separated file (by default it expects a file with the `.atf` extension) containing timestamps in the first column and measurements for different sweeps in the remaining columns.

```MATLAB
>> AutomaticEPanalysis
```

Run `AutomaticEPanalysis_multipleFiles.m` to analyze multiple files in a directory. All files are expected be `.atf` files.

```MATLAB
>> AutomaticEPanalysis_multipleFiles
```


## Outputs

The scripts generate an HTML report for each analyzed file. The report will be in the same directory if using the single-file version, or in the output directory if using the multiple-file version.


## Structure

Here is a short summary of the relationship between the different files. See the Running section.

Both scripts write to the global variable `infile` and then call the `publish` function in MATLAB passing the name of the `EPanalysis.m` script. The global variable is the simplest way I am aware of to pass parameters to a script that will be `publish`ed.

<img src="./doc/modules.drawio.svg">

## Acknowledgment and authorship

This code was developed by Thomas Pengo (U of Minnesota Informatics 
Institute, tpengo@umn.edu) for Prof. Susan Keirstead (U of Minnesota Stem Cell Institute).



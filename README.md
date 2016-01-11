#Timbre Toolbox (TT) Tutorial

##Obtaining the TT

Releases:
https://github.com/mondaugen/timbretoolbox/releases

Development versions:
https://github.com/mondaugen/timbretoolbox

##How to use

Download a release or development version.

Decompress the archive to some location.

Add this location to path, e.g., by using the MATLAB browser, left-clicking on the extracted directory and then right-clicking on it (now that it is highlighted) and finally clicking Add to Path -> Selected Folders and Subfolders.

A quick way to do this using the command-line is:

```
>> addpath(genpath('/path/to/timbretoolbox'));
```

Compile the mex files. Currently there is only one and must be compiled as
follows:

```
>> mex ./classes/@cERBRep/private/rsmooth.c -outdir ./classes/@cERBRep/private/
```

Make another directory (not inside the “timbretoolbox…” directory) that you will do work in.

Copy the scripts from “timbretoolbox/doc/“ to this directory, or simply use them as a guide for writing new scripts.

NB: If you run the “multifile” example, be sure to create the “sounds” and “results” directories and specify the appropriate paths (if they differ from what’s already provided). After creating these directories, add these to the MATLAB path the same way you added the TT to the path.

Run your script either by opening the script and clicking run, or doing
```
>> run script_name
```
in the MATLAB prompt.

## Notes on the example

To view the results, you have to load the structures into memory by doing
```
load(‘path/to/data’);
```
There are three different files saved, with different endings to describe each one:

...desc.mat :
Stores the descriptors calculated from each representation (e.g., spectral centroid).
...rep.mat :
Stores the representations (e.g., STFT, Harmonic, etc.).
...stat.mat :
Stores statistics calculated on the time-series in _desc.mat (e.g., mean, median, etc.).

So in this example, to see the statistics calculated from the file “026_ped_s_mono.wav”, we would do
```
load('results/026_ped_s_mono_stat.mat');
```
and the structure will show up in MATAB’s “Workspace”.

##Reporting bugs

If you find that something is not working properly, please report it here:

https://github.com/mondaugen/timbretoolbox/issues

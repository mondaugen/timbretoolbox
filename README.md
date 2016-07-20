#Timbre Toolbox (TT) Tutorial

##Obtaining the TT

Development versions:
`https://github.com/mondaugen/timbretoolbox`

##How to use

Download a development version either using git or clicking on the "Download
ZIP" link.

Decompress the archive to some location. For this documentation we will assume
you have decompressed it to a folder named "timbretoolbox".

Add this location to path, e.g., by using the MATLAB browser, left-clicking on
the extracted directory and then right-clicking on it (now that it is
highlighted) and finally clicking Add to Path -> Selected Folders and
Subfolders.

A quick way to do this using the command-line is:

```
>> addpath(genpath('/path/to/timbretoolbox'));
```

Compile the mex files. Currently there is only one and must be compiled as
follows:

```
>> mex ./classes/@cERBRep/private/rsmooth.c -outdir ./classes/@cERBRep/private/
```

Make another directory (not inside the `timbretoolbox…` directory) that you will
do work in.

Copy the scripts from `timbretoolbox/doc/` to this directory, or simply use them
as a guide for writing new scripts.

The reason we suggest making a new directory is so when you download new
versions of the timbretoolbox, you can simply replace the "timbretoolbox" folder
with the new version and not lose your scripts.

NB: If you run the “multifile” example, be sure to create the “sounds” and
“results” directories and specify the appropriate paths (if they differ from
what’s already provided). After creating these directories, add these to the
MATLAB path the same way you added the TT to the path.

Run your script either by opening the script and clicking run, or doing
```
>> run script_name
```
in the MATLAB prompt.

## Notes on using with a Git repository

A convenient way to incorporate the newest improvements and bug-fixes to your
workflow using the TT is to use version control. Fans of the command line can
simply clone as follows

```
cd /some/directory/where/you/work
git clone https://github.com/mondaugen/timbretoolbox
```

This will create a folder called "timbretoolbox" and will contain the latest
version of the master branch of the repository. When you want the latest changes
to the repository, simply do

```
cd /some/directory/where/you/work/timbretoolbox
git pull
```
Those who prefer the MATLAB interface to Git can do as follows (The following
has only been tested on MATLAB versions R2015a-b but will probably work in other
later versions).

In MATLAB
- Navigate to `/some/directory/where/you/work`.
- Right-click on some white space in the "Current Folder" pane.
- Select "Source Control -> Manage Files".
A dialog with title "Manage Files Using Source Control" will appear.
- From the drop-down menu next to "Source control integration:" select "Git".
- In the textbox next to "Repository path:" type `https://github.com/mondaugen/timbretoolbox`.
- In the textbox next to "Sandbox:" type
  `/some/directory/where/you/work/timbretoolbox`.
- Then click "Retrieve". It will probably ask if you want to create the
  `timbretoolbox` folder, click "Yes".
- It should retrieve the files and the "Current Folder" pane should be in the
  timbretoolbox folder.

After doing this, you will have the latest version of the master branch of the
repository. To get updates to the repository (if they are available) do as
follows:

With "Current Folder" located at `/some/directory/where/you/work/timbretoolbox`,
- right-click on some white space in the "Current Folder" pane.
- Select "Source control -> Fetch". This will obtain the latest changes to the
  repository. As far as I can tell, there is no visual feedback when this
  happens.
- Then right-click on some white space again and select "Source Control ->
  Manage Branches".
A dialog with title "Manage Branches" will appear.
- In the drop-down menu next to "Branches:", select the branch
  `refs/remotes/origin/master`
- Then click on "Merge".
- Close the dialog.
You should now have the latest changes from the repository at
`https://github.com/mondaugen/timbretoolbox`.

## Notes on the examples

See `doc/get_descriptors_example.m`, `doc/get_descriptors_multifile_example.m`, and
`doc/get_descriptors_global_example.m` for examples of scripts that compute
descriptors.

To view the results, you have to load the structures into memory by doing
```
>> load(‘path/to/data’);
```
There are three different files saved, with different endings to describe each
one:

- ...desc.mat : Stores the descriptors calculated from each representation
  (e.g., spectral centroid).
- ...rep.mat : Stores the representations (e.g., STFT, Harmonic, etc.).
- ...stat.mat : Stores statistics calculated on the time-series in \*desc.mat
  (e.g., mean, median, etc.).

So in this example, to see the statistics calculated from the file
`026_ped_s_mono.wav`, we would do
```
>> load('results/026_ped_s_mono_stat.mat');
```
and the structure will show up in MATLAB’s “Workspace”.

## Notes on the graphical user interface (GUI)

A simple GUI is available in scripts/get_descriptors_gui.m.
Run this by executing:
```
>> get_descriptors_gui()
```
from the MATLAB prompt.

Help is available in the GUI, or by typing:
```
>> help get_descriptors_gui
```

##Reporting bugs

If you find that something is not working properly, please report it here:

`https://github.com/mondaugen/timbretoolbox/issues`

% function [FILE_s, ALLDESC_s, ALLTM_s] = Gtimbredescriptor(w_Directory, EXT)
%
% DESCRIPTION:
% ============
% compute the whole set of timbre related audio features for all the sound files
% contained in a given FOLDER
%
% INPUTS:
% =======
% - w_Directory	: define the folder where the files are located in
% - EXT			: define the file extension of the audio file (.wav, .aiff)
%
% OUTPUTS:
% ========
% - FILE_s		: list of audio files that have been processed
% - ALLDESC_s	: structure containing the global and time-variable audio features
% - ALLTM_s		: structure containing the global and temporal-models of the audio features
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%
% version 1.0
%


function [FILE_s, ALLDESC_s, ALLTM_s] = Gtimbredescriptor(w_Directory, EXT)

if ~nargin
	% === DEFINE THE FOLDER WHERE THE FILES ARE LOCATED IN AND THEIR EXTENSIONS
	%w_Directory = ['./soundexample/Lakatos.McGill/'];			EXT = '.aiff';
	w_Directory = ['./soundexample/GreyWAV/'];					EXT = '.wav';
end

% ====================
% === Add toolbox folders to Matlab path
ROOT_DIR = './';
addpath([ROOT_DIR]);
addpath([ROOT_DIR filesep 'classes']);
addpath([ROOT_DIR filesep '_tools']);
addpath([ROOT_DIR filesep '_tools_sf']);

% ====================
% === PARAMETERS
do_s.b_TEE				= 1;    % descriptors from the Temporal Energy Envelope
do_s.b_STFTmag			= 1;    % descriptors from the STFT magnitude
do_s.b_STFTpow			= 1;    % descriptors from the STFT power
do_s.b_Harmonic			= 1;	% descriptors from Harmonic Sinusoidal Modeling representation
do_s.b_ERBfft			= 1;    % descriptors from ERB representation (ERB being computed using FFT)
do_s.b_ERBgam			= 1;    % descriptors from ERB representation (ERB being computed using Gamma Tone Filter)

% Time domain descriptors configuration
% === defines the number of auto-correlation coefficients that will be used
config_s.TEE.xcorr_nb_coeff = 12; 
% Harmonic descriptors configuration
% === defines the threshold [0,1] below which harmonic-features are not computed
config_s.Harmonic.threshold_harmo = 0.3;
% === defines the number of harmonics that will be extracted
config_s.Harmonic.nb_harmo = 20;

% ====================
% === Get list of input files
[FILE_s]	= Gget_filelist(w_Directory, EXT);

% ======================
% ===   MAIN LOOP
for num_file = 1:length(FILE_s)
	fprintf(1, '\nProcessing file %2d/%2d: %s\n', num_file, length(FILE_s), FILE_s(num_file).fullpath);
	fprintf(1, '=======================================\n');
	ALLDESC_s{num_file}	= Gget_desc_onefile(FILE_s(num_file).fullpath, do_s, config_s);
	ALLTM_s{num_file}	= Gget_temporalmodeling_onefile(ALLDESC_s{num_file});
	Gwrite_resultfile([FILE_s(num_file).fullpath '_desc.txt'], ALLTM_s{num_file});
end


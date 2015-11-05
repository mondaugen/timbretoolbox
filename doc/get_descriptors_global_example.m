% This is an example of how to compute decscriptors by carrying out one analysis on
% an entire soundfile.
% The maximum file size for a machine with 8 GB of ram is about 5 seconds, but
% this depends on the hop size, windowing, sample rate and other parameters.
% Gget_desc_onefile.m to see the pros and cons of this method.
% To run this example, make sure the path to this file is included in the MATLAB
% path and do
%
% >> run 'get_descriptors_global_example.m'
%
% In a MATLAB prompt.

filename='example_short.wav';

disp(sprintf('Filename: %s\n',filename));

config_s = struct();

% Parameters passed to function that loads sound file
config_s.SOUND = struct();
% The following parameters are mandatory if a raw file is read in 
config_s.SOUND.w_Format = 'double';
config_s.SOUND.i_Channels = 2;
config_s.SOUND.f_Fs = 48000;
config_s.SOUND.i_Samples = 480001;
% To see what other parameters can be specified, see cSound.m

% Parameters passed to function that computes time-domain descriptors
config_s.TEE = struct();
% example of how to specify parameter
config_s.TEE.xcorr_nb_coeff = 12;
% See @cSound/FCalcDescr.m to see parameters that can be specified.

% Parameters passed to function that computes spectrogram-based descriptors
config_s.STFTmag = struct();	
% example of how to specify parameter
config_s.STFTmag.i_FFTSize = 4096;
% The parameter w_DistType will be overridden, so specifying it is futile.
% See @cFFTRep/cFFTRep.m to see parameters that can be specified.

% Parameters passed to function that computes spectrogram-based descriptors
config_s.STFTpow = struct();	
% example of how to specify parameter
config_s.STFTpow.i_FFTSize = 4096;
% The parameter w_DistType will be overridden, so specifying it is futile.
% See @cFFTRep/cFFTRep.m to see parameters that can be specified.

% Parameters passed to function that computes harmonic-analysis-based descriptors
config_s.Harmonic = struct();
% examples of how to specify parameter
config_s.Harmonic.threshold_harmo = 0.2;
config_s.Harmonic.w_WinType = 'hamming';
% See @cHarmRep/cHarmRep.m to see parameters that can be specified.

% Parameters passed to function
config_s.ERBfft = struct();	
% example of how to specify parameter
config_s.ERBfft.f_Exp = 1/8;
% The parameter w_Method will be overridden, so specifying it here is futile.
% See @cERBRep/cERBRep.m to see parameters that can be specified.

config_s.ERBgam = struct();
% example of how to specify parameter
config_s.ERBgam.f_Exp = 1/8;
% The parameter w_Method will be overridden, so specifying it here is futile.
% See @cERBRep/cERBRep.m to see parameters that can be specified.

do_s = struct();

% Specifiy field as 1 if computation should be carried out, 0 if not.
% Here we compute all descriptors
do_s.b_TEE = 1;
do_s.b_STFTmag = 1;
do_s.b_STFTpow = 1;
do_s.b_Harmonic = 1;
do_s.b_ERBfft = 1;
do_s.b_ERBgam = 1;

% Compute descriptors and representations
[ALLDESC_s, ALLREP_s] = Gget_desc_onefile(filename,do_s,config_s,0);

% Example of how to plot some representation information
% Here we plot the partials discovered by the harmonic analysis
d = struct(ALLREP_s.Harmonic);
figure(1);
hold on;
for n=(1:length(d.PartTrax_s)),
    scatter((n-1)*ones(length(d.PartTrax_s(n).f_Freq_v),1),...
        d.PartTrax_s(n).f_Freq_v,...
        10,...
        d.PartTrax_s(n).f_Ampl_v);
end;
hold off;
title('Harmonic analysis partials');
ylabel('Normalized frequency (2\pi Radians)');
xlabel('Frame index (starting at 0)');

% Example of how to plot some descriptor information
% Here we plot the spectral spread
figure(2);
plot((1:length(ALLDESC_s.STFTpow.SpecSpread))-1,ALLDESC_s.STFTpow.SpecSpread);
title('Spectral spread (from FFT Representation)');
ylabel('Spectral spread');
xlabel('Frame index (starting at 0)');

% Compute other statistics from descriptors (median, inter-quartile range)
ALLDESCSTATS_s=Gget_statistics(ALLDESC_s);

% function [c] = cHarmRep(Snd_o, config_s)
%
% DESCRIPTION:
% ============ 
% Harmonic Sinusoidal Model representation
%
% INPUTS:
% =======
% (1) cSound object (mandatory)
% (2) configuration structure (optional)
% The configuration structure contains the following fields. If any of the
% fields are not specified, they are calculated or given default values.
%   threshold_harmo     -- The fundamental frequency estimator outputs strengths
%                          for each pitch estimate (the certainty of the
%                          estimate). If at least one estimate is greater than
%                          this threshold then analysis continues on the sound,
%                          otherwise empty vectors are output (the sound is not
%                          analysed).
%   nb_harmo            -- The number of partials used in the harmonic
%                          representation.
%   f_WinSize_sec       -- The length of the analysis window used in calculating
%                          the spectrogram.
%   F_HopSize_sec       -- The amount the analysis window advances between two
%                          analyses when calculating the spectrogram.
%   i_FFTSize           -- The length of the FFT in samples. If this is not
%                          specified the default is at least 4 times the window
%                          size in samples. This is to give bettwe frequency
%                          resolution for the harmonic search. Just to give you
%                          an idea of an FFT size to choose.
%   w_WinType           -- A string specifying a window to use. This must be a
%                          function known to MATLAB that takes an integer
%                          indicating the length of the window vector to return,
%                          e.g., "hanning".
%   f_Win_v             -- If w_WinType is not specified, a vector representing
%                          a window can be passed. This must be the same length
%                          as the sample rate of the sound being analysed
%                          multiplied by f_WinSize_sec, otherwise an error will
%                          be raised.
%
% OUTPUTS:
% ========
% (1) Harmo object
%
%  NOTE: The spectrogram contained in this output is of a signal that has been
%  Hilbert transformed before carrying out the spectrogram analysis. This means
%  that the total power of one frame (after dividing by the equivalent noise
%  bandwidth of the window, a field of this class) will be 2*V + sum(A_i ^ 2) where
%  V is the variance of the noise present in the signal (not explained by the
%  harmonics) and A_i are the amplitudes of the sinusoids (harmonics).
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [c] = cHarmRep(Snd_o, config_s)


% === get input sig. 
c.f_Sig_v	= FGetSignal(Snd_o);
c.sr_hz		= FGetSampRate(Snd_o);
c.config_s	= config_s;

[c.f_F0_v, c.PartTrax_s, c.f_SupX_v, c.f_SupY_v, c.f_DistrPts_m, c.f_ENBW] ...
    = Fanalyseharmo(c.f_Sig_v, c.sr_hz, c.config_s);


% === Build class
c = class(c, 'cHarmRep'); % inherit generic distribution properties

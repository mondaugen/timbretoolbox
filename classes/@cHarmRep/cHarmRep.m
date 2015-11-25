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
%                          size in samples. This is to give better frequency
%                          resolution for the harmonic search.
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
% i_IncToNext   - If the descriptors are being calculated in chunks, how many
%                 samples the read head should be advanced to have the chunk
%                 start where this analysis left off. For example if the chunk
%                 size is 16 samples, the hop size is 2 samples and the window
%                 size is 5 samples, the highest index attained where the window
%                 still fits within the chunk is 11. So the next hop we want to
%                 compute is at index 13 but before we can do that, we must
%                 read in more samples. Before reading in more samples,
%                 increment the read head by 12 to place the beginning of the
%                 chunk where the next hop should land.
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

function [c] = cHarmRep(Snd_o, config_s, f_Pad_v)


% === get input sig. 
c.config_s	= config_s;

[c.f_F0_v, c.PartTrax_s, d.f_SupX_v, d.f_SupY_v, d.f_DistrPts_m, d.f_ENBW, ...
    d.f_SampRateX, d.f_SampRateY, c.config_s, i_ForwardWinSize] = ...
        Fanalyseharmo(FGetSignal(Snd_o), FGetSampRate(Snd_o), c.config_s, ...
            f_Pad_v);

c.i_Len=FGetLen(Snd_o);
c.i_IncToNext=(floor((c.i_Len - i_ForwardWinSize)/c.config_s.i_HopSize + ...
    1)*c.config_s.i_HopSize);

% c2xDistr fields
d.i_SizeX=size(d.f_DistrPts_m,2);
d.i_SizeY=size(d.f_DistrPts_m,1);

% === Build class
c = class(c,'cHarmRep',c2xDistr(d)); % inherit generic distribution properties

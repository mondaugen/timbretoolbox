% function [c] = cFFTRep(varargin)
%
% DESCRIPTION:
% ============ 
% Short-time Fourier transform representation
%
% INPUTS:
% =======
% (1) cSound object (mandatory)
% (2) configuration structure (optional)
% The configuration structure contains the following fields. If any of the
% fields are not specified, they are calculated or given default values.
%   i_FFTSize     -- The size of the FFT performed on each frame. This should be
%                    greater than or equal to the window size in samples because
%                    the STFT algorithm will not window and fold the time-domain
%                    signal appropriately if the FFT size is shorter than the
%                    window as described in Portnoff (1980).
%   f_WinSize_sec -- The size of the window in seconds.
%   i_WinSize     -- The size of the window in samples. If both the size in
%                    samples and seconds are specified, seconds takes precident.
%   f_HopSize_sec -- The hop size in seconds.
%   i_HopSize     -- The hop size in samples. The hop size in seconds takes
%                    precident.
%   w_WinType     -- The kind of window used. This can be the name of any
%                    function that accepts an integer argument N and returns a
%                    vector of length N containing the window.
%   f_Win_v       -- A vector containing a window. If this is specified,
%                    w_WinType will not be used to calculate a window. Note that
%                    it is not checked that the length of this vector be the
%                    same as i_WinSize!
%   f_SampRate_x  -- If not specified, this is the sample rate divided by the
%                    hop size in samples.
%   f_BinSize     -- If not specified this is the sample rate divided by the FFT
%                    size in samples.
%   f_SampRate_y  -- If not specified this is the reciprocal of the bin size.
%   w_DistType    -- The type of spectrum computed. By default this is "pow" and
%                    computes the power spectrum. Other possible values are:
%                       "pow"           -- Computes the power spectrum. The
%                                          spectrum is divided by two times the
%                                          FFT size, the sum of the squared
%                                          values of the window and all values
%                                          except for the first value are
%                                          divided by 2 to remove energy
%                                          contributed by the Hilbert transform.
%                       "mag"           -- Computes the magnitude spectrum.
%                                          Spectrum is scaled as for "pow"
%                                          except that it is instread divided by
%                                          the sum of the unsquared values of
%                                          the window.
%                       "complex"       -- Computes the complex spectrum, which
%                                          is then scaled the same way as for
%                                          "mag".
%                       "mag_noscaling" -- Computes the magnitude spectrum
%                                          without any of the scaling.
% The soundfile is analysed using the short-time Fourier transform of the
% analytic signal, which is the original signal transformed using the Hilbert
% transform.
%
% OUTPUTS:
% ========
% (1) FFTRep object
% %%% NEEDS REVISION
% %The result is a cFFTRep object which contains, through class inheritance of a
% %c2xDistr object,
% %  a matrix f_DistrPts_m whose columns are the FFT frames corresponding to the
% %                        sample points and whose rows are the spectrum values
% %                        from 0 to half the sample rate, 
% %  a vector d.f_SupX_v   containing the seconds to which the centre of each
% %                        analysis window refers, and 
% %  a vector d.f_SupY_v   containing the normalized frequencies to which each
% %                        row corresponds, up to half the sampling rate.
% %This means that the columns of this matrix are of length i_FFTSize/2.
% %%%
% i_IncToNext   - If the descriptors are being calculated in chunks, how many
%                 samples the read head should be advanced to have the chunk
%                 start where this analysis left off. For example if the chunk
%                 size is 16 samples, the hop size is 2 samples and the window
%                 size is 5 samples, the highest index attained where the window
%                 still fits within the chunk is 11. So the next hop we want to
%                 compute is at index 13 but before we can do that, we must read
%                 in more samples. Before reading in more samples, increment the
%                 read head by 12 to place the beginning of the chunk where the
%                 next hop should land.
% 
%
% Member functions
% ----------------
% FGetSampleRate(c)
%
% See also cERBRep
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [c] = cFFTRep(varargin)

% === Handle input args
if (nargin == 1)
        oSnd = varargin{1};        
        % === use default settings
        config_s=cFFTRep_FGetDefaultConfig();
        config_s.f_sr_hz=FGetSampRate(oSnd);
end
if (nargin > 1)
        % === use input config structure
        oSnd        = varargin{1};
        config_s    = varargin{2};
        % === check completness of config.

        if ~isfield(config_s,'f_sr_hz'),
            config_s.f_sr_hz = FGetSampRate(oSnd);
        end;

        % If window size in samples specified, calculate the window size in
        % seconds
        if isfield(config_s,'i_WinSize'),
            config_s.f_WinSize_sec = config_s.i_WinSize/config_s.f_sr_hz;
        end;
        % If window size in seconds specified, calculate the window size in
        % samples. Notice that you can't specify both the window size in
        % seconds and in samples, so seconds takes precident (and replaces i_WinSize).
        if isfield(config_s,'f_WinSize_sec'),
            config_s.i_WinSize = round(config_s.f_WinSize_sec*config_s.f_sr_hz);
        end;
        % If hop size in samples specified, calculate the window size in
        % seconds
        if isfield(config_s,'i_HopSize'),
            config_s.f_HopSize_sec = config_s.i_HopSize/config_s.f_sr_hz;
        end;
        % If window size in seconds specified, calculate the window size in
        % samples. Notice that you can't specify both the window size in
        % seconds and in samples, so seconds takes precident (and replaces i_WinSize).
        if isfield(config_s,'f_HopSize_sec'),
            config_s.i_HopSize = round(config_s.f_HopSize_sec*config_s.f_sr_hz);
        end;
        
         % Default window size 23.2 ms
        if ~isfield( config_s, 'f_WinSize_sec'), 
            config_s.f_WinSize_sec	= 0.0232;
        end;
        % Default hop size 5.8 ms
        if ~isfield( config_s, 'f_HopSize_sec'),
            config_s.f_HopSize_sec	= 0.0058;
        end;
        if ~isfield( config_s, 'i_WinSize'),
            config_s.i_WinSize	= round(config_s.f_WinSize_sec*config_s.f_sr_hz);
        end;
        % Default hop size ends up being 256 samples
        if ~isfield( config_s, 'i_HopSize'),
            config_s.i_HopSize = round(config_s.f_HopSize_sec*config_s.f_sr_hz);
        end;		
		
        if ~isfield( config_s, 'i_FFTSize'), config_s.i_FFTSize = 2^nextpow2(config_s.i_WinSize); end;
        if config_s.i_FFTSize < config_s.i_WinSize,
            warning('The FFT size is less than the window size.');
        end;

        if ~isfield( config_s, 'w_WinType'),		config_s.w_WinType = 'hamming';	end;
		if ~isfield( config_s, 'f_Win_v'),
            config_s.f_Win_v = eval(sprintf('%s(%d)', config_s.w_WinType, config_s.i_WinSize));
        end;
        if ~isfield( config_s, 'f_SampRateX'),		config_s.f_SampRateX= config_s.f_sr_hz ./ config_s.i_HopSize; end;
        if ~isfield( config_s, 'f_BinSize'),		config_s.f_BinSize	= config_s.f_sr_hz ./ config_s.i_FFTSize; end;
        if ~isfield( config_s, 'f_SampRateY'),		config_s.f_SampRateY= config_s.i_FFTSize ./ config_s.f_sr_hz; end;   
        if ~isfield( config_s, 'w_DistType')		config_s.w_DistType	= 'pow'; end;  
end
if (nargin > 2)
    f_Pad_v=varargin{3};
end

% === FFT specific elements
c.i_FFTSize	= config_s.i_FFTSize;
c.f_BinSize	= config_s.f_BinSize;
c.i_WinSize	= config_s.i_WinSize;
c.i_HopSize	= config_s.i_HopSize;
c.w_WinType	= config_s.w_WinType;
c.f_Win_v	= config_s.f_Win_v;

% If the window is centred at t, this is the starting index at which to
% look up the signal which you want to multiply by the window. It is a
% negative number because (almost) half of the window will be before time t
% and half after. In fact, if the length of the window N is an even number,
% it is set up so this number equals -1*(N/2 - 1). If the length of the window
% is odd, this number equals -1*(N-1)/2.
iLHWinSize = ceil(-(c.i_WinSize-1)/2);
% This is the last index at which to look up signal values and is equal to
% (N-1)/2 if the length N of the window is odd and N/2 if the length of the
% window is even. This means that in the even case, the window has an
% unequal number of past and future values, i.e., time t is not the centre
% of the window, but slightly to the left of the centre of the window
% (before it).
iRHWinSize = ceil((c.i_WinSize-1)/2);

% === 2x distribution elements
d.f_SampRateX = config_s.f_SampRateX;
d.f_SampRateY = config_s.f_SampRateY;

% === get input sig. (make analytic)
f_Sig_v = FGetSignal(oSnd);
c.i_Len=FGetLen(oSnd);
 
if (nargin > 2)
    [d.f_DistrPts_m, d.f_SupY_v, d.f_SupX_v, d.f_ENBW, i_ForwardWinSize] = FCalcSpectrogram(f_Sig_v, ...
        c.i_FFTSize, config_s.f_sr_hz, c.f_Win_v, c.i_WinSize - c.i_HopSize, ...
        config_s.w_DistType, f_Pad_v, 1);
else
    [d.f_DistrPts_m, d.f_SupY_v, d.f_SupX_v, d.f_ENBW, i_ForwardWinSize] = FCalcSpectrogram(f_Sig_v, ...
        c.i_FFTSize, config_s.f_sr_hz, c.f_Win_v, c.i_WinSize - c.i_HopSize, ...
        config_s.w_DistType,[],1);
end
c.i_IncToNext=(floor((c.i_Len - i_ForwardWinSize)/c.i_HopSize + 1)*c.i_HopSize);

% === support vectors            
d.i_SizeX	= size(d.f_DistrPts_m,2);
d.i_SizeY	= size(d.f_DistrPts_m,1);


% === Build class
c = class(c, 'cFFTRep', c2xDistr(d)); % inherit generic distribution properties

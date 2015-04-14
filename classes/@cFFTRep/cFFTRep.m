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
%
% OUTPUTS:
% ========
% (1) FFTRep object
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
switch nargin
    case 1
        oSnd = varargin{1};        
        % === use default settings
        config_s.i_FFTSize		= 2048;
        config_s.f_WinSize_sec	= 1025/44100;	% === is 0.0232s at 44100Hz
        config_s.f_HopSize_sec	= 256/44100;	% === is 0.0058s at 44100Hz

		config_s.i_WinSize		= round(config_s.f_WinSize_sec*FGetSampRate(oSnd));
		config_s.i_HopSize		= round(config_s.f_HopSize_sec*FGetSampRate(oSnd));
		config_s.i_FFTSize		= 2^nextpow2(config_s.i_WinSize);

        config_s.w_WinType		= 'hamming';
        config_s.f_Win_v		= hamming( config_s.i_WinSize );
        config_s.f_SampRateX	= FGetSampRate(oSnd) ./ config_s.i_HopSize;
        config_s.f_BinSize		= FGetSampRate(oSnd) ./ config_s.i_FFTSize;
        config_s.f_SampRateY	= config_s.i_FFTSize ./ FGetSampRate(oSnd);	% = 1 / config_s.f_BinSize;
        config_s.w_DistType		= 'pow';

    case 2
        % === use input config structure
        oSnd        = varargin{1};
        config_s    = varargin{2};
        % === check completness of config.

        % If window size in samples specified, calculate the window size in
        % seconds
        if isfield(config_s,'i_WinSize'),
            config_s.f_WinSize_sec = config_s.i_WinSize/FGetSampRate(oSnd);
        end;
        % If window size in seconds specified, calculate the window size in
        % samples. Notice that you can't specify both the window size in
        % seconds and in samples, so seconds takes precident (and replaces i_WinSize).
        if isfield(config_s,'f_WinSize_sec'),
            config_s.i_WinSize = round(config_s.f_WinSize_sec*FGetSampRate(oSnd));
        end;
        % If hop size in samples specified, calculate the window size in
        % seconds
        if isfield(config_s,'i_HopSize'),
            config_s.f_HopSize_sec = config_s.i_HopSize/FGetSampRate(oSnd);
        end;
        % If window size in seconds specified, calculate the window size in
        % samples. Notice that you can't specify both the window size in
        % seconds and in samples, so seconds takes precident (and replaces i_WinSize).
        if isfield(config_s,'f_HopSize_sec'),
            config_s.i_HopSize = round(config_s.f_HopSize_sec*FGetSampRate(oSnd));
        end;
        
         % Default window size ends up being 1025 samples
        if ~isfield( config_s, 'f_WinSize_sec'), 
            config_s.f_WinSize_sec	= 1025/FGetSampRate(oSnd);
        end;
        % Default hop size ends up being 256 samples
        if ~isfield( config_s, 'f_HopSize_sec'),
            config_s.f_HopSize_sec	= 256/FGetSampRate(oSnd);
        end;
        if ~isfield( config_s, 'i_WinSize'),
            config_s.i_WinSize	= round(config_s.f_WinSize_sec*FGetSampRate(oSnd));
        end;
        % Default hop size ends up being 256 samples
        if ~isfield( config_s, 'i_HopSize'),
            config_s.i_HopSize = round(config_s.f_HopSize_sec*FGetSampRate(oSnd));
        end;		
		
        if ~isfield( config_s, 'i_FFTSize'), config_s.i_FFTSize = 2^nextpow2(config_s.i_WinSize); end;
        if config_s.i_FFTSize < config_s.i_WinSize,
            warning('The FFT size is less than the window size.');
        end;

        if ~isfield( config_s, 'w_WinType'),		config_s.w_WinType = 'hamming';	end;
		if ~isfield( config_s, 'f_Win_v'),
            config_s.f_Win_v = eval(sprintf('%s(%d)', config_s.w_WinType, config_s.i_WinSize));
        end;
        if ~isfield( config_s, 'f_SampRateX'),		config_s.f_SampRateX= FGetSampRate(oSnd) ./ config_s.i_HopSize; end;
        if ~isfield( config_s, 'f_BinSize'),		config_s.f_BinSize	= FGetSampRate(oSnd) ./ config_s.i_FFTSize; end;
        if ~isfield( config_s, 'f_SampRateY'),		config_s.f_SampRateY= config_s.i_FFTSize ./ FGetSampRate(oSnd); end;   
        if ~isfield( config_s, 'w_DistType')		config_s.w_DistType	= 'pow'; end;  
                
    otherwise
        disp('Error: bad set of arguements to cFFTRep');
        %c = cFFTRep(zeros(1,10));
        exit(1);
end;

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
if isreal(f_Sig_v), f_Sig_v = hilbert(f_Sig_v); end

% === pre/post-pad signal
f_Sig_v = [zeros(-1*iLHWinSize,1); f_Sig_v; zeros(iRHWinSize,1)];
        
% === support vectors            
i_Len		= length(f_Sig_v);
i_Ind		= [-iLHWinSize+1 : c.i_HopSize : i_Len-iRHWinSize];
d.i_SizeX	= length(i_Ind);
d.i_SizeY	= c.i_FFTSize;
d.f_SupX_v	= [0:(d.i_SizeX-1)]./config_s.f_SampRateX;		% === X support (time)
d.f_SupY_v	= ([0:(d.i_SizeY-1)]./d.i_SizeY)';              % === Y support (normalized freq.)


% calc. windowed sig.
d.f_DistrPts_m = zeros(d.i_SizeY, d.i_SizeX);
for( i=1:d.i_SizeX )
    d.f_DistrPts_m(1:c.i_WinSize,i) = f_Sig_v(i_Ind(i)+iLHWinSize:i_Ind(i)+iRHWinSize) .* c.f_Win_v; 
end;

% === fft (cols of dist.)
% note that this divides by the window size

% compute FFT unless we want unprocessed data
if strcmp(config_s.w_DistType,'nofft')==0
    d.f_DistrPts_m = fft(d.f_DistrPts_m, c.i_FFTSize);
    if strcmp(config_s.w_DistType, 'complex')
        d.f_DistrPts_m			= 1/c.i_FFTSize .* d.f_DistrPts_m;
        d.f_DistrPts_m			= d.f_DistrPts_m ./ sum(c.f_Win_v .^2); % === remove window energy
        d.f_DistrPts_m(2:end)	= d.f_DistrPts_m(2:end) ./ 2;		% === remove added energy from hilbert x-form?
    elseif strcmp(config_s.w_DistType, 'pow') % === Power distribution
        d.f_DistrPts_m			= 1/c.i_FFTSize .* abs(d.f_DistrPts_m).^2;
        d.f_DistrPts_m			= d.f_DistrPts_m ./ sum(c.f_Win_v .^2); % === remove window energy
        d.f_DistrPts_m(2:end)	= d.f_DistrPts_m(2:end) ./ 2;		% === remove added energy from hilbert x-form?
    elseif strcmp(config_s.w_DistType, 'mag') % === Magnitude distribution
        d.f_DistrPts_m			= sqrt(1/c.i_FFTSize) .* abs(d.f_DistrPts_m);
        d.f_DistrPts_m			= d.f_DistrPts_m ./ sum(abs(c.f_Win_v));
        d.f_DistrPts_m(2:end)	= d.f_DistrPts_m(2:end) ./ 2;
    elseif strcmp(config_s.w_DistType, 'mag_noscaling')
        % magnitude distribution with no scaling
        d.f_DistrPts_m = abs(d.f_DistrPts_m);
    else % === Might want to add 'log' option as well (similar to IRCAM toolbox)
        disp('Error: unknown distribution type (options are: pow/mag)');
        exit(1);
    end;
end;

% === Build class
c = class(c, 'cFFTRep', c2xDistr(d)); % inherit generic distribution properties

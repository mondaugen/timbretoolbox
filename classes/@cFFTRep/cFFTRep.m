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
        if ~isfield( config_s, 'i_FFTSize'),		config_s.i_FFTSize		= 2048;			end;
        if ~isfield( config_s, 'i_WinSize'),		config_s.f_WinSize_sec	= 1025/44100;	end; % === is 0.0232s at 44100Hz
        if ~isfield( config_s, 'i_HopSize'),		config_s.f_HopSize_sec	= 256/44100;	end; % === is 0.0058s at 44100Hz
 
		config_s.i_WinSize = round(config_s.f_WinSize_sec*FGetSampRate(oSnd));
		config_s.i_HopSize = round(config_s.f_HopSize_sec*FGetSampRate(oSnd));
		config_s.i_FFTSize = 2^nextpow2(config_s.i_WinSize);

        if ~isfield( config_s, 'w_WinType'),		config_s.w_WinType = 'hamming';	end;
		if ~isfield( config_s, 'f_Win_v')
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
iHWinSize	= fix((c.i_WinSize-1)/2);

% === 2x distribution elements
d.f_SampRateX = config_s.f_SampRateX;
d.f_SampRateY = config_s.f_SampRateY;

% === get input sig. (make analytic)
f_Sig_v = FGetSignal(oSnd);
if isreal(f_Sig_v), f_Sig_v = hilbert(f_Sig_v); end

% === pre/post-pad signal
f_Sig_v = [zeros(iHWinSize,1); f_Sig_v; zeros(iHWinSize,1)];
        
% === support vectors            
i_Len		= length(f_Sig_v);
i_Ind		= [iHWinSize+1 : c.i_HopSize : i_Len-iHWinSize];
d.i_SizeX	= length(i_Ind);
d.i_SizeY	= c.i_FFTSize;
d.f_SupX_v	= [0:(d.i_SizeX-1)]./config_s.f_SampRateX;		% === X support (time)
d.f_SupY_v	= ([0:(d.i_SizeY-1)]./d.i_SizeY/2)';			% === Y support (normalized freq.)

% === calculate power spectrum
d.f_DistrPts_m = zeros(d.i_SizeY, d.i_SizeX);
for( i=1:d.i_SizeX )
    d.f_DistrPts_m(1:c.i_WinSize,i) = f_Sig_v(i_Ind(i)-iHWinSize:i_Ind(i)+iHWinSize) .* c.f_Win_v; % calc. windowed sig.
end;

% === fft (cols of dist.)
if( strcmp(config_s.w_DistType, 'pow') )						% === Power distribution
    d.f_DistrPts_m			= 1/c.i_FFTSize .* abs( fft( d.f_DistrPts_m, c.i_FFTSize) ).^2;
    d.f_DistrPts_m			= d.f_DistrPts_m ./ sum(c.f_Win_v .^2); % === remove window energy
    d.f_DistrPts_m(2:end)	= d.f_DistrPts_m(2:end) ./ 2;		% === remove added energy from hilbert x-form?
    
elseif( strcmp(config_s.w_DistType, 'mag') )					% === Magnitude distribution
    d.f_DistrPts_m			= sqrt(1/c.i_FFTSize) .* abs( fft( d.f_DistrPts_m, c.i_FFTSize) );
    d.f_DistrPts_m			= d.f_DistrPts_m ./ sum(abs(c.f_Win_v));
    d.f_DistrPts_m(2:end)	= d.f_DistrPts_m(2:end) ./ 2;    
    
else % === Might want to add 'log' option as well (similar to IRCAM toolbox)
    disp('Error: unknown distribution type (options are: pow/mag)');
    exit(1);
end;


% === Build class
c = class(c, 'cFFTRep', c2xDistr(d)); % inherit generic distribution properties

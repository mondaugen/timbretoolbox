function [c,f,t]=ERBpower2(a,sr,cfarray,hopsize,bwfactor)
%ERBPOWER2 Cochlear power spectrogram by gammatone filter bank
%  [C,F,T] = ERBPOWER2(A,SR,CFARRAY,HOPSIZE,BWFACTOR) 
%  Power spectrogram with same frequency resolution and scale as human ear.
%
%  A: audio signal
%  SR: Hz - sampling rate
%  CFARRAY: array of channel frequencies (default: 1/2 ERB-spaced 30Hz-16 KHz)
%  HOPSIZE: s - interval between analyses (default: 0.01 s)
%  BWFACTOR: factor to apply to filter bandwidths (default=1)
%  C: spectrogram matrix
%  F: Hz - array of channel frequencies
%  T: s - array of times
%
%  ERBPOWER2 applies a gammatone filter bank to signal and calculates 
%  instantaneous power (smoothed over hopsize windows) at hopsize intervals
%
% See also ERBPOWER.

% AdC @ CNRS/Ircam 2001
% (c) 2001 CNRS

% TODO: calibrate, do temporal alignment

if nargin < 1 | isempty(a); error('no input vector'); end
if nargin < 2 | isempty(sr); error('need to specify sampling rate'); end
if nargin < 3 | isempty(cfarray)
	% space cfs at 1/2 ERB intervals from about 30Hz to 16kHz (or sr/2 if smaller):
	lo		= 30;                            % Hz - lower cf
	hi		= 16000;                         % Hz - upper cf
	hi		= min(hi, (sr/2-ERB(sr/2)/2)); % limit to 1/2 erb below Nyquist
	nchans	= round(2*(ERBfromhz(hi)-ERBfromhz(lo)));
	cfarray = ERBspace(lo,hi,nchans); 
end
[nchans,m] = size(cfarray);
if m>1; cfarray = cfarray'; if nchans>1; error('channel array should be 1D'); end; nchans=m; end

if nargin < 4 | isempty(hopsize),		hopsize = 0.01; end   % s
if nargin < 5 | isempty(bwfactor),		bwfactor = 1; end     
if nargin < 6 | isempty(outermiddle),	outermiddle = 'killian'; end  

% apply gammatone filterbank
b = gtfbank(a, sr, cfarray, bwfactor);

% instantaneous power
b = fbankpwrsmooth(b, sr, cfarray);

% smooth with a hopsize window, downsample
b			= rsmooth(b',sr*hopsize,1,1)';
b			= max(b,0); % remove negative gremlins that rsmooth is liable to produce
[m,n]		= size(b);
nframes		= floor(n/(sr*hopsize));
startsamples= round(1+(0:nframes-1)*hopsize*sr);	% array of frame start samples
c			= b(:,startsamples);
% plot(b(1:10:end,:)'); return

f = cfarray';
t = startsamples/sr;

function [c,f,t,wsize]=ERBpower2(a,sr,cfarray,hopsize,bwfactor,pad)
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
%  PAD:        A vector of values that can be used to pad the beginning of the
%              signal. This is useful when computing the spectrogram in chunks.
%              As the first window's centre is aligned with the first sample,
%              half (or half-1 if an odd sized window) of the window's samples
%              will be before the first sample. If this argument is not given,
%              these samples are taken to be 0. Otherwise N samples from the end
%              of this vector will be taken to be the signal before the 1st
%              sample where N is half the window length if the window is of even
%              length or half the window length - 1 if the window is of odd
%              length.
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

if isempty(hopsize),		hopsize = 0.01; end   % s
if isempty(bwfactor),		bwfactor = 1; end     
outermiddle = 'killian';

[m_a,n_a]=size(a);
if m_a>1; a=a'; if n_a>1; error('signal should be 1D'); end; n_a=m_a; end
[m_pad,n_pad]=size(pad);
if m_pad>1; pad=pad'; if n_pad>1; error('signal should be 1D'); end; n_pad=m_pad; end
l_pad = length(pad);

% apply gammatone filterbank
b = gtfbank([pad a], sr, cfarray, bwfactor);
% instantaneous power
b = fbankpwrsmooth(b, sr, cfarray);
% smooth with a hopsize window, downsample
b			= rsmooth(b',sr*hopsize,1,1)';
b			= max(b,0); % remove negative gremlins that rsmooth is liable to produce
b           = b(:,(l_pad+1):end);
[m,n]		= size(b);
nframes		= floor(n/(sr*hopsize));
startsamples= round(1+(0:nframes-1)*hopsize*sr); % array of frame start samples
c			= b(:,startsamples);
% plot(b(1:10:end,:)'); return

f = cfarray';
t = startsamples/sr;

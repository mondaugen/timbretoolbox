function [c,f,t,forward_wsize]=ERBspect(a,sr,method,exponent,hopsize,pad)
%ERBspect - Cochleagram of signal
%  p = ERBspect(a,sr,method)
%  calculates a cochleagram (spectrogram with same frequency resolution and
%  scale as human ear).
%
%  a: audio signal (array or file name)
%  sr: Hz - sampling rate
%  method: 'FFT' or 'gammatone' [default: 'FFT'] - calculation method
%  exponent: exponent to obtain specific loudness from power [default: 1/4]
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
%  output:
%   p.centroid: Hz - spectral centroid (instantaneous-loudness-weighted)
%   p.centroids: Hz - row vector of instantaneous spectral centroids
%   p.cochcleagram: cochleagram matrix (instantaneous partial loudness)
%   p.cfarray: Hz - column vector of channel frequencies
%   p.times: s - frame times
% 
%  FORWARD_WINSIZE:  samples - This is the number of samples after the hop index
%                    that fit within the window. This might not be equal to the
%                    window size if the window is not aligned to the hop index
%                    at the beginning, e.g., when the window's centre is aligned
%                    with the hop index. This is used to calculate how many hops
%                    will be taken when calculating the spectrogram.
%
%  See also: ERBpower.m

% Alain de Cheveigné @ CNRS/Ircam, 2001
% (c) 2001 CNRS

% TODO: calibrate

if nargin < 1 | isempty(a); help ERBspect; return; end
if exist('sr')==1  && ~isempty(sr)
	% if a is a file, load it but don't use its 'sr' info, else it's a vector
	if isa(a,'char'); a = allread(a); end
else
	% if a is a file, load it and use its 'sr' info, else it's a vector
	if isa(a,'char');
		[a,sr] = allread(a);
	else
		error('need to specify sampling rate');
	end
end

[m,n] = size(a);
if m==1; a=a'; m=n; n=1; end
if n>1;
	disp(['warning: using column 1 of ', num2str(n), '-column data']);
	a=a(:,1);
end
if nargin < 3 | isempty(method),	method = 'FFT'; end
if nargin < 4 | isempty(exponent),	exponent = 1/4; end;           % Hartmann (1997)

% apply outer/middle ear filter:
pad = pad(:);
l_pad = length(pad);
l_a   = length(a);
% account for padded signal as impulse response from this will influence "a"
a_pad		= outmidear([pad; a],sr);
pad = a_pad(1:l_pad);
a   = a_pad((l_pad+1):end);
[m,n]	= size(a);

% defaults (see ERBpower)
bwfactor = []; outermiddle = []; cfarray = [];
%hopsize = []; -- ck --
%hopsize=.001;

switch lower(method)
	case 'fft'
        [c,f,t,forward_wsize] = ERBpower(a,sr,cfarray,hopsize,bwfactor,pad);
	case 'gammatone'
		[c,f,t] = ERBpower2(a,sr,cfarray,hopsize,bwfactor,pad);
        forward_wsize=0;
	otherwise
		error('unexpected method');
end
clear('a');
c = c.^exponent;          % instantaneous partial loudness
[nchans,nframes]=size(c);

% spectral centroid
% TODO: This part broken because the struct "p" is not in the argument list.
%troids		= centroid(c);
%loud		= sum(c);								% instantaneous loudness
%troid		= sum(troids.*loud)/sum(loud)			% weighted average
%p.centroid	= interp1((1:nchans), f, troid);		% to hz
%p.centroids = interp1((1:nchans), f, troids);		% to hz

p.cochleagram = c;

if ~nargout	% plot
	c = max(-2,log10((eps+c))); % cosmetics
	c = flipud(c/max(max(c)));
	%ck %imagesc(c);
	surf(c,'EdgeColor','none'), colormap(jet); view(0,90);

	udtroids= nchans-troids+1;	% match upside-down axis
	hold on; plot(1:nframes,udtroids,'k'); hold off % plot spectral centroid
	%ck %set(gca,'yticklabel',round(f(1+nchans-get(gca,'ytick')))'); ylabel('Hz');
	xscale	= niceticks(max(t))';
	ticks	= round(xscale*nframes/max(t));
	%ck %set(gca,'xtick',ticks);
	%ck %set(gca,'xticklabel',1000*xscale'); xlabel('ms');

	disp(['spectral centroid (erb-scale, instantaneous-loudness-weighted average): ',  ...
		num2str(ERBfromhz(p.centroid),4), ' ERB (', num2str(p.centroid,4), ' Hz)']);
end

%clear c;
p.cfarray	= f;
p.times		= t;

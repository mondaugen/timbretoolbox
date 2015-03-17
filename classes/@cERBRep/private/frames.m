function [b,t]=frames(a,fsize,hopsize,nframes)
%b=frames(a,fsize,hopsize,nframes) - make matrix of signal frames
%
%  b: matrix of frames (columns)
%  a: signal vector
%  fsize: samples - frame size
%  hopsize: samples - interval between frames
%  nframes: number of frames to return (default: as many as fits)
%
%  hopsize may be fractional (frame positions rounded to nearest integer multiple)

if nargin < 3; help frames; return ; end

[m,n]=size(a);
if m>1; 
	a=a'; 
	if n>1; error('signal should be 1D'); end; 
	n=m; 
end

if nargin < 4 ; 
	nframes=ceil((n-fsize)/hopsize); 
else
	if nframes>ceil((n-fsize)/hopsize); error('nframes too large'); end
end 

b = ones(fsize, nframes);			% index matrix
t=1+round(hopsize*(0:nframes-1));	% frame start indices
b(1,:)=t;  b=cumsum(b);

a=[a, zeros(1,fsize)]; % extend a to allow last slice to extend beyond
b=a(b); 

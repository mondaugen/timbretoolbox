function [y,Fs,bits]=allread(file,ext,format)
%ALLREAD - Read any kind of data file. 
% Y=ALLREAD(FILE) loads a data file specified by the string FILE,
% returning the sampled data in y.  Unless FORMAT is specified,
% the file format is determined by heuristics (file suffix, magic
% words, presence of ascii numerical data, etc.).
% The syntax is similar to matlab's AUREAD and WAVREAD (.au, .snd
% and .wav formats are handled by those routines).  Other formats
% are handled by home-grown, possibly buggy code.  Caveat emptor!
% Beware that heuristics may spuriously trigger the wrong format.
%
% Formats currently handled are:
%	workspace: matlab array in workspace
%	AU: NeXT/SUN (handled by auread)
%	WAV: Microsoft WAVE (handled by wavread)
%	AIFF/AIFC
%	NIST
%	ESPS
%	WFF: Nottingham IHR's WFF format
%	IWAVE: John Cullings IWAVE format
%	ascii: (space,tab)/newline separated ascii 
%		(1st line of text, if present, is stripped)
%	csv: comma-separated ascii
%	double, float, long, short, char: native binary data
%	MACSND: macintosh 'snd' resources
%
% [Y,Fs,BITS]=ALLREAD(FILE) returns the sample rate (Fs) in Hertz
% and the number of bits per sample (BITS) used to encode the
% data in the file (if known).
%
% [...]=ALLREAD(FILE,N) returns only the first N samples from each
%	channel in the file.
% [...]=ALLREAD(FILE,[N1 N2]) returns only samples N1 through N2 from
%	each channel in the file.
% SIZ=ALLREAD(FILE,'size') returns the size of the audio data contained
% 	in the file in place of the actual audio data, returning the
%	vector SIZ=[samples channels].
% INFO=ALLREAD(FILE,'info') returns all available info about the file
%	in a structure.
% [...]=ALLREAD(FILE,[],FORMAT) specifies the file FORMAT rather than 
%	using heuristics.  
%
% See also MAP, AUREAD, WAVREAD and lower-level functions SF_FORMAT, 
% SF_INFO and SF_WAVE. 

% Alain de CheveignŽ, CNRS/Ircam, 2002.
% Copyright (c) 2002 Centre National de la Recherche Scientifique.
%
% Permission to use, copy, modify, and distribute this software without 
% fee is hereby granted FOR RESEARCH PURPOSES only, provided that this
% copyright notice appears in all copies and in all supporting 
% documentation, and that the software is not redistributed for any 
% fee (except for a nominal shipping charge). 
%
% For any other uses of this software, in original or modified form, 
% including but not limited to consulting, production or distribution
% in whole or in part, specific prior permission must be obtained from CNRS.
% Algorithms implemented by this software may be claimed by patents owned 
% by CNRS, France Telecom, Ircam or others.
%
% The CNRS makes no representations about the suitability of this 
% software for any purpose.  It is provided "as is" without express
% or implied warranty.  Beware of the bugs.

if nargin>3,
  error('Too many input arguments.');
end
if nargin == 3
	i.format=format;
end
if nargin<2, ext=[]; end    % Default - read all samples

% guess file format, get info about file
i.fname = file;
i = sf_info(i);
if isfield(i, 'sr')
	Fs = i.sr;
else 
	Fs = nan;
end
if isfield(i, 'samplebits');
	bits = i.samplebits;
else
	bits = nan;
end

	
exts=prod(size(ext));
if strncmp(lower(ext),'size',exts),
  	% Caller doesn't want data - just size of data in file:
  	y = [i.nsamples i.nchans];
  	if isfield (i, 'fd') & fopen(i.fd); fclose(i.fd); end;
  	return;
elseif strncmp(lower(ext),'info',exts),
  	% Caller doesn't want data - just info:
  	y=i;
  	if isfield (i, 'fd') & fopen(i.fd); fclose(i.fd); end;
  	return;
elseif exts>2,
  	error('Index range must be specified as a scalar or 2-element vector.');
elseif (exts==1),
  	ext=[1 ext];  % Prepend start sample index
elseif (exts==0)
	ext=[1 i.nsamples];
end

i.samples = ext;

% Read data:
y=sf_wave(i, i.samples);
if isfield (i, 'fd') & fopen(i.fd); fclose(i.fd); end;

% end of allread.m

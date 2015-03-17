% function [FILE_s] = Gget_filelist(wDirectory, EXT)
%
% DESCRIPTION:
% ============
% get the list of audio files in a given folder
%
% INPUTS:
% =======
% - wDirectory	: full path to the folder
% - EXT			: extension of the files to look for (default [.wav])
%
% OUTPUTS:
% ========
% - FILE_s(:)	.root		: root of the audio file
%				.fullpath	: fullpath to the audio file
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [FILE_s] = Gget_filelist(wDirectory, EXT)

if nargin==1, EXT='.wav'; end

allfile_s = dir(wDirectory); 

count=0; 
for l=1:length(allfile_s),
	if ~allfile_s(l).isdir
		if length(allfile_s(l).name)>length(EXT)
			if strcmp(allfile_s(l).name(end-length(EXT)+1:end), EXT)
				count=count+1;				
				FILE_s(count).root		= [allfile_s(l).name(1:end-length(EXT))];
				FILE_s(count).fullpath	= [wDirectory filesep allfile_s(l).name];
			end, % === if strcmp
		end, % === if length
	end, % === if isdir
end, % === for l

if ~exist('FILE_s'), FILE_s = []; end

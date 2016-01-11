function c = cSound(varargin)
% CSOUND:
% =======
% Instantiates a cSound class from a filename and configuration structure.
%
% INPUTS:
% =======
% A string specifying a path to the soundfile
%
% A configuration structure containing the fields
% f_HopSize_sec     - analysis hop size for the time domain descriptors (other
%                     representations, e.g. FFT, have their own hop size, etc.).
% f_WinSize_sec     - analysis window size.
% w_Format          - If the soundfile is a raw file, specifies the datatype of
%                     one sample. This can be any datatype supported by fread.
%                     To select the raw file type, the filename must end with
%                     '.raw'.
% i_Channels        - If the soundfile is a raw file, specifies the number of
%                     channels.
% i_SampleRange_v   - (Optional) An array of two elements. The first is the
%                     index at which to start reading (indexed starting at 1)
%                     and the second is the index at which to stop reading. The
%                     samples indices are given as if the file only contained
%                     one channel. For example, if the file has a sampling rate
%                     of 48000 Hz and contains 2 channels and you would like to
%                     have the sound from 1 second in for a duration of 1
%                     second, you would set this field to the array [1*48000
%                     2*48000]. If it is not specified, all of the first channel
%                     of the audio file is read.
% f_Fs              - Sample rate of audio file. (Required only for raw files).
% 
%
% OUTPUTS:
% ========
% A cSound object containing the fields:
% f_Sig_v       - The samples read from the file. If the file comprises many
%                 channels, these are the samples from the first channel.
% i_Len         - The number of samples read from the file. This will only be
%                 equal to the total number of samples in one channel of the
%                 audiofile  if no sample range was specified.
% i_Bits        - The number of bits used to represent one sample in the audio
%                 file. This is only valid for uncompressed (e.g. WAVE, or raw)
%                 or loss-lessly compressed audio files (e.g., FLAC), for
%                 lossily compressed audio files (like mp3 or ogg) this will be
%                 set to 0.
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
% It will also contain all of the fields in the configuration structure (if they
% weren't specified, they were given a default value) except for: w_Format,
% i_Channels and i_SampleRange_v.
%
% Copyright (c) 2011 IRCAM/ McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

% === Evaluate input args
switch nargin
	case 1
		if( isa( varargin{1}, 'char' ) )
			c.w_FileName = varargin{1};
		else
			disp('Error: invalid filename');
			return;
		end;

        % see Peeters (2011) for defaults
		s_Config.f_HopSize_sec	= 0.0029;
		s_Config.f_WinSize_sec	= 0.0232;

	case 2
		if( isa( varargin{1}, 'char' ) )
			c.w_FileName = varargin{1};
		else
			disp('Error: invalid filename');
			return;
		end;

		% === Configs
		s_Config = varargin{2};

        if ~isfield(s_Config,'f_HopSize_sec'),
            s_Config.f_HopSize_sec	= 0.0029;
        end;
        if ~isfield(s_Config,'f_WinSize_sec'),
            s_Config.f_WinSize_sec	= 0.0232;
        end;

	otherwise
		return;
end;

% === Get input type
pos_v			= findstr(c.w_FileName, '.');
c.w_FileType	= c.w_FileName(pos_v(end)+1:end);

% === Read file
switch c.w_FileType
    case 'raw',
        if (~isfield(s_Config,'w_Format') | ~isfield(s_Config,'i_Channels') ...
             | ~isfield(s_Config,'f_Fs')),
            error(['Need to specificy format, number of channels and sample rate for' ...
            ' files of type "raw".']);
        end;
        % Get data type size in bytes.
        x__=eval(sprintf('%s(1)',s_Config.w_Format));
        s__=whos('x__');
        f=fopen(c.w_FileName,'r');
        if isfield(s_Config,'i_SampleRange_v'),
            % skip over samples
            fseek(f,s__.bytes*(s_Config.i_SampleRange_v(1)-1)*s_Config.i_Channels,'bof');
            % read in samples
            data=fread(f,(diff(s_Config.i_SampleRange_v)+1)*s_Config.i_Channels,s_Config.w_Format);
        else
            data=fread(f,Inf,s_Config.w_Format);
        end
        % Only keep the first channel
        c.f_Sig_v = data(1:s_Config.i_Channels:end);
        fclose(f);
        c.f_Fs = s_Config.f_Fs;
        % Store data type size in bits
        c.i_Bits=s__.bytes*8;
	case 'aiff',        
        if isfield(s_Config,'i_SampleRange_v'),
            [c.f_Sig_v, c.f_Fs, c.i_Bits]	= allread(c.w_FileName,s_Config.i_SampleRange_v);
        else
            [c.f_Sig_v, c.f_Fs, c.i_Bits]	= allread(c.w_FileName);
        end
        % Only keep the first channel
		c.f_Sig_v=c.f_Sig_v(:,1);
	otherwise,
        info__=audioinfo(c.w_FileName);
        if isfield(s_Config,'i_SampleRange_v'),
            [c.f_Sig_v, c.f_Fs] = ...
                audioread(c.w_FileName,s_Config.i_SampleRange_v);
        else
		    [c.f_Sig_v, c.f_Fs] = audioread(c.w_FileName);
        end;
        if (isfield(info__,'BitsPerSample'))
            c.i_Bits=info__.BitsPerSample;
        else
            c.i_Bits=0;
        end
        % Only keep the first channel
        c.f_Sig_v=c.f_Sig_v(:,1);
end;

c.i_Len		= length(c.f_Sig_v);

% === Windowing/hop size for instantaneous temporal features
c.i_HopSize	= round(s_Config.f_HopSize_sec*c.f_Fs);
c.i_WinSize	= round(s_Config.f_WinSize_sec*c.f_Fs);
c.f_Win_v	= hamming(c.i_WinSize);
c.i_IncToNext=(floor((c.i_Len - c.i_WinSize)/c.i_HopSize + 1)*c.i_HopSize);


% === Instantiate class
c = class(c, 'cSound');

return;

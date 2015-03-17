% function c = cSound(varargin)
%
% DESCRIPTION:
% ============
%
% INPUTS:
% =======
%
% OUTPUTS:
% ========
%
% Copyright (c) 2011 IRCAM/ McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function c = cSound(varargin)

% === Evaluate input args
switch nargin
	case 1
		if( isa( varargin{1}, 'char' ) )
			c.w_FileName = varargin{1};
		else
			disp('Error: invalid filename');
			return;
		end;

		s_Config.f_HopSize_sec	= 128/44100;		% === is 0.0029s at 44100Hz
		s_Config.f_WinLen_sec	= 1024/44100;		% === is 0.0232s at 44100Hz

	case 2
		if( isa( varargin{1}, 'char' ) )
			c.w_FileName = varargin{1};
		else
			disp('Error: invalid filename');
			return;
		end;

		% === Configs
		s_Config = varargin{2};

	otherwise
		return;
end;

% === Get input type
pos_v			= findstr(c.w_FileName, '.');
c.w_FileType	= c.w_FileName(pos_v(end)+1:end);

% === Read file
switch c.w_FileType
	case 'wav',         
		[c.f_Sig_v, c.f_Fs, c.i_Bits]	= wavread(c.w_FileName);
		c.f_Sig_v						= mean(c.f_Sig_v, 2);   % === for stereo signal
	case 'aiff',        
		[c.f_Sig_v, c.f_Fs, c.i_Bits]	= allread(c.w_FileName);
		c.f_Sig_v						= mean(c.f_Sig_v, 2);    % === for stereo signal
        c.f_Sig_v						= c.f_Sig_v / 2^c.iBits; % === NEW GFP 2011/07/07
	otherwise,		error('Unsupported file type');
end;

c.i_Len		= length(c.f_Sig_v);

% === Windowing/hop size for instantaneous temporal features
c.i_HopSize	= round(s_Config.f_HopSize_sec*c.f_Fs);
c.i_WinLen	= round(s_Config.f_WinLen_sec*c.f_Fs);
c.f_Win_v	= hamming(c.i_WinLen);


% === Instantiate class
c = class(c, 'cSound');

return;
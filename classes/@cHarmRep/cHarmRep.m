% function [c] = cHarmRep(Snd_o, config_s)
%
% DESCRIPTION:
% ============ 
% Harmonic Sinusoidal Model representation
%
% INPUTS:
% =======
% (1) cSound object (mandatory)
% (2) configuration structure (optional)
%
% OUTPUTS:
% ========
% (1) Harmo object
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [c] = cHarmRep(Snd_o, config_s)


% === get input sig. 
c.f_Sig_v	= FGetSignal(Snd_o);
c.sr_hz		= FGetSampRate(Snd_o);
c.config_s	= config_s;

[c.f_F0_v, c.PartTrax_s, c.f_SupX_v, c.f_SupY_v, c.f_DistrPts_m] = Fanalyseharmo(c.f_Sig_v, c.sr_hz, c.config_s);


% === Build class
c = class(c, 'cHarmRep'); % inherit generic distribution properties

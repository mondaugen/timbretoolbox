% function [f_EffDur] = FCalcEffectiveDur(f_Env_v, f_Thresh)
%
% DESCRIPTION:
% ============
% Return the Effective Duration in samples based on the global envelope and a normalized threshold on [0,1]
%
% INPUTS:
% =======
% - f_Env_v
% - f_Thresh
%
% OUTPUTS:
% ========
% - f_EffDur
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [f_EffDur] = FCalcEffectiveDur(f_Env_v, f_Thresh)

[f_MaxEnv, i_MaxInd]= max(f_Env_v);					% === max value and index
f_Env_v				= f_Env_v ./ f_MaxEnv;			% === normalize
i_Pos_v				= find(f_Env_v > f_Thresh);

i_StartFrm = i_Pos_v(1);
if( i_StartFrm == i_MaxInd)
	i_StartFrm = i_StartFrm - 1;
end
i_StopFrm	= i_Pos_v(end);

f_EffDur	= (i_StopFrm - i_StartFrm + 1);

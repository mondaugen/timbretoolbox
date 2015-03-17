% function [f_TempCent] = FCalcTempCentroid(f_Env_v, f_Thresh)
%
% DESCRIPTION:
% ============
% Compute the Temporal Centroid
%
% INPUTS:
% =======
% - f_Env_v		: envelop vector (can be energy over time)
% - f_Thresh	: threshold to applied to the envelop
%
% OUTPUTS:
% ========
% - f_TempCent	: Temporal Centroid
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [f_TempCent] = FCalcTempCentroid(f_Env_v, f_Thresh)

[f_MaxEnv, i_MaxInd]= max(f_Env_v);              % max value and index
f_Env_v				= f_Env_v ./ f_MaxEnv;       % normalize
i_Pos_v				= find(f_Env_v > f_Thresh);

i_StartFrm = i_Pos_v(1);
if( i_StartFrm == i_MaxInd )
    i_StartFrm = i_StartFrm - 1;
end;
i_StopFrm	= i_Pos_v(end);

f_Env2_v	= f_Env_v(i_StartFrm : i_StopFrm);
f_SupVec_v	= ([1:length(f_Env2_v)]-1)';
f_Mean		= sum(f_SupVec_v .* f_Env2_v) ./ sum(f_Env2_v); % centroid

f_TempCent	= (i_StartFrm + f_Mean);            % temporal centroid (in samples)

function FCalcDescrCheckFields(c)
% FCALCDESCRCHECKFIELDS
%
% Input:
%
% c - a c2xDistr
%
% Checks to see if FCalcDescr can be called on c without error. 
%
% If c has length(c.PartTrax_s) == 0 an error with identifier
% 'FCalcDescr:BadSize' will be thrown. This error can be caught (see MATLAB
% documentation). 

% Check validity of fields of c
errorStruct=struct();
if (length(c.PartTrax_s) == 0)
    errorStruct.message=sprintf('Bad size: (%d)',length(c.PartTrax_s));
    errorStruct.identifier='FCalcDescr:BadSize';
    error(errorStruct);
end

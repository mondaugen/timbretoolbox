function FCalcDescrCheckFields(c)
% FCALCDESCRCHECKFIELDS
%
% Input:
%
% c - a c2xDistr
%
% Checks to see if FCalcDescr can be called on c without error. 
%
% If c has c.i_Len == 0 an error with identifier
% 'FCalcDescr:BadSize' will be thrown. This error can be caught (see MATLAB
% documentation). 

% Check validity of fields of c
errorStruct=struct();
if (c.i_Len < c.i_WinSize)
    errorStruct.message=sprintf('Bad size: (%d)',c.i_Len);
    errorStruct.identifier='FCalcDescr:BadSize';
    error(errorStruct);
end

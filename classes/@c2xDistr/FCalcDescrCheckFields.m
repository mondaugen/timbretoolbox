function FCalcDescrCheckFields(c)
% FCALCDESCRCHECKFIELDS
%
% Input:
%
% c - a c2xDistr
%
% Checks to see if FCalcDescr can be called on c without error. 
%
% If c has an i_SizeX <= 1 or i_SizeY = 0, an error with identifier
% 'FCalcDescr:BadSize' will be thrown. This error can be caught (see MATLAB
% documentation).

% Check validity of fields of c
errorStruct=struct();
if (c.i_SizeX <= 1) || (c.i_SizeY == 0)
    errorStruct.message=sprintf('Bad size: (%d,%d)',c.i_SizeX,c.i_SizeY);
    errorStruct.identifier='FCalcDescr:BadSize';
    error(errorStruct);
end

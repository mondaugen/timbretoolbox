function [a] = horzcat(a,b)
% HORZCAT
% Overriding horzcat function for cHarmRep.
%
% Convert to structures
a=struct(a);
b=struct(b);
% Hopsize, w_method and f_Exp must be equal for concatenation to succeed.
if ~(a.i_HopSize == b.i_HopSize)
    error(['Field i_HopSize not equal. First is ' a.i_HopSize ', second is '
        b.i_HopSize '.']);
end;
if ~(strcmp(a.w_Method,b.w_Method))
    error(['Field w_Method not equal. First is ' a.w_Method ', second is ' ...
        b.w_Method '.']);
end;
if ~(a.f_Exp == b.f_Exp)
    error(['Field f_Exp not equal. First is ' a.f_Exp ', second is '
        b.f_Exp '.']);
end;
% "a" cannot contain a field called c2xDistr before it becomes a class, so we
% store the concatenated distribution somewhere else and delete the field
distr=[a.c2xDistr,b.c2xDistr];
a=rmfield(a,'c2xDistr');
% Now it will inherit from the concatenated c2xDistr
a=class(a,'cERBRep',distr);

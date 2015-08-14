function [a] = horzcat(a,b)
% HORZCAT
% Overriding horzcat function for cHarmRep.
%
% Convert to structures
a=struct(a);
b=struct(b);
% Check that the config structures are equal.
if length(fields(a.config_s)) ~= length(fields(b.config_s))
    error(['Number of config_s fields not equal. ' ...
        'First is ' length(fields(a.config_s)) ', second is ' ...
        length(fields(b.config_s))]);
end
flds=fields(a.config_s);
for k=1:length(flds)
    if length(a.config_s.(flds{k})) ~= length(a.config_s.(flds{k}))
        error(['Field ' flds{k} ' lengths do not match.']);
    end;
    if any(a.config_s.(flds{k}) ~= a.config_s.(flds{k}))
        error(['Fields ' flds{k} ' do not match.' ...
            'first is ' a.config_s.(flds{k}) ', second is ' ...
            b.config_s.(flds{k})]);
    end;
end;
% The rest of the fields can be concatenated
a.f_F0_v=[a.f_F0_v,b.f_F0_v];
a.PartTrax_s=[a.PartTrax_s,b.PartTrax_s];
% "a" cannot contain a field called c2xDistr before it becomes a class, so we
% store the concatenated distribution somewhere else and delete the field
distr=[a.c2xDistr,b.c2xDistr];
a=rmfield(a,'c2xDistr');
% Now it will inherit from the concatenated c2xDistr
a=class(a,'cHarmRep',distr);

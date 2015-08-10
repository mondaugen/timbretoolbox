function [descr] = horzcat(descr1,descr2)
% HORZCAT
% Combine two descriptors by offsetting and appending the time points of descr2
% to descr1 and appending the other description information. Only two
% descriptors of the same subclass may be combined.
% 
% e.g.,
% The time points of descr1 are [0, 0.5, 1.0] and the time points of descr2 are
% [0, 0.5, 1.0] then the resulting descriptor will have the time points [0, 0.5,
% 1.0, 1.5, 2.0, 2.5].
% 
% Notice that it is assumed the last timepoint's information is valid for a
% duration equal to the spacing of the time points (here 0.5). In the case that
% there is unequal spacing, the final difference will be used, so in the case
% where descr1's time points are [0, 0.75, 0.8] and descr2's time points are the
% same, the result will be [0, 0.75, 0.8, 0.85, 1.35, 1.85]. Probably you will
% prefer to have equal spacing for all the descriptors, but the unequal case
% does work. If descr1 has length 1 then the spacing is assumed to be 1 e.g.,
% [0] and [0 0.5 1.0] will make [0 1. 1.5 2.]. 
%
% descr1's f_SupX_v must be at least of length 2.
%
% The fields of descr1 are looked for in descr2.
% 
% The contents of all fields are concatenated along the horizontal dimension.
if (~isfield(descr1,'f_SupX_v') | ~isfield(descr2,'f_SupX_v'))
    error(['All classes inheriting from cDescr require a vector that ' ...
    'indicates to what times the descriptors refer']);
end;
descr=struct();
descr.f_SupX_v=descr2.f_SupX_v+descr1.f_SupX_v(end)+ ...
    (descr1.f_SupX_v(end)-descr1.f_SupX_v(end-1));
descr.f_SupX_v=[descr1.f_SupX_v,descr.f_SupX_v];
% combine fields along horizontal dimension
flds=fields(descr1);
% remove f_SupX_v field name as it has already been concatenated
flds(find(strcmp('f_SupX_v',flds)))='';
for k=1:length(flds),
    descr.(flds{k})=horzcat(descr1.(flds{k}),descr2.(flds{k}));
end;
descr=class(descr,'cDescr');

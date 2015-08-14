function [c] = cDescr_concat(a,b)
% CDESCR_CONCAT
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
% Check that classes are the same type
if ~isa(a,class(b)),
    error(['Objects being concatenated must be of the same class.' ...
        'a is: ' class(a) '. ' ...
        'b is: ' class(b) '.']);
end;
% Concatenate f_SupX_v, which is common to all Prods
a_f_SupX_v=get_f_SupX_v(a);
b_f_SupX_v=get_f_SupX_v(b);
f_SupX_v=b_f_SupX_v+a_f_SupX_v(end)+ ...
    (a_f_SupX_v(end)-a_f_SupX_v(end-1));
f_SupX_v=[a_f_SupX_v,f_SupX_v];
% Get data that can be concatenated
data_a=get_concat_data(a);
data_b=get_concat_data(b);
% Concatenate data
data_c=struct();
flds=fields(data_a);
for k=1:length(flds),
    data_c.(flds{k})=[data_a.(flds{k}),data_b.(flds{k})];
end;
% Clone a in a way intended for concatenation. That means the clone can contain
% the fields that were not returned by the call to get_concat_data, in order to
% preserve them.
c=concat_clone(a);
% Assign concatenated fields to clone
c=set_data(c,data_c);
c=set_f_SupX_v(c,f_SupX_v);

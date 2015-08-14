% This has to be copied to all subclasses, even though what it does is the same
% for all subclasses of cDescr. It cannot be a method of cDescr because when it
% is called it thinks that c's fields are cDescr's fields and complains that it
% cannot add fields.
function [c] = set_data(c,d)
flds=fields(d);
% f_SupX_v must be set using set_f_SupX_v
flds(find(strcmp(flds,'f_SupX_v')))='';
for k=1:length(flds),
    c.(flds{k})=d.(flds{k});
end;

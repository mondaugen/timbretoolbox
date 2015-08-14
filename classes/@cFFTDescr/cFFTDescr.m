function [c] = cFFTDescr(s)
parent=cDescr();
parent=set_f_SupX_v(parent,s.f_SupX_v);
% Remove f_SupX_v field from initialization structure, or else we'll have it
% twice.
s=rmfield(s,'f_SupX_v');
c=class(s,'cFFTDescr',parent);

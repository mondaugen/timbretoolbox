function [clone] = concat_clone(c)
% No fields of the AS class need to be cloned. They will be filled in by the
% concatenated result.
clone=c;
clone=set_f_SupX_v(clone,[]);

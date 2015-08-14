function [d] = get_concat_data(c)
% This function gets the fields from c that can be concatenated. This will not
% return fields that you would want to only contain value after a concatenation.
%
% As far as I know, the parent class is always the last field in the struct that
% results when calling struct on a class. It should be safe to just remove the
% last field. This must be done because I don't know how to get the name of the
% parent class in order to search in the struct for this field name, and I can't
% find any documentation of this.
d=struct(c);
flds=fields(d);
% All fields of the FFT data can be concatenated with one another
d=rmfield(d,flds{end});

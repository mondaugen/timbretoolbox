% function [] = Gwrite_resultfile(FILENAME, ALLTM_s)
%
% DESCRIPTION:
% ============
% write the descriptors contained in ALLTM_s(:).name=value into a text file "FILENAME"
%
% INTPUTS:
% ========
%
% OUTPUTS:
% ========
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [] = Gwrite_resultfile(FILENAME, ALLTM_s)


fid			= fopen(FILENAME, 'w');
fieldname_c = fieldnames(ALLTM_s);
for f=1:length(fieldname_c)
	value	= ALLTM_s.(fieldname_c{f});
	name	= fieldname_c{f};
	if length(value)==1
		fprintf(fid, '%s\t%f\n', name, value);
	else
		for l=1:length(value)
			fprintf(fid, '%s_%d\t%f\n', name, l, value(l));
		end
	end
end
fclose(fid);


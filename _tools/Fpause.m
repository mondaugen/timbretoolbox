% function [] = Fpause()
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [] = Fpause()

a=dbstack;
fprintf(1, 'in pause [%s %d]\n', a(2).file, a(2).line);
pause
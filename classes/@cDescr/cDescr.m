% function d = cDescr(varargin)
%
% DESCRIPTION:
% ============ 
%
% INPUTS:
% =======
%
% OUTPUTS:
% ========
% 
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function d = cDescr(varargin)

switch nargin
    case 0
        % make empty object
    case 1
        % copy to new object
        c = varargin{1};
    otherwise
        % error
end;
d = class(c, 'cDescr');
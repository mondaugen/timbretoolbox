% function d = cDescr(varargin)
%
% DESCRIPTION:
% ============ 
% An abstract class for descriptors.
% The following methods must be defined in subclasses or else some methods will
% not work them.
% get_concat_data
% concat_clone
% set_data
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

function d = cDescr(c)
% 
% All cDescr classes have an x support vector that indicates at what times the
% data refers to.
c.f_SupX_v=[];
d = class(c, 'cDescr');

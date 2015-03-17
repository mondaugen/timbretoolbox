% function [pos_max_v] = Fcomparepics2(input_v, lag_n, do_affiche, lag2_n, seuil)
%
% DESCRIPTION:
% ============
% detection des maxima locaux [n-lag:n+lag] du vecteur input_v
%
% INPUTS:
% =======
% - input_v  	: le spectre d'amplitude
% - lag_n      	: nombre de points lateraux de comparaisons
%
% OUTPUTS:
% ========
% - pos_max_v   : position des maximas locaux
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [pos_max_v] = Fcomparepics2(input_v, lag_n, do_affiche, lag2_n, seuil)

if nargin < 3, do_affiche	= 0;		end
if nargin < 2, lag_n		= 2;		end
if nargin < 4, lag2_n		= 2*lag_n;	end
if nargin < 5, seuil		= 0;		end

L_n = length(input_v);

pos_cand_v = find(diff(sign(diff(input_v,1))) < 0);
pos_cand_v = pos_cand_v+1;

pos_max_v = [];

for p = 1 : length(pos_cand_v);
    pos = pos_cand_v(p);
    if (pos>lag_n) && (pos<=L_n-lag_n)
        tmp			= input_v(pos-lag_n:pos+lag_n);
        [maximum, position]	= max(tmp);
        position		= position + pos-lag_n-1;
        
        if (pos-lag2_n)>0 && (pos+lag2_n)<L_n+1
            tmp2			= input_v(pos-lag2_n:pos+lag2_n);
            if (position == pos) && (input_v(position)>seuil*mean(tmp2))
                pos_max_v = [pos_max_v; pos];
            end
        end
    end
end

% ===============================
% === traitement des extrémités
% ===============================
if lag_n < 2
    if input_v(1) > input_v(2),
        pos_max_v = [1; pos_max_v];
    end
    if input_v(end) > input_v(end-1)
        pos_max_v = [pos_max_v; L_n];
    end
end
% ===============================

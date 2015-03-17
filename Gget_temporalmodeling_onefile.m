% function [ALLTM_s]	= Gget_temporalmodeling_onefile(ALLDESC_s, do_affiche)
%
% DESCRIPTION:
% ============
% performs the temporal modeling (min, max, mean, std) of the descriptors contained in 
% the structure ALLDESC_s(:).family_name(:).descriptor_name
% WARNING: it supposes that values are expressed as (nb_dim, nb_frame)
%
% INPUTS:
% =======
% - ALLDESC_s(:)	.family_name(:) .descriptor_name
%
% OUTPUTS:
% =======
% - ALLTM_s(:)		.family+variable+modlingtype_name
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [ALLTM_s]	= Gget_temporalmodeling_onefile(ALLDESC_s, do_affiche)

if nargin<2, do_affiche=0; end

fieldname1_c = fieldnames(ALLDESC_s);
for f1=1:length(fieldname1_c)
	if ~isempty(ALLDESC_s.(fieldname1_c{f1}))
		fieldname2_c = fieldnames( ALLDESC_s.(fieldname1_c{f1}) );
		for f2=1:length(fieldname2_c)
			name	= sprintf('%s_%s', fieldname1_c{f1}, fieldname2_c{f2});
			value 	= ALLDESC_s.(fieldname1_c{f1}).(fieldname2_c{f2});
			if ~ischar(value)
				if size(value,1)==1 && size(value,2)==1
					ALLTM_s.(name) = value;
                    
				elseif size(value,2)>1
					%ALLTM_s.([name '_min'])	= min(value, [], 2);
					%ALLTM_s.([name '_max'])	= max(value, [], 2);
					%ALLTM_s.([name '_mean'])	= mean(value, 2);
					%ALLTM_s.([name '_std'])	= std(value, [], 2);
					ALLTM_s.([name '_median']) = median(value, 2);
					ALLTM_s.([name '_iqr'])	= 0.7413*iqr(value, 2);
					
                    % +++++++++++++++++++++++++++++++++++++
					if do_affiche
						subplot(122)
						plot(value, 'linewidth', 2); ax=axis;
						aaa_c = {'_median','_iqr'};
						for a=1:length(aaa_c)
							plotvalue = ALLTM_s.([name aaa_c{a}]);
							hold on, 
							plot([ax(1) ax(2)], plotvalue*[1 1], 'k'); 
							if length(plotvalue)==1, text(ax(1), plotvalue, strrep(aaa_c{a},'_','-')); end
							hold off
						end
						title(strrep(name,'_','-'))
						Fpause
					end
					% +++++++++++++++++++++++++++++++++++++
                    
				else
					ALLTM_s.(name) = value;
				end
			end, % === if ischar
		end, % === for f2
	end, % === if isempty
end, % === for f1


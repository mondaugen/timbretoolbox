% function[y_v] = Fevalbp(bp, x_v)
%
% DESCRIPTION:
% ============
% 
%
% INPUTS:
% =======
% 
%
% OUTPUTS:
% ========
% 
% Copyright (c) 2010 IRCAM, All Rights Reserved. (peeters@ircam.fr
% Permission is only granted to use for research purposes
%


function[y_v] = Fevalbp(bp, x_v)

if max(max(isnan(bp))), error('bp is Nan'), end
if max(isnan(x_v)), error('bp is Nan'), end

x_v = x_v(:);
pos1 = find(x_v < bp(1,1));
if ~isempty(pos1), y_v(pos1,1) = bp(1,2); end
pos2 = find(x_v > bp(end,1));
if ~isempty(pos2), y_v(pos2,1) = bp(end,2); end

pos  = find((x_v >= bp(1,1)) & (x_v <= bp(end,1)));

if length(x_v(pos)) > 1, % ==============================

	%warning('using matlab interpolation this can cause a problem')
	y_v(pos,1) = interp1q(bp(:,1), bp(:,2), x_v(pos));

else % ==============================

	y_v = zeros(length(x_v), 1);

	for n = 1:length(x_v)
		%fprintf(1,'Fevalbp %d/%d\r', n, length(x_v));

		x = x_v(n);

		[minimum.value, minimum.pos] = min(abs(bp(:,1) - x));

		L = size(bp, 1);

		if (bp(minimum.pos,1) == x) | (L(1) == 1) | ...
				((bp(minimum.pos,1) < x) & (minimum.pos==L)) | ...
				((bp(minimum.pos,1) > x) & (minimum.pos==1))

			y_v(n) = bp(minimum.pos,2);

		elseif (bp(minimum.pos,1) < x)

			y_v(n) = (bp(minimum.pos+1,2) - bp(minimum.pos,2)) / ...
				(bp(minimum.pos+1,1) - bp(minimum.pos,1)) * ...
				(x - bp(minimum.pos,1)) + ...
				bp(minimum.pos,2);

		elseif (bp(minimum.pos,1) > x)

			y_v(n) = (bp(minimum.pos,2) - bp(minimum.pos-1,2)) / ...
				(bp(minimum.pos,1) - bp(minimum.pos-1,1)) * ...
				(x - bp(minimum.pos-1,1)) + ...
				bp(minimum.pos-1,2);

		else

			error('not a case')

		end


	end
	% ============================

end


% ============================
if nargout == 0
	subplot(111)
	plot(bp(:,1), bp(:,2), 'k.-')
	hold on
	plot(x_v, y_v, '*')
	hold off
end





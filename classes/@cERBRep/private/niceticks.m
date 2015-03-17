function y=niceticks(x)
%y=nicescale(x) - calculate a nice set of values for ticks, based on max
%
% x: maximum value along scale
% y: array of ticks

% closest power of 10 smaller than x:
a = 10^floor(log10(x));

if (x/a) < 2
	a = a/5;
elseif (x/a) < 5
	a = a/2;
end

y = a * (0:floor(x/a));

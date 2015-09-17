function [f_DistrPts_m,f_SupY_v,f_SupX_v,f_ENBW,i_ForwardWinSize] = FCalcSpectrogram(f_Sig_v, ...
    i_FFTSize, sr_hz, f_Win_v, i_Overlap, w_DistType, f_Pad_v, make_analytic)
% FCALCSPECTROGRAM - Calculates the spectrogram of a signal
% f_Sig_v          - The signal to compute a spectrogram of.
% i_FFTSize        - The length of the FFT.
% sr_hz            - The sampling rate of the signal
% f_Win_v          - The window used to do the windowing. This is a vector
%                    representing a window!
% i_Overlap        - The number of samples of overlap. Stated this way to be
%                    compatible with "specgram". To get the the overlap from the
%                    hop size, do: i_Overlap = length(f_Win_v) - i_HopSize.
% w_DistType       - The kind of distribution produced. See below for the kinds.
% f_Pad_v          - A vector of values that can be used to pad the beginning of
%                    the signal. This is useful when computing the spectrogram
%                    in chunks.  As the first window's centre is aligned with
%                    the first sample, half (or half-1 if an odd sized window)
%                    of the window's samples will be before the first sample. If
%                    this argument is not given, these samples are taken to be
%                    0. Otherwise N samples from the end of this vector will be
%                    taken to be the signal before the 1st sample where N is
%                    half the window length if the window is of even length or
%                    half the window length - 1 if the window is of odd length.
% make analytic    - If 1, will hilbert transform the signal before doing spectral
%                    anlaysis, otherwise no transformation carried out beforehand.
% 
% Returns 
% f_DistrPts_m     - the distribution points (not a valid probability
%                    distribution!)
% f_SupY_v         - the normalized frequencies to which the rows of the
%                    distribution refer.
% f_SupX_v         - the times to which the columns of the distribution refer
%                    (in seconds, weird I know)
% f_ENBW           - The ENBW total over all bins of the window used. This can
%                    be used to compute the total power in each frame from the
%                    resulting power spectrum: 
%                       P_total = 2*sum(f_DistrPts_m)./f_ENBW
%                    The reason for the 2 is because half of the spectrum is
%                    omitted (frequencies above Nyquist are not stored). Note
%                    that this only applies to the power spectrum calculation.
% i_ForwardWinSize - This is the number of samples after the hop index that fit
%                    within the window. This might not be equal to the window
%                    size if the window is not aligned to the hop index at the
%                    beginning, e.g., when the window's centre is aligned with
%                    the hop index. This is used to calculate how many hops will
%                    be taken when calculating the spectrogram.

i_WinSize = length(f_Win_v);
if (i_Overlap >= i_WinSize),
    error('Overlap greater than or equal to window size.');
end;
i_HopSize = i_WinSize - i_Overlap;
f_SampRateX = sr_hz / i_HopSize;

% Make column vector
f_Sig_v = f_Sig_v(:);
if (length(f_Pad_v) > 0)
    f_Pad_v=f_Pad_v(:);
end

% If the window is centred at t, this is the starting index at which to
% look up the signal which you want to multiply by the window. It is a
% negative number because (almost) half of the window will be before time t
% and half after. In fact, if the length of the window N is an even number,
% it is set up so this number equals -1*(N/2 - 1). If the length of the window
% is odd, this number equals -1*(N-1)/2.
iLHWinSize = ceil(-(i_WinSize-1)/2);
% This is the last index at which to look up signal values and is equal to
% (N-1)/2 if the length N of the window is odd and N/2 if the length of the
% window is even. This means that in the even case, the window has an
% unequal number of past and future values, i.e., time t is not the centre
% of the window, but slightly to the left of the centre of the window
% (before it).
iRHWinSize = ceil((i_WinSize-1)/2);
% iRHWinSize is a value by which you increment an index and not a size, so we
% add 1.
i_ForwardWinSize=iRHWinSize+1;

% Length of the signal before padding
i_Len		= length(f_Sig_v);

% pre/post-pad signal
if length(f_Pad_v) <= 0
    f_Sig_v = [zeros(-1*iLHWinSize,1); f_Sig_v];
else
    f_Sig_v = [f_Pad_v(end-fliplr(0:(-1*iLHWinSize-1))); f_Sig_v];
end

if (make_analytic == 1)
    f_Sig_v=hilbert(f_Sig_v);
end

% last hop index where the window will fit within the end of the signal
i_LastIndex=floor((i_Len-(iRHWinSize+1))/i_HopSize)*i_HopSize+1;

% support vectors            
i_Ind       = (1:i_HopSize:i_LastIndex)+iLHWinSize*-1;
i_SizeX	    = length(i_Ind);
i_SizeY	    = i_FFTSize/2; % Only return frequencies below Nyquist rate.
f_SupX_v	= [0:(i_SizeX-1)]/f_SampRateX;  % X support (time)
f_SupY_v	= ([0:(i_SizeY-1)]/i_SizeY/2)'; % Y support (normalized freq.)

% calc. windowed sig.
f_DistrPts_m = zeros(i_FFTSize, i_SizeX);
for( i=1:i_SizeX )
    f_DistrPts_m(1:i_WinSize,i) = ...
        f_Sig_v((i_Ind(i)+iLHWinSize):(i_Ind(i)+iRHWinSize)) .* f_Win_v; 
end;

% fft (cols of dist.)

% compute FFT unless we want unprocessed data
if strcmp(w_DistType,'nofft')==0
    f_DistrPts_m = fft(f_DistrPts_m, i_FFTSize);
    if strcmp(w_DistType, 'complex')
        f_DistrPts_m			= f_DistrPts_m;
        f_DistrPts_m			= f_DistrPts_m ./ (sum(f_Win_v)); % remove window energy
    elseif strcmp(w_DistType, 'pow') % Power distribution
        f_DistrPts_m			= abs(f_DistrPts_m).^2;
        f_DistrPts_m			= f_DistrPts_m ./ (sum(f_Win_v) .^2); %remove window energy
    elseif strcmp(w_DistType, 'mag') % Magnitude distribution
        f_DistrPts_m			= abs(f_DistrPts_m);
        f_DistrPts_m			= f_DistrPts_m ./ sum(abs(f_Win_v));
    elseif strcmp(w_DistType, 'mag_noscaling')
        % magnitude distribution with no scaling
        f_DistrPts_m = abs(f_DistrPts_m);
    else % Might want to add 'log' option as well (similar to IRCAM toolbox)
        error('Unknown distribution type (options are: pow/mag)');
    end;
end;
% only keep half the spectrum
f_DistrPts_m = f_DistrPts_m(1:floor(end/2),:);
f_ENBW=sum(f_Win_v.^2)/(sum(f_Win_v).^2)*i_FFTSize;

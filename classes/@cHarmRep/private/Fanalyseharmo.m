% function [f0_hz_v, PartTrax_s, f_SuxX_v, f_SupY_v, f_DistrPts_m, f_ENBW] = Fanalyseharmo(f_Sig_v, sr_hz, config_s)
%
% DESCRIPTION:
% ============
% compute the sinusoidal harmoic decomposition of a file
% based on external f0 estimation
%
% INPUTS:
% =======
% - f_Sig_v						:
% - sr_hz						:
% - config_s.threshold_harmo	:
%
% OUTPUTS:
% ========
% - f0_hz_v
% - PartTrax_s(nb_frame)	.f_Freq_v(1:config_s.nb_harmo)	: harmonic frequencies
%							.f_Ampl_v(1:config_s.nb_harm)	: linear amplitude of harmonics
% - f_SupX_v
% - f_SupY_v
% - f_DistrPts_m(N/2+1, nb_frame)							: spectrogram in power amplitude
% - f_ENBW                                                  : equivalent noise
%                                                             bandwidth of
%                                                             spectrogram
%                                                             analysis window
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%


function [f0_hz_v, PartTrax_s, f_SupX_v, f_SupY_v, f_DistrPts_m, f_ENBW, ...
    f_SampRateX, f_SampRateY, config_s, i_ForwardWinSize] = Fanalyseharmo(f_Sig_v, sr_hz, ...
    config_s, f_Pad_v)

% Supply defaults if not specified

if ~isfield(config_s,'threshold_harmo'),
    config_s.threshold_harmo = 0.3;
end;

if ~isfield(config_s,'nb_harmo'),
    config_s.nb_harmo = 20;
end;

do_affiche				= 0;


[p_v, t_v, s_v]			= swipep(f_Sig_v, sr_hz, [50 500], 0.01, 1/48, 0.1, 0.2, -Inf);
p_v(find(isnan(p_v)))	= median(p_v(find(~isnan(p_v))));

% ++++++++++++++++++++++++++++++
if do_affiche==3
	subplot(311), plot([0:length(f_Sig_v)-1]/sr_hz, f_Sig_v);
	subplot(312), specgram(f_Sig_v, 2048, sr_hz), a=colormap('gray'); 
	colormap(1-a); ax=axis; axis([ax(1) ax(2) 0 2000])
	hold on, plot(t_v, p_v, 'b.-'),			xlabel('Time (s)'), ylabel('Pitch (Hz)'), hold off
	subplot(313), plot(t_v, s_v, 'b.-'),	xlabel('Time (s)'), ylabel('Pitch Strength')
	Fpause
end


% ==========================================================
% === Compute sinusoidal harmonic parameters


if isfield(config_s,'f_WinSize_sec'),
    L_sec       = config_s.f_WinSize_sec;
else,
    L_sec		= 0.1; % === analysis window length
    config_s.f_WinSize_sec=L_sec;
end

if isfield(config_s,'f_HopSize_sec'),
    STEP_sec	= config_s.f_HopSize_sec;
else,
    STEP_sec	= L_sec/4; % === hop size
    config_s.f_HopSize_sec=STEP_sec;
end;
f_SampRateX=1/STEP_sec;

L_n				= round(L_sec*sr_hz);
config_s.i_WinSize=L_n;
STEP_n			= round(STEP_sec*sr_hz);
config_s.i_HopSize=STEP_n;

if (~isfield(config_s,'i_FFTSize')),
    N			= 4*2^nextpow2(L_n);	% === large zero-padding to get better frequency resolution
    config_s.i_FFTSize=N;
else
    N           = config_s.i_FFTSize;
end;
% This is more like 1/(bin_bandwidth) but is done this way to match cFFTRep
f_SampRateY=N/sr_hz;

% If window type is specified, synthesize the window and place it in the
% config_s.f_Win_v field.
% Note that if both a window type and a window vector are specified, the window
% type will overwrite the window vector and this new window vector will be used
% in place of the original window vector.
if isfield(config_s,'w_WinType'),
    config_s.f_Win_v = eval(sprintf('%s(%d)',config_s.w_WinType,L_n));
else
    config_s.w_WinType='custom';
end;

% If window defined in configure structure, use it, otherwise just use a boxcar
% window. If no window type was specified, w_WinType is currently 'custom'. If
% no window vector is specified, one is created (from a boxcar window) and
% w_WinType is given the value 'boxcar'. If not, it keeps the name 'custom'.
if ~isfield(config_s, 'f_Win_v'),
    fenetre_v	= blackman(L_n);
    config_s.f_Win_v = fenetre_v;
    config_s.w_WinType='blackman';
else
    if (length(config_s.f_Win_v) ~= L_n),
        error(['Analysis window (config_s.f_Win_v) length does not equal ' ...
               'specified window length (config_s.f_WinSize_sec). Note ' ...
               'that the length of the window is specified in seconds so ' ...
               'this means length(config_s.f_Win_v) must equal ' ...
               'config_s.f_WinSize_sec ' ...
               '* Fs where Fs is the sampling rate of the sound being ' ...
               'analysed.']);
    end;
    fenetre_v   = config_s.f_Win_v;
end;

[B_m, F_v, T_v, f_ENBW, i_ForwardWinSize] = ...
    FCalcSpectrogram(f_Sig_v, N, sr_hz, fenetre_v, L_n-STEP_n, 'mag', f_Pad_v, 1);

B_m				= abs(B_m);
T_v				= T_v+L_sec/2;

nb_frame		= size(B_m,2);
f_DistrPts_m	= abs(B_m).^2;
f_SupX_v		= T_v; 
f_SupY_v		= F_v;

lag_f0_hz_v		= [-5:0.1:5];			nb_delta		= length(lag_f0_hz_v);
inharmo_coef_v	= [0:0.00005:0.001];	nb_inharmo		= length(inharmo_coef_v);
totalenergy_3m	= zeros(nb_frame, length(lag_f0_hz_v), length(inharmo_coef_v));
stock_pos_4m	= zeros(nb_frame, length(lag_f0_hz_v), length(inharmo_coef_v), config_s.nb_harmo);

% ==========================================================
% === We consider only harmonic sounds -> if the sound is not harmonic then we do not analyse it
if max(s_v)>config_s.threshold_harmo,	f0_bp(:,1) = t_v; f0_bp(:,2) = p_v;
else									f0_bp = [];
end

if size(f0_bp, 1)==0
    warning('Sound deemed not harmonic. Setting f0 estimate to 0.');
    % If sound not harmonic, we just fill in with 0s as fundamental estimate,
    % otherwise this will cause there to be misalignment if the sound
    % analysed is a chunk of a whole sound.
    f0_hz_v			= zeros(1,nb_frame);
    PartTrax_s=repmat(struct('f_Freq_v',0,'f_Ampl_v',0),[1 nb_frame]);
	return;
end

% Estimate f0 at times at which spectrogram was evaluated by interpolating
% between times when f0 was evaluated
f0_hz_v = Fevalbp(f0_bp, T_v);
% === candidate_f0_hz_m (nb_frame, nb_delta)
% This is a range of frequencies around f0 the harmonics of which are
% searched for spectral peaks.
candidate_f0_hz_m			= repmat(f0_hz_v(:), 1, nb_delta) + repmat(lag_f0_hz_v(:).', nb_frame, 1);
stock_f0_m					= candidate_f0_hz_m;

for num_inharmo=1:nb_inharmo
	inharmo_coef = inharmo_coef_v(num_inharmo);
    % Calculate the harmonic numbers. These will be non-integer valued when the
    % inharmonicity coefficient is non-zero.
	nnum_harmo_v = [1:config_s.nb_harmo] .* sqrt( 1 + inharmo_coef * ([1:config_s.nb_harmo]).^2);

	for num_delta = 1:nb_delta
		% === candidate_f0_hz_v (nb_frame, 1)
        % The current fundamentals out of the range of fundamentals whose
        % harmonics we are checking in the spectrogram
		candidate_f0_hz_v		= candidate_f0_hz_m(:,num_delta);
		% === candidate_f0_hz_m (nb_frame, nb_harmo): (nb_frame,1)*(1,nb_harmo)
        % The current harmonics that we are checking in the spectrogram
		candidate_harmo_hz_m	= candidate_f0_hz_v(:) * nnum_harmo_v(:).';
		% === candidate_f0_hz_m (nb_frame, nb_harmo)
        % The spectrogram bins closest to the harmonics that we are checking in
        % the spectrogram
		candidate_harmo_pos_m	= round(candidate_harmo_hz_m/sr_hz*N)+1;

		stock_pos_4m(:,num_delta,num_inharmo,:)		= candidate_harmo_pos_m;
		for num_frame=1:nb_frame
            B_m_num_rows__ = size(B_m,1);
            % make sure all the indices are within the range of valid
            % indices for B_m's rows.
            valid_indices__ = candidate_harmo_pos_m(num_frame,:);
            valid_indices__ = ...
                valid_indices__(candidate_harmo_pos_m(num_frame,:) <= B_m_num_rows__);
			totalenergy_3m(num_frame, num_delta, num_inharmo) ...
                = sum( B_m(valid_indices__, num_frame) );
		end

		% ++++++++++++++++++++++++++++++
		if 0
			clf, imagesc(T_v, F_v, B_m), axis xy
			hold on,
			for num_harmo=1:config_s.nb_harmo, plot(T_v, F_v(candidate_harmo_pos_m(:,num_harmo)), 'r-o'); end
			hold off,
			title(sprintf('%d %f: %f', num_delta, inharmo_coef, sum(squeeze(totalenergy_3m(:, num_delta, num_inharmo)))))
			Fpause
		end
		% ++++++++++++++++++++++++++++++

	end, % === for num_delta
end, % === num_inharmo

% It seems the optimal harmonicity coefficient is chosen for the entire
% soundfile analysed.
% === choix du coefficient d'inharmonicite
for num_inharmo=1:nb_inharmo
	% === sum à travers les trames (max à chaque trame à travers les delta pour inharmo fixé)
	score_v(num_inharmo) = sum(max(squeeze(totalenergy_3m(:,:,num_inharmo))));
end

% If the maximum score is within 1% of the first score, just choose the first
% score. That is, just choose the inharmonicity coefficient at index 1.
[max_value, max_pos]	= max(score_v);
calcul = (score_v(max_pos)-score_v(1))/score_v(1);
if calcul>0.01,		num_inharmo = max_pos;
else				num_inharmo = 1;
end
totalenergy_2m		= squeeze(totalenergy_3m(:,:,num_inharmo));
%disp('Inharmonicity coefficient');
%f_InharmoCoeff      = inharmo_coef_v(num_inharmo);

for num_frame=1:nb_frame
    % Find the offset from f0 that gives the maximum and store its index and the
    % maximum
	[max_value, num_delta]			= max(totalenergy_2m(num_frame,:));
    % Look up what frequency this is
	f0_hz_v(num_frame)				= stock_f0_m(num_frame,num_delta);
    % No interpolation is performed to determine the frequency or amplitude of
    % the partial! These results could be very erroneous, especially in the case
    % of the amplitude.
	PartTrax_s(num_frame).f_Freq_v	= squeeze( F_v(stock_pos_4m(num_frame,num_delta,num_inharmo,:)) );
	PartTrax_s(num_frame).f_Ampl_v	= B_m(stock_pos_4m(num_frame,num_delta,num_inharmo,:), num_frame);
end



% ++++++++++++++++++++++++++++++
if do_affiche
	clf
	for m=1:3
		subplot(1,3,m)
		tmp_m = log(B_m+eps); M=max(max(tmp_m)); tmp_m(find(tmp_m<M-10))=M-10;
		imagesc(T_v, F_v, tmp_m), axis xy
		a=colormap('gray'); colormap(1-a);
		hold on,
		switch m
			case 1
				plot(f0_bp(:,1),f0_bp(:,2), 'r--', 'linewidth', 1)
				for num_harmo=1:config_s.nb_harmo, plot(f0_bp(:,1), num_harmo*f0_bp(:,2), 'r--', 'linewidth', 2), end
			case 2
				plot(T_v,		f0_hz_v,	'b--', 'linewidth', 1)
				for num_harmo=1:config_s.nb_harmo, plot(T_v, num_harmo*f0_hz_v, 'b--', 'linewidth', 2), end
			case 3
				for num_frame=1:nb_frame, F_m(:,num_frame) = PartTrax_s(num_frame).f_Freq_v; end
				for num_harmo=1:config_s.nb_harmo, plot(T_v, F_m(num_harmo,:), 'g--', 'linewidth', 2), end
		end
		hold off
		ax=axis; axis([ax(1) ax(2) 0 6000]);
		xlabel('Time [s.]'), ylabel('Frequency [Hz]');
	end
	title('original f0 (r) estimated-f0 and harmonics (b) partial (g)');
	Fpause
end
% ++++++++++++++++++++++++++++++

% Transpose f0_hz_v vector to make it consistent with the others in timbre
% toolbox.
f0_hz_v=f0_hz_v.';

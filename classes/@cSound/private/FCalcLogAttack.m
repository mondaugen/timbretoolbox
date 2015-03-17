% function [f_LAT, f_Incr, f_Decr, f_ADSR_v] = FCalcLogAttack(f_Env_v, f_Fs, f_ThreshNoise)
%
% DESCRIPTION:
% ============
% Compute all parameters related to the temporal envelope
%
% INPUTS:
% =======
% - f_Env_v			:
% - f_Fs			:
% - f_ThreshNoise	:
%
% OUTPUTS:
% ========
% - f_LAT			:
% - f_Incr			:
% - f_Decr			:
% - f_ADSR_v		:
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [f_LAT, f_Incr, f_Decr, f_ADSR_v] = FCalcLogAttack(f_Env_v, f_Fs, f_ThreshNoise)

i_Method		= 3; % 1 = 0.8*maximum, 2 = maximum, 3 = effort
f_ThreshDecr	= 0.4;

[f_EnvMax, i_EnvMaxInd]	= max(f_Env_v);
f_Env_v					= f_Env_v / (f_EnvMax); % normalize by maximum value

% ============================================
% === calcul de la pos pour chaque seuil
percent_step	= 0.1;
percent_value_v = [percent_step:percent_step:1];
for p=1:length(percent_value_v)
	pos_v				= find(f_Env_v >= percent_value_v(p));
	percent_posn_v(p)	= pos_v(1);
end
% ================================================
% === NOTATION
% satt: start attack
% eatt: end attack
%

% ==== détection du start (satt_posn) et du stop (eatt_posn) de l'attaque ========================
pos_v 	= find(f_Env_v > f_ThreshNoise);
switch i_Method
	case 1
		satt_posn	= pos_v(1);
		eatt_posn	= percent_posn_v(0.8/percent_step); % === équivalent à 80%

	case 2
		satt_posn	= pos_v(1);
		eatt_posn	= percent_posn_v(1.0/percent_step); % === équivalent à 100%

	case 3
		% === PARAMETRES
		param.m1	= round(0.3/percent_step); % === BORNES pour calcul mean
		param.m2	= round(0.6/percent_step);

		param.s1att	= round(0.1/percent_step); % === BORNES pour correction satt (start attack)
		param.s2att	= round(0.3/percent_step);

		param.e1att	= round(0.5/percent_step); % === BORNES pour correction eatt (end attack)
		param.e2att	= round(0.9/percent_step);

		% === facteur multiplicatif de l'effort
		param.mult	= 3;

		% === dpercent_posn_v = effort
		dpercent_posn_v	= diff(percent_posn_v);
		% === M = effort moyen
		M				= mean(dpercent_posn_v(param.m1:param.m2));

		% === 1) START ATTACK
		% === on DEMARRE juste APRES que l'effort à fournir (écart temporal entre percent) soit trop important
		pos2_v			= find(dpercent_posn_v(param.s1att:param.s2att) > param.mult*M);
		if ~isempty(pos2_v),result		= pos2_v(end)+param.s1att-1+1;
		else				result		= param.s1att;
		end
		satt_posn		= percent_posn_v(result);

		% === raffinement: on cherche le minimum local
		delta	= round(0.25*([percent_posn_v(result+1)-percent_posn_v(result)]));
		n		= percent_posn_v(result);
		if n-delta >= 1
			[min_value, min_pos]= min(f_Env_v(n-delta:n+delta));
			satt_posn			= min_pos + n-delta-1;
		end

		% === 2) END ATTACK
		% === on ARRETE juste AVANT que l'effort à fournir (écart temporal entre percent) soit trop important
		pos2_v		= find(dpercent_posn_v(param.e1att:param.e2att) > param.mult*M);
		if ~isempty(pos2_v),result		= pos2_v(1)+param.e1att-1;
		else				result		= param.e2att+1;
		end
		eatt_posn	= percent_posn_v(result);
		% === raffinement: on cherche le maximum local
		delta	= round(0.25*([percent_posn_v(result)-percent_posn_v(result-1)]));
		n		= percent_posn_v(result);
		if n+delta <= length(f_Env_v)
			[max_value, max_pos]	= max(f_Env_v(n-delta:n+delta));
			eatt_posn				= max_pos + n-delta-1;
		end

end

% ==============================================
% === D: Log-Attack-Time
if (satt_posn == eatt_posn), satt_posn = satt_posn - 1; end
risetime_n	= (eatt_posn - satt_posn);
f_LAT      	= log10(risetime_n/f_Fs);

% ==============================================
% === D: croissance temporelle NEW 13/01/2003
% === moyenne pondérée (gaussienne centrée sur percent=50%) des pentes entre satt_posn et eattpos_n
% === iEnvMaxInd, stop_posn
satt_value		= f_Env_v(satt_posn);
eatt_value		= f_Env_v(eatt_posn);
seuil_value_v	= [satt_value:0.1:eatt_value]';
seuil_possec_v	= zeros(length(seuil_value_v), 1);
for p=1:length(seuil_value_v)
	pos3_v				= find(f_Env_v(satt_posn:eatt_posn) >= seuil_value_v(p));
	seuil_possec_v(p)	= pos3_v(1)/f_Fs;
end
pente_v			= diff(seuil_value_v)./diff(seuil_possec_v);

if 0
	% === moyenne
	f_Incr		= mean(pente_v);
else
	% === moyenne pondérée par une gaussienne (maximum autour de 50%)
	mseuil_value_v	= 0.5*(seuil_value_v(1:end-1)+seuil_value_v(2:end));
	weight_v		= exp( -(mseuil_value_v-0.5).^2 / (0.5)^2);
	f_Incr			= sum(pente_v.*weight_v)/sum(weight_v);
end

tempsincr_sec_v		= [satt_posn:eatt_posn]'/f_Fs;
const				= mean(f_Env_v(round(tempsincr_sec_v*f_Fs))- f_Incr*tempsincr_sec_v);
mon_poly_incr		= [f_Incr const];

mon_poly_incr2		= polyfit(tempsincr_sec_v, f_Env_v(round(tempsincr_sec_v*f_Fs)), 1);
incr2				= mon_poly_incr2(1);



% =======================================================
% === D: décroissance temporelle
% === iEnvMaxInd, stop_posn
[fEnvMax, iEnvMaxInd] = max(f_Env_v);
%iEnvMaxInd	= iEnvMaxInd;							% === NEW 13/01/2003
iEnvMaxInd		= round(0.5*(iEnvMaxInd+eatt_posn));% === NEW 13/01/2003 (iEnvMaxInd est trop loin pour estimer MOD)

pos_v			= find(f_Env_v > f_ThreshDecr);		% === NEW 13/01/2003 augmentation du seuil
stop_posn		= pos_v(end);

% === NEW GFP 2007/01/11
if iEnvMaxInd==stop_posn
	if stop_posn<length(f_Env_v),	stop_posn = stop_posn+1;
	elseif iEnvMaxInd>1,			iEnvMaxInd = iEnvMaxInd-1;
	end
end

tempsdecr_sec_v	= [iEnvMaxInd:stop_posn]'/f_Fs;
mon_poly_decr 	= polyfit(tempsdecr_sec_v, log(f_Env_v(round(tempsdecr_sec_v*f_Fs))), 1);
f_Decr       	= mon_poly_decr(1);

% =======================================================
% === D: enveloppe ADSR = [A(1) | A(2)=D(1) | D(2)=S(1) | S(2)=D(1) | D(2)]
[f_ADSR_v]	= [satt_posn, iEnvMaxInd, 0, 0, stop_posn]'/f_Fs;

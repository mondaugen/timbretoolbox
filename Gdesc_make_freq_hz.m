function [ALLDESC_s] = Gdesc_make_freq_hz(ALLDESC_s,Snd_o)
% GDESC_MAKE_FREQ_HZ
% Uses the sampling rate stored in the Snd_o object to convert the normalized
% frequency metrics into absolute ones.

% Fields to multiply by sample rate 
scale_fields_sr={ 'SpecSpread', 'SpecCent', 'SpecRollOff' };
% According to Peeters (2011) multiplying spectral skewness and kurtosis by the
% sampling rate will have no effect.

% Fields to multiply by 1/sr
scale_fields_1_sr={ 'SpecSlope' };

desc_struct_fields=fieldnames(ALLDESC_s);

% Do sr scaling
for n=(1:length(desc_struct_fields))
    for m=(1:length(scale_fields_sr))
        if (isfield(ALLDESC_s.(char(desc_struct_fields(n))),char(scale_fields_sr(m))))
            ALLDESC_s.(char(desc_struct_fields(n))).(char(scale_fields_sr(m)))=...
                ALLDESC_s.(char(desc_struct_fields(n))).(char(scale_fields_sr(m))).*FGetSampRate(Snd_o);
        end
    end
end

% Do 1/sr scaling
for n=(1:length(desc_struct_fields))
    for m=(1:length(scale_fields_1_sr))
        if (isfield(ALLDESC_s.(char(desc_struct_fields(n))),char(scale_fields_1_sr(m))))
            ALLDESC_s.(char(desc_struct_fields(n))).(char(scale_fields_1_sr(m)))=...
                ALLDESC_s.(char(desc_struct_fields(n))).(char(scale_fields_1_sr(m)))./FGetSampRate(Snd_o);
        end
    end
end

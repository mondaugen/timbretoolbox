function [ALLDESC_Hz_s] = Gdesc_make_freq_hz(ALLDESC_s,Snd_o)
% GDESC_MAKE_FREQ_HZ
% Uses the sampling rate stored in the Snd_o object to convert the normalized
% frequency metrics into absolute ones.

% Fields to multiply by sample rate 
scale_fields={
    "SpecCent"
    "SpecSpread"
% According to Peeters (2011) multiplying spectral skewness and kurtosis by the
% sampling rate will have no effect.
};
desc_struct_fields=fieldnames(ALLDESC_s);
for n=(1:length(desc_struct_fields))
%    sub_struct_fields=fieldnames(get_field(ALLDESC_s,desc_structs_fields(n)));
    sub_desc_struct=getfield(ALLDESC_s,desc_struct_fields(n));
    for m=(1:length(scale_fields))
        if (isfield(sub_desc_struct,scale_fields(m)))
            field_value=getfield(sub_desc_struct,scale_fields(m));
            setfield(sub_desc_struct,scale_fields(m), ...
                field_value .* FGetSampRate(Snd_o));
        end
    end
    setfield(ALLDESC_s,desc_struct_fields(n),sub_desc_struct);
end

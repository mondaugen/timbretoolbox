function [ALLDESCSTATS_s] = Gget_statistics(ALLDESC_s)
% GGET_STATISTICS
%
% Input:
% ALLDESC_S      - The structure containing fields collecting descriptors
%                  according to different representations (i.e., the structure
%                  output by Gget_desc_onefile).
%
% Output:
% ALLDESCSTATS_s - A structure similar to ALLDESC_s but each field in the
%                  output struct will now be a struct with the fields median,
%                  iqr, etc.  containing the the fields contained in each sub
%                  structure in the original, but whose values are instead
%                  statistics computed from them.
ALLDESCSTATS_s=struct();
% A structure of statistical metric name and computation method
computed_stats            = struct();
computed_stats.median     = 'median(%s)';
computed_stats.iqr        = 'iqr(%s)';
% See note in _doc_timbretoolbox.txt on scaled inter-quartile range
computed_stats.iqr_normal = '0.7413*iqr(%s)';
computed_stats.mean       = 'mean(%s)';

for fname_n=fieldnames(ALLDESC_s).'
    for stat_name=fieldnames(computed_stats)'
        stat_field_name=[char(fname_n) '_' char(stat_name)];
        ALLDESCSTATS_s.(stat_field_name) = struct();
        for fname_m=fieldnames(ALLDESC_s.(char(fname_n))).'
            % only compute if field's value's type is 'double'
            if strcmp(class(ALLDESC_s.(char(fname_n)).(char(fname_m))),'double')
                ALLDESCSTATS_s.(stat_field_name).(char(fname_m)) = ...
                    eval(sprintf(computed_stats.(char(stat_name)), ...
                        char(['ALLDESC_s.' char(fname_n) '.' char(fname_m)])));
            end
        end
    end
end

function [info] = FGetSFInfo(filename,what)
% FGETSFINFO
% Returns the piece of information queried from the audiofile.
%
% filename - path to sound file.
% what     - what piece of information to get. Can be: 'size'.

% Get file type from filename suffix.
pos_v			= findstr(filename, '.');
filetype        = filename(pos_v(end)+1:end);
if strcmp(filetype,'raw')
    error('No information is available for raw files.');
end
switch what
    case 'size'
        info=[0 0];
        switch filetype
            case 'aiff'
                info=allread(filename,'size');
            otherwise
                info__=audioinfo(filename);
                info=[info__.TotalSamples info__.NumChannels];
        end
    otherwise
        error(sprintf('%s not a valid piece of information to query.',what));
end

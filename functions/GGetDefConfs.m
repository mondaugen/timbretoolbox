function [s]=GGetDefConfs()
% Contains the outputs for *_FGetDefaultConfig for all the input
% representations. These can be used to, for example, populate GUIs. Each
% item of the resulting cell array contains a field "_settable" which indicates
% if a user can or cannot set a field with a 1 or 0 resp.
strs=dir('classes/');
s={};
k=1;
for n=1:length(strs)
    [dir_,file_]=fileparts(strs(n).name);
    m=strfind(file_,'_FGetDefaultConfig');
    if (length(m) > 0)
        s{k}=eval(sprintf('%s()',file_));
        s{k}.Name=file_(1:(m(1)-1));
        k =k+1;
    end
end


function [s]=GGetDefConfs()
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


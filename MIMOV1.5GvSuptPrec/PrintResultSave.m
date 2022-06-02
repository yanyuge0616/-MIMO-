function [LocalErrors LocalMSE LocalBlckErrors]=PrintResultSave(AlgoName,N,errors,MSE,measureMSE)

fprintf(strcat('\n Current block errors- ',AlgoName,':\n'));
disp(errors);
if N~=1
    LocalMSE=sum(MSE);
    LocalErrors=sum(errors);
else
    LocalMSE=(MSE);
    LocalErrors=(errors);
end
if measureMSE
    if strcmp({AlgoName},'GvH')==0
        fprintf(strcat('\n Current block MSE- ',AlgoName,':\n'));
        disp(MSE);
    end
end
if errors ~=0
    LocalBlckErrors=1;      %≈–∂œ≤ª ’¡≤øÈ
else
    LocalBlckErrors=0;
end
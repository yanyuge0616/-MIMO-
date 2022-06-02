function [mes_out] = BP_demapper(mes_in_mean, mes_in_var, mes_in_bits,ModOrder)

[meaning coordinateset]=Modulation(ModOrder);

numSymbols = length(mes_in_mean);

mes_out = -Inf*ones(numSymbols*ModOrder,2);

for symInd=1:numSymbols
    mean = mes_in_mean(symInd);
    var = mes_in_var(symInd);
    incom_mes = mes_in_bits((symInd-1)*ModOrder+1:symInd*ModOrder,:);
    outg_mes = mes_out((symInd-1)*ModOrder+1:symInd*ModOrder,:);
    
    for pointInd=1:2^ModOrder
        dist = -abs(mean-coordinateset(pointInd)).^2/var;
        for bitInd=1:ModOrder
            incom_mes(bitInd,:)=incom_mes(bitInd,:)-max(incom_mes(bitInd,:));
            dist = dist+incom_mes(bitInd,meaning(bitInd,pointInd)+1);
        end
        for bitInd=1:ModOrder
            outg_mes(bitInd,meaning(bitInd,pointInd)+1)=max_special(outg_mes(bitInd,meaning(bitInd,pointInd)+1),...
                dist-incom_mes(bitInd,meaning(bitInd,pointInd)+1));
        end
    end
    mes_out((symInd-1)*ModOrder+1:symInd*ModOrder,:) = outg_mes;
end
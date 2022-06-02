function pilot_added = pilot_insert(st_coded,Idx_pilot,PilotValue)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 加入导频.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_sym=size(st_coded,2);%OFDM符号数
N_Tx_ant=size(st_coded,3);%发送天线数
for n=1:N_Tx_ant
    for m=1:N_sym
        st_coded(Idx_pilot,m,n) = PilotValue;%在频域插入导频
    end
end                 %每副天线上的OFDM符号均插入导频

pilot_added = st_coded;
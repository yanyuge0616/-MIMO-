function pilot_added = pilot_insert(st_coded,Idx_pilot,PilotValue)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���뵼Ƶ.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_sym=size(st_coded,2);%OFDM������
N_Tx_ant=size(st_coded,3);%����������
for n=1:N_Tx_ant
    for m=1:N_sym
        st_coded(Idx_pilot,m,n) = PilotValue;%��Ƶ����뵼Ƶ
    end
end                 %ÿ�������ϵ�OFDM���ž����뵼Ƶ

pilot_added = st_coded;
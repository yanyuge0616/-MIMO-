function [transmit_signal, training] = add_training(transmit_signal,PrefixRatio,...
    N_subc,N_used, Idx_used,cp_len, N_Tx_ant,N_tran_sym)

% 1024��FFT��ǰ������
% �������ߵ�ѵ������(ͬ��֡),������OFDM����
training = zeros(N_subc,N_tran_sym,N_Tx_ant);
% ����α������У�����ѵ��OFDM���ŵĵ�Ƶλ��.
PN_seq = mseq(10, [1 2 6 10], ones(1,10), N_Tx_ant*3);
PN_seq = 2*PN_seq - 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������1��ѵ��OFDM����
Repeat = 8; % Ϊ��֤��ʱ�����ظ�Repeat��, ��Ƶ�������������ݵ����ز����(Repeat-1)����
for ant = 1:N_Tx_ant
    real_part = PN_seq( (ant-1)*N_Tx_ant + 1,1:N_used/Repeat ); % ��ȡPN����
    imag_part = PN_seq( (ant-1)*N_Tx_ant + 2,1:N_used/Repeat );
    
    tran_tmp1 =  sqrt(Repeat/2) * ( real_part + j * imag_part );
    tmp1 = [ tran_tmp1 ; zeros(Repeat-1,N_used/Repeat) ];
    tmp2 = reshape(tmp1, N_used, 1);
    tmp3 = [ tmp2(1:N_used/2) ; flipud(tmp2(N_used/2 + 1:end))];
    training(Idx_used,1,ant) = tmp3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������2��ѵ��OFDM����, ��ż�������ز��Ϸ�α�������

Repeat = 2;
for ant = 1:N_Tx_ant
    tran_tmp1 = PN_seq( 2*N_Tx_ant + ant,1:N_used/Repeat ); % ��ȡPN����    
    tmp1 = [ tran_tmp1 ; zeros(Repeat-1,N_used/Repeat) ];
    tmp2 = reshape(tmp1, N_used, 1);
    tmp3 = [ tmp2(1:N_used/2) ; flipud(tmp2(N_used/2 + 1:end))];
    training(Idx_used,2,ant) = tmp3;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����ʱ��ѵ������

syn_frame = sqrt(N_subc) * ifft( fftshift( training , 1 ) );
cp = syn_frame(N_subc - cp_len + 1:N_subc ,:,:);
training_frame = [cp;syn_frame];
training_frame = reshape(training_frame,[1, (N_subc + cp_len)*N_tran_sym ,N_Tx_ant]);

transmit_signal = [ training_frame transmit_signal ];


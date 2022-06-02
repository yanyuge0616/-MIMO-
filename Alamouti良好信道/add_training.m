function [transmit_signal, training] = add_training(transmit_signal,PrefixRatio,...
    N_subc,N_used, Idx_used,cp_len, N_Tx_ant,N_tran_sym)

% 1024点FFT的前导序列
% 多条天线的训练序列(同步帧),各两个OFDM符号
training = zeros(N_subc,N_tran_sym,N_Tx_ant);
% 产生伪随机序列，放在训练OFDM符号的导频位置.
PN_seq = mseq(10, [1 2 6 10], ones(1,10), N_Tx_ant*3);
PN_seq = 2*PN_seq - 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 产生第1个训练OFDM符号
Repeat = 8; % 为保证在时域上重复Repeat次, 在频域上两个有数据的子载波间插(Repeat-1)个零
for ant = 1:N_Tx_ant
    real_part = PN_seq( (ant-1)*N_Tx_ant + 1,1:N_used/Repeat ); % 截取PN序列
    imag_part = PN_seq( (ant-1)*N_Tx_ant + 2,1:N_used/Repeat );
    
    tran_tmp1 =  sqrt(Repeat/2) * ( real_part + j * imag_part );
    tmp1 = [ tran_tmp1 ; zeros(Repeat-1,N_used/Repeat) ];
    tmp2 = reshape(tmp1, N_used, 1);
    tmp3 = [ tmp2(1:N_used/2) ; flipud(tmp2(N_used/2 + 1:end))];
    training(Idx_used,1,ant) = tmp3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 产生第2个训练OFDM符号, 在偶数的子载波上放伪随机序列

Repeat = 2;
for ant = 1:N_Tx_ant
    tran_tmp1 = PN_seq( 2*N_Tx_ant + ant,1:N_used/Repeat ); % 截取PN序列    
    tmp1 = [ tran_tmp1 ; zeros(Repeat-1,N_used/Repeat) ];
    tmp2 = reshape(tmp1, N_used, 1);
    tmp3 = [ tmp2(1:N_used/2) ; flipud(tmp2(N_used/2 + 1:end))];
    training(Idx_used,2,ant) = tmp3;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 产生时域训练序列

syn_frame = sqrt(N_subc) * ifft( fftshift( training , 1 ) );
cp = syn_frame(N_subc - cp_len + 1:N_subc ,:,:);
training_frame = [cp;syn_frame];
training_frame = reshape(training_frame,[1, (N_subc + cp_len)*N_tran_sym ,N_Tx_ant]);

transmit_signal = [ training_frame transmit_signal ];


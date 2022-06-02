function [transmit_signal] = ofdm_mod(st_coded,PrefixRatio,N_subc,N_sym,...
                            N_used,Idx_used,N_Tx_ant,N_tran_sym)
                        %function [transmit_signal, known_training] = ofdm_mod(st_coded,PrefixRatio,N_subc,N_sym,...
                           % N_used,Idx_used,N_Tx_ant,N_tran_sym)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 实现OFDM的基本调制

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

transmit_signal = zeros(1,N_subc*N_sym*(1+PrefixRatio),N_Tx_ant);
cp_len = round(PrefixRatio*N_subc);

for ant = 1:N_Tx_ant
    % ifft乘sqrt(N_subc)以保证变换前后能量不变
    % 我们假设频域的样点是在[-fs/2  fs/2]中的, fs是采样频率
    % 使用fftshift函数目的是使得变换前的频域样点转换到[0 fs]中,以满足IFFT变换的要求
    
    %%%原代码
    ofdm_frame = sqrt(N_subc) * ifft( fftshift( st_coded(:,:,ant), 1 ) );%按列进行IFFT计算
    
%     ofdm_frame = sqrt(N_subc) * ifft(
%     fftshift(st_coded(:,:,ant),1),N_subc);%按列进行IFFT计算，我自己写的

    cp = ofdm_frame(N_subc - cp_len + 1:N_subc ,:);
    ofdm_frame = [cp;ofdm_frame];
    % 加窗处理
    
    
    % 转换为串行信号
    transmit_signal(:,:,ant) = reshape( ofdm_frame, 1, N_subc*N_sym*(1+PrefixRatio) );    
    
end
   


% 加前导序列,两个OFDM符号,作为定时同步和信道估计使用
%[transmit_signal, known_training] = add_training(transmit_signal,PrefixRatio,N_subc,N_used,...
                        %Idx_used,cp_len,N_Tx_ant,N_tran_sym);



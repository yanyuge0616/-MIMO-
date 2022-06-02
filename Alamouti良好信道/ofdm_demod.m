function [data_sym] = ofdm_demod(fine_freq_out,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant)
%function [training_sym ,data_sym] =
%ofdm_demod(fine_freq_out,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 实现OFDM的基本解调

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%training_sym = zeros(N_subc,1,N_Rx_ant);%第一个符号为训练序列符号
data_sym = zeros(N_subc,N_sym,N_Rx_ant);
cp_len = round(PrefixRatio*N_subc);

for ant = 1:N_Rx_ant
    ofdm_tmp = reshape( fine_freq_out(1,:,ant), N_subc*(1+PrefixRatio) , N_sym + N_tran_sym  );
    cp_cut = ofdm_tmp( cp_len + 1:end,: );
    % fft乘1/sqrt(N_subc)以保证变换前后能量不变
    % 我们假设频域的样点是在[-fs/2  fs/2]中的, fs是采样频率
    % fftshift目的是使得变换后的频域样点在[-fs/2  fs/2]中,而不是[0 fs]中
    ofdm_sym(:,:,ant) = fftshift(1/sqrt(N_subc) * fft( cp_cut ), 1);
end

%training_sym = ofdm_sym(:,1,:);             % 用于信道估计的训练符号
data_sym = ofdm_sym(:, 1:N_sym ,:);     % 数据OFDM符号, 包括导频符号


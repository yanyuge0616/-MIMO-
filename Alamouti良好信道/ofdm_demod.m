function [data_sym] = ofdm_demod(fine_freq_out,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant)
%function [training_sym ,data_sym] =
%ofdm_demod(fine_freq_out,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ʵ��OFDM�Ļ������

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%training_sym = zeros(N_subc,1,N_Rx_ant);%��һ������Ϊѵ�����з���
data_sym = zeros(N_subc,N_sym,N_Rx_ant);
cp_len = round(PrefixRatio*N_subc);

for ant = 1:N_Rx_ant
    ofdm_tmp = reshape( fine_freq_out(1,:,ant), N_subc*(1+PrefixRatio) , N_sym + N_tran_sym  );
    cp_cut = ofdm_tmp( cp_len + 1:end,: );
    % fft��1/sqrt(N_subc)�Ա�֤�任ǰ����������
    % ���Ǽ���Ƶ�����������[-fs/2  fs/2]�е�, fs�ǲ���Ƶ��
    % fftshiftĿ����ʹ�ñ任���Ƶ��������[-fs/2  fs/2]��,������[0 fs]��
    ofdm_sym(:,:,ant) = fftshift(1/sqrt(N_subc) * fft( cp_cut ), 1);
end

%training_sym = ofdm_sym(:,1,:);             % �����ŵ����Ƶ�ѵ������
data_sym = ofdm_sym(:, 1:N_sym ,:);     % ����OFDM����, ������Ƶ����


function [transmit_signal] = ofdm_mod(st_coded,PrefixRatio,N_subc,N_sym,...
                            N_used,Idx_used,N_Tx_ant,N_tran_sym)
                        %function [transmit_signal, known_training] = ofdm_mod(st_coded,PrefixRatio,N_subc,N_sym,...
                           % N_used,Idx_used,N_Tx_ant,N_tran_sym)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ʵ��OFDM�Ļ�������

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

transmit_signal = zeros(1,N_subc*N_sym*(1+PrefixRatio),N_Tx_ant);
cp_len = round(PrefixRatio*N_subc);

for ant = 1:N_Tx_ant
    % ifft��sqrt(N_subc)�Ա�֤�任ǰ����������
    % ���Ǽ���Ƶ�����������[-fs/2  fs/2]�е�, fs�ǲ���Ƶ��
    % ʹ��fftshift����Ŀ����ʹ�ñ任ǰ��Ƶ������ת����[0 fs]��,������IFFT�任��Ҫ��
    
    %%%ԭ����
    ofdm_frame = sqrt(N_subc) * ifft( fftshift( st_coded(:,:,ant), 1 ) );%���н���IFFT����
    
%     ofdm_frame = sqrt(N_subc) * ifft(
%     fftshift(st_coded(:,:,ant),1),N_subc);%���н���IFFT���㣬���Լ�д��

    cp = ofdm_frame(N_subc - cp_len + 1:N_subc ,:);
    ofdm_frame = [cp;ofdm_frame];
    % �Ӵ�����
    
    
    % ת��Ϊ�����ź�
    transmit_signal(:,:,ant) = reshape( ofdm_frame, 1, N_subc*N_sym*(1+PrefixRatio) );    
    
end
   


% ��ǰ������,����OFDM����,��Ϊ��ʱͬ�����ŵ�����ʹ��
%[transmit_signal, known_training] = add_training(transmit_signal,PrefixRatio,N_subc,N_used,...
                        %Idx_used,cp_len,N_Tx_ant,N_tran_sym);



%%%%%����˵����MIMO+OFDM�Ļ������棬��������������
%%%%%%���γ����ڻ������棬��û����������˲�+���ز���һ��
%%%%%%***************** ���Ͷ� ***************
%%%%%% ���Ͷ˲���Alamouti���룬��2������
%%%%%% ��4���û���ÿ���û�ռ�õ����ز���һ����adpt_mod_para�����û�ռ�����ز��ķ��䷽ʽAllocMethod
%%%%%% ���Ʒ�ʽ��ÿ���û�����������ز����н�����ͬ�ĵ��Ʒ�ʽ��QPSK/8PSK/16QAM����/64QAM
%%%%%%  �ŵ����룺��
%%%%%% ***************** �ŵ� ***************
%%%%%% ���ø�˹�������ŵ���δ����ྶ�ŵ�
%%%%%% ***************** ���ն� ***************
%%%%%% ���ն���2�����ߣ���Ҫ��Alamouti����
%%%%%% ���ն�δ������Ƶƫ���ơ���ʱ���ơ��ŵ����ƣ���Ϊ�ŵ��Ƚ�����
%%%%%% �뷢�Ͷ����ݱȶԣ�����������������
%%%%%% ***************** ������˵�� ***************
%%%%%% ��1����ÿ��������½��з��棬����10֡�źţ�һ֡Ϊ10��OFDM���ţ�һ��OFDM���ŵ�IFFT����Ϊ1024
%%%%%% ��2��4���û���ʹ��600�����ز���24�����ز����͵�Ƶ��576�����ز���������
%%%%%%   ��˵�Ƶ������600/24=25�������ÿ���û�144���ز�
%%%%%% ��3��ÿ���û��뷢������5760bit�����576bit/OFDM���ţ����ݵ��ƽ����������Ҫռ�ݵ����ز�����
%%%%%% ��4����16QAMΪ����576bit = 144���������ţ���Ҫռ144�����ز����루2���պö�Ӧ��

clear all;
close all;
N_Tx_ant = 2;  %��������Ϊ2
N_Rx_ant = 2;  %��������Ϊ2
N_user = 4;    %�û���Ϊ4

N_sym = 10;     %  ÿ֡��OFDM������,����������ǰ׺OFDM���� LTE��һ֡����Ϊ6~7��OFDM����
N_frame = 10;   %  �����֡����
% ����ѭ����ʼ��Eb_No,����Ϊÿ���ص�����Eb
% �������ĵ��߹������ܶ�No�ı�ֵ, dBֵ
Eb_NoStart = 0;
Eb_NoInterval = 2;      % ����Eb/No�ļ��ֵ(dB)
Eb_NoEnd = 20;          % ����Eb/No����ֵֹ(dB)
%�������ѡ�����LTEϵͳ����Ϊ10MHzʱ����

%%%%�����⼸������ò��û���õ�
fc = 5e9;                               %  �ز�Ƶ��(Hz)   5GHz
Bw = 20e6;                              %  ����ϵͳ����(Hz) 10MHz
fs = 15.36e6;                           %  ��������Ƶ�� 1024*15KHz=15360000Hz
T_sample = 1/fs;                        %  ����ʱ��������(s)


N_subc = 1024;                          %  OFDM ���ز���������FFT����
Idx_used = [-300:-1 1:300];             %  ʹ�õ����ز���ţ�һ��ʹ��600�����ز�
Idx_pilot = [-300:25:-25 25:25:300];    %  ��Ƶ���ز����,��Ƶ���Ϊ24����Ӧ������Ϊ0�����ز���ӳ�����ݻ��ߵ�Ƶ��Ϊ��LTE��׼
N_used = length(Idx_used);              % ʹ�õ����ز��� 600
N_pilot = length(Idx_pilot);            % ��Ƶ�����ز���
N_data = N_used - N_pilot;              % һ��OFDM�����������û����͵����ݵ����ز���
Idx_data = zeros(1,N_data);
N_tran_sym = 0;                         %ǰ�����еĳ��� �˴�Ϊ�����ǰ������
% �õ��������ز��ı��
m = 1;
n = 1;
for k  = 1:length(Idx_used)
    if Idx_used(k) ~= Idx_pilot(m)
        Idx_data(n) = Idx_used(k);
        n = n + 1;
    else
        if m ~= N_pilot
            m = m + 1;
        end
    end
end
%  Ϊ���ʹ�÷���,�������ز����Ϊ��1��ʼ,�����ز����� length(Idx_used) = length(Idx_pilot) + length(Idx_data) 
Idx_used = Idx_used + N_subc/2 +1;    %ʹ�õ����ز�����
Idx_pilot = Idx_pilot + N_subc/2 +1;  %��Ƶ���ز�����
Idx_data = Idx_data + N_subc/2 +1;    %�������ز�����

PilotValue = ones(N_pilot,1);%��ƵֵΪȫ1
PrefixRatio = 1/4;           %ѭ��ǰ׺��ռ��������256��������
T_sym = T_sample*( (1 + PrefixRatio)*N_subc );%һ��OFDM���ţ�����ѭ��ǰ׺���ĳ���ʱ��
Modulation = 6; %���Ʒ�ʽѡ��2--QPSK����, 3--8PSK,4--16QAM����,6--64QAM
Es = 1;                 % ��QPSK, 16QAM���Ʒ�ʽ��,��������������һ��
Eb = Es/Modulation;     % ÿ��������
N_ant_pair = N_Tx_ant * N_Rx_ant;   % �շ����߶Ե���Ŀ
ST_Code = 1;   % ��ʱ���룺 , 1--��ʱ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

snr_idx = 1;
for Eb_No_dB = Eb_NoStart:Eb_NoInterval:Eb_NoEnd
    Eb_No = 10^(Eb_No_dB/10);       %���������
    var_noise = Eb/(2*Eb_No);       % ��������Ĺ���   NoΪ���߹��� No=2*var_noise
    for frame = 1:N_frame          %��֡ѭ������
        %%%%%*********************  ���Ͷ�  **************%%%
        %����Ӷྶ�ŵ������������Ӧ���룬���ŵ����Ƶ�
        %%%% ���ز���
        [user_bit,user_bit_cnt]  = user_bit_gen( N_user, N_data ,N_sym , Modulation );% ���û���������ģ�飬ÿ���û�һ֡������
        %%%% �ŵ�����,��
        coded_user_bit=user_bit;%���ŵ����룬RS�룬������
        
        %%%% ���ز����� 
        AllocMethod=1;%���ڷ���
        [user_subc_alloc,mod_subc,pwr_subc,pad_bit_cnt]=adpt_mod_para(coded_user_bit,N_sym,Idx_data,AllocMethod);
        TurnOn.AdptMod=0;%������Ӧ����
        
        %%%% ���ո�����ÿ�û�,ÿ���ز��ĵ��Ʒ�ʽ,���е���
        mod_sym =  modulator(coded_user_bit,user_subc_alloc,mod_subc,pwr_subc,pad_bit_cnt,N_subc,N_sym,TurnOn.AdptMod);
        
        %%%% ���ͷּ�, ʹ�ÿ�ʱ����
        st_coded = st_coding( mod_sym,N_Tx_ant,ST_Code);
        
        % �ӵ�Ƶ
        pilot_added = pilot_insert(st_coded,Idx_pilot,PilotValue);
        
        % OFDM����,��ѭ��ǰ׺����ǰ������. ���ʹ�÷��ͷּ�,������������ߵ��ź�
        %%%%%ʵ�ʺ����в����ǰ������
        [transmit_signal] = ofdm_mod(pilot_added,PrefixRatio,N_subc,N_sym,N_used,Idx_used,N_Tx_ant,N_tran_sym);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �ŵ�  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        transmit_signal_power = var(transmit_signal);%�����źŹ���
        length_noise=size(transmit_signal,2);
        noise=gausnoise(Eb_No_dB,transmit_signal_power,length_noise);%��������������
        recv_signal =  transmit_signal+noise;%���յ����źż�����
        
        %%%%%%%%%%%%%%%%%%%*********************  ���ն�  **************%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for u = 1:N_user        % ����û����ջ���ѭ��
            %���ŵ����ƣ�ͬ����
            
            % OFDM���
            data_sym = ofdm_demod(recv_signal,PrefixRatio,N_subc,N_sym,N_tran_sym,N_Rx_ant);
            
            % ���ջ��ּ�����Ϳ�ʱ����
            channel_est = ones(N_subc,1,N_ant_pair);%����Ϊ�����ŵ����ŵ�����Ϊȫ1����
            st_decoded = st_decoding( data_sym,channel_est,N_Tx_ant, N_Rx_ant ,ST_Code ,Idx_data);%2X2MIMO
            
            % ����ÿ�û�,ÿ���ز��ĵ��Ʒ�ʽ,���н��
            demod_user_bit = demodulator(st_decoded,user_subc_alloc{u},mod_subc{u},pad_bit_cnt(u),N_sym,TurnOn.AdptMod);
            
            %���ŵ�����, ����RS����, �����Viterbi�����
            decoded_user_bit{u}= demod_user_bit;
            
            % ��֡,���������,���û�������ͳ��
            bit_err = sum(abs(decoded_user_bit{u} - user_bit{u}));%�����ʼ���
            user_bit_err{u}(frame,snr_idx) = bit_err ;
        end  % ����û����ջ���ѭ������
    end     % OFDM֡/���ݰ�ѭ������
    snr_idx = snr_idx + 1;
end      % Eb/No�����ѭ������
performance_eval;% ��ͼ
%%%%ʵ���� 
%%%����ʵ��û���ŵ����룬���ն�û��Ƶƫ���ơ���ʱͬ�����ŵ����ơ��ŵ�����Ȳ���



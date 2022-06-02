function   st_decoded = st_decoding( Recv,channel_est,N_Tx_ant, N_Rx_ant ,ST_Code, Idx_data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʱ����ͷּ�����

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


N_subc = size(Recv,1);%���ز���
N_sym = size(Recv,2);%������
st_decoded = zeros(N_subc, N_sym);
% ��H_freqת��Ϊ��ʱ�������������ʽ,Ϊһ��N_subc*N_ant_pair�ľ���,ÿ�б�ʾ:
% 1-->1 ,1-->2,...,1-->N_Rx_ant, ... ,N_Tx_ant-->1, N_Tx_ant-->2,..., N_Tx_ant-->N_Rx_ant

H = squeeze(channel_est(:,1,:));
%H=ones(N_subc,N_ant_pair );%����Ϊ�����ŵ���ȫ1����

% ���û�з��ͷּ�,��ʱ����
if N_Tx_ant == 1
    if N_Rx_ant ~= 1
        
        % ���Ⱥϲ�, ÿ���������ݵļ�ȨΪ�����ߵ��ŵ���Ӧ
        numerator = zeros(length(Idx_data),N_sym);
        denominator = zeros(length(Idx_data),N_sym);
        for n_r = 1:N_Rx_ant
             numerator = numerator + Recv(Idx_data,:,n_r).*conj(repmat(channel_est(Idx_data,1,n_r),1,N_sym));
             denominator = denominator + abs(repmat(channel_est(Idx_data,1,n_r),1,N_sym)).^2;
        end
        st_decoded(Idx_data,:) = numerator./denominator;
        
        
    else
        %st_decoded(Idx_data,:) = Recv(Idx_data,:)./repmat(channel_est(Idx_data),1,N_sym);
        st_decoded(Idx_data,:) = Recv(Idx_data,:).*conj(repmat(channel_est(Idx_data),1,N_sym))...
                                    ./abs(repmat(channel_est(Idx_data),1,N_sym)).^2;
        % st_decoded = Recv; % ����
    end

% ����з��ͷּ�
else
% ���ʹ�ÿ�ʱ������
    if ST_Code == 1
    
        if (N_Tx_ant == 2)&(N_Rx_ant == 1)
            % ��2��1��STBC����
        
        elseif (N_Tx_ant == 2)&(N_Rx_ant == 2)
            % 2��2��STBC����

            % ���շ��Ű���N_sym/N_Tx_ant ��������
            for n = 1:N_sym/N_Tx_ant % 1��10/2=1:5
                % �����������ʱ�������ķ���,��t��ʾʱ���,a��ʾ���ߺ�,���ʽΪ:
                % [Recv(t1,a1) Recv(t2,a1) Recv(t1,a2) Recv(t2,a2)].
                R = [];
                for ant = 1:N_Rx_ant
                    R = [R  Recv(:,(n-1)*N_Tx_ant+1:n*N_Tx_ant,ant) ];%����2X2MIMO��˵��R����Ϊ[Xe  -conj(Xo)  Xo  conj(Xe)]
                end
                output = stbc_decode_TX2RX2(H,R);
                st_decoded(:,(n-1)*N_Tx_ant+1:n*N_Tx_ant) = output;
            end


        elseif (N_Tx_ant == 2)&(N_Rx_ant == 4)
            % 2��4��STBC����
            output=stbc_decode_TX2RX4(H,R)

        elseif (N_Tx_ant == 4)&(N_Rx_ant == 4)
            % 2��4��STBC����
            output=stbc_decode_TX4RX4(H,R)
    
        else
            st_decoded = input;
        end
    
        
% ʹ�ÿ�ʱ����    
    elseif ST_Code == 2
    
    end

end
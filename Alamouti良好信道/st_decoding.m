function   st_decoded = st_decoding( Recv,channel_est,N_Tx_ant, N_Rx_ant ,ST_Code, Idx_data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 空时解码和分集处理

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


N_subc = size(Recv,1);%子载波数
N_sym = size(Recv,2);%符号数
st_decoded = zeros(N_subc, N_sym);
% 把H_freq转化为空时译码器的输入格式,为一个N_subc*N_ant_pair的矩阵,每列表示:
% 1-->1 ,1-->2,...,1-->N_Rx_ant, ... ,N_Tx_ant-->1, N_Tx_ant-->2,..., N_Tx_ant-->N_Rx_ant

H = squeeze(channel_est(:,1,:));
%H=ones(N_subc,N_ant_pair );%假设为理想信道，全1矩阵

% 如果没有发送分集,空时编码
if N_Tx_ant == 1
    if N_Rx_ant ~= 1
        
        % 最大比合并, 每条天线数据的加权为该天线的信道响应
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
        % st_decoded = Recv; % 测试
    end

% 如果有发送分集
else
% 如果使用空时分组码
    if ST_Code == 1
    
        if (N_Tx_ant == 2)&(N_Rx_ant == 1)
            % 简单2发1收STBC解码
        
        elseif (N_Tx_ant == 2)&(N_Rx_ant == 2)
            % 2发2收STBC解码

            % 接收符号按照N_sym/N_Tx_ant 组来处理
            for n = 1:N_sym/N_Tx_ant % 1：10/2=1:5
                % 构造输入进空时译码器的符号,用t表示时间号,a表示天线号,其格式为:
                % [Recv(t1,a1) Recv(t2,a1) Recv(t1,a2) Recv(t2,a2)].
                R = [];
                for ant = 1:N_Rx_ant
                    R = [R  Recv(:,(n-1)*N_Tx_ant+1:n*N_Tx_ant,ant) ];%对于2X2MIMO来说，R矩阵即为[Xe  -conj(Xo)  Xo  conj(Xe)]
                end
                output = stbc_decode_TX2RX2(H,R);
                st_decoded(:,(n-1)*N_Tx_ant+1:n*N_Tx_ant) = output;
            end


        elseif (N_Tx_ant == 2)&(N_Rx_ant == 4)
            % 2发4收STBC解码
            output=stbc_decode_TX2RX4(H,R)

        elseif (N_Tx_ant == 4)&(N_Rx_ant == 4)
            % 2发4收STBC解码
            output=stbc_decode_TX4RX4(H,R)
    
        else
            st_decoded = input;
        end
    
        
% 使用空时格码    
    elseif ST_Code == 2
    
    end

end
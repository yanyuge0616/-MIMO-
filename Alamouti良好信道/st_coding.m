function st_coded = st_coding( mod_sym,N_Tx_ant,ST_Code)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 发送分集 , 2发或4发

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[N_subc,N_sym] = size(mod_sym);

% 如果有发送分集
if N_Tx_ant ~= 1
    % 使用空时分组码
    if ST_Code == 1
        st_coded = zeros(N_subc,N_sym, N_Tx_ant);
        if (mod(N_sym,N_Tx_ant))
            error('空时编码器输入符号不匹配,子程序st_coding出错');
        else
            for n = 1:N_sym/N_Tx_ant
                % 一次送入空时编码器的OFDM符号有N_Tx_ant个，如发送天线为2，则一次送入两个OFDM符号进行Alamouti编码
                coded_tmp = stbc_code_TX( mod_sym( :,(n-1)*N_Tx_ant+1 : n*N_Tx_ant ) );
                % coded_tmp的结构: 每列代表一条天线发出的数据,有N_Tx_ant*N_subc
                % 个样点, 而一共有N_Tx_ant列,代表不同天线的数据
                
                % 转化为结构:有 N_subc行, 代表不同时间OFDM符号的N_Tx_ant列,
                % 矩阵第三维为N_Tx_ant个,代表不同天线的数据
                for ant = 1:N_Tx_ant
                    tmp = reshape(coded_tmp(:,ant), N_subc, N_Tx_ant);%第一根天线发送的前两个符号为[Xe,-conj(Xo)]
                    % 把调整后的符号块,放在输出符号的相应位置
                    st_coded(:, (n-1)*N_Tx_ant+1:n*N_Tx_ant ,ant) = tmp;%利用第三维表示不同天线发送的OFDM符号
                end
            end
        end
        
        % 使用空时格码
    elseif ST_Code == 2
        
        
    end
    
    % 如果没有发送分集
else
    st_coded = mod_sym;
end



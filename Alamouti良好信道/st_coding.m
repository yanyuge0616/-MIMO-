function st_coded = st_coding( mod_sym,N_Tx_ant,ST_Code)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ͷּ� , 2����4��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[N_subc,N_sym] = size(mod_sym);

% ����з��ͷּ�
if N_Tx_ant ~= 1
    % ʹ�ÿ�ʱ������
    if ST_Code == 1
        st_coded = zeros(N_subc,N_sym, N_Tx_ant);
        if (mod(N_sym,N_Tx_ant))
            error('��ʱ������������Ų�ƥ��,�ӳ���st_coding����');
        else
            for n = 1:N_sym/N_Tx_ant
                % һ�������ʱ��������OFDM������N_Tx_ant�����緢������Ϊ2����һ����������OFDM���Ž���Alamouti����
                coded_tmp = stbc_code_TX( mod_sym( :,(n-1)*N_Tx_ant+1 : n*N_Tx_ant ) );
                % coded_tmp�Ľṹ: ÿ�д���һ�����߷���������,��N_Tx_ant*N_subc
                % ������, ��һ����N_Tx_ant��,����ͬ���ߵ�����
                
                % ת��Ϊ�ṹ:�� N_subc��, ����ͬʱ��OFDM���ŵ�N_Tx_ant��,
                % �������άΪN_Tx_ant��,����ͬ���ߵ�����
                for ant = 1:N_Tx_ant
                    tmp = reshape(coded_tmp(:,ant), N_subc, N_Tx_ant);%��һ�����߷��͵�ǰ��������Ϊ[Xe,-conj(Xo)]
                    % �ѵ�����ķ��ſ�,����������ŵ���Ӧλ��
                    st_coded(:, (n-1)*N_Tx_ant+1:n*N_Tx_ant ,ant) = tmp;%���õ���ά��ʾ��ͬ���߷��͵�OFDM����
                end
            end
        end
        
        % ʹ�ÿ�ʱ����
    elseif ST_Code == 2
        
        
    end
    
    % ���û�з��ͷּ�
else
    st_coded = mod_sym;
end



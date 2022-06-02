

function mod_sym =  modulator(coded_user_bit,user_subc_alloc,mod_subc,...
                   pwr_subc, pad_bit_cnt ,N_subc ,N_sym, AdptMod);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����: ���������Ӧ����,�������û�,��OFDM����,�����ز�����������
%       �˲���ȽϷ�ʱ, ������Ϊ�������ز����Ʒ�ʽ��ͬ , �޷�ʹ���������е��� 
%       �����û������Ӧ����,��������û�,��OFDM���ŵ���������
%       ʹ���������е���,�ٶȽϿ�
% ����: 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mod_sym = zeros(N_subc,N_sym);
N_user = length(coded_user_bit);
for u = 1:N_user
    % ���ʹ�һ��
    pwr_subc{u} = pwr_subc{u}./( sum(pwr_subc{u}) / length(pwr_subc{u}) );
    % �û��������ݵ�ָ��
    pointer = 1;   
    % �Ȱ���pad_bit_cnt, ��ÿ���û������ݱ������к���
    coded_user_bit{u} = [ coded_user_bit{u} ;zeros(pad_bit_cnt(u),1)];
    % Ȼ����OFDM���ŵ�ѭ��, �Լ����������û����ز���ѭ��
    for n = 1:N_sym
        
        %������Ӧ����
        if AdptMod == 1
            for k = 1:length(user_subc_alloc{u})
                % ��u���û�,��n��OFDM����,��k�����ز����
                subc_k = user_subc_alloc{u}(k);
                % ��Ӧ�ĵ��Ʒ�ʽ
                bit_k = mod_subc{u}(k);
                if bit_k ~= 0
                    % ��Ӧ�Ĺ���
                    pwr_k = pwr_subc{u}(k);
                    % ȡ�����ڵ��Ƶı���
                    bit_to_mod = coded_user_bit{u}( pointer : pointer + bit_k -1);
                    pointer = pointer + bit_k;
                    % �˺������Ը�������ı������г���,���е���
                    sym = modu_sym(bit_to_mod);
                    
                    % ���ܳ���Ӧ�Ĺ�������! ��Ϊ�����QAM����,�˹������ӱ仯��
                    % ����, ���п����д�!!!!            
                    % mod_sym(subc_k, n) = sym * pwr_k; % ����!!
                    mod_sym(subc_k, n) = sym ;          % ��ȷ
                else
                    mod_sym(subc_k, n) = 0;
                end
            end
        %û������Ӧ����    
        else
            % ��ǰ�û�,��ǰOFDM����,�������ز��ı�����(���Ʒ�ʽ��ͬ)
            mod_type = mod_subc{u}(1);%���Ʒ�ʽ
            tmp = length(user_subc_alloc{u})*mod_type;%ÿ���û��ֵ������ز���*���ƽ���������һ��OFDM���Ű����ı�����
            % ȡ�����ڵ��Ƶı���, ���任Ϊmodu_sym�Ͽɵ�������ʽ
            tmp_bit = coded_user_bit{u}(pointer : pointer + tmp - 1);
            pointer = pointer + tmp;
            bit_to_mod = reshape(tmp_bit, mod_type , tmp/mod_type);
            sym = modu_sym (bit_to_mod);
            % ������Ӧ�Ĺ�������, �ѷ��ŷŵ���Ӧ�����ز���
            mod_sym(user_subc_alloc{u}, n) = sym.' .* pwr_subc{u};%���н������ݵ�д�룬ÿһ��Ϊһ��OFDM����
        end
    end
    
end
            

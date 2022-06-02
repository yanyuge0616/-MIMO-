

function mod_sym =  modulator(coded_user_bit,user_subc_alloc,mod_subc,...
                   pwr_subc, pad_bit_cnt ,N_subc ,N_sym, AdptMod);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 功能: 如果有自适应调制,进行逐用户,逐OFDM符号,逐子载波的星座调制
%       此步骤比较费时, 但是因为各个子载波调制方式不同 , 无法使用向量进行调制 
%       而如果没有自适应调制,则进行逐用户,逐OFDM符号的星座调制
%       使用向量进行调制,速度较快
% 输入: 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mod_sym = zeros(N_subc,N_sym);
N_user = length(coded_user_bit);
for u = 1:N_user
    % 功率归一化
    pwr_subc{u} = pwr_subc{u}./( sum(pwr_subc{u}) / length(pwr_subc{u}) );
    % 用户输入数据的指针
    pointer = 1;   
    % 先按照pad_bit_cnt, 在每个用户的数据比特序列后补零
    coded_user_bit{u} = [ coded_user_bit{u} ;zeros(pad_bit_cnt(u),1)];
    % 然后建立OFDM符号的循环, 以及本符号内用户子载波的循环
    for n = 1:N_sym
        
        %有自适应调制
        if AdptMod == 1
            for k = 1:length(user_subc_alloc{u})
                % 第u个用户,第n个OFDM符号,第k个子载波序号
                subc_k = user_subc_alloc{u}(k);
                % 对应的调制方式
                bit_k = mod_subc{u}(k);
                if bit_k ~= 0
                    % 对应的功率
                    pwr_k = pwr_subc{u}(k);
                    % 取出用于调制的比特
                    bit_to_mod = coded_user_bit{u}( pointer : pointer + bit_k -1);
                    pointer = pointer + bit_k;
                    % 此函数可以根据输入的比特序列长度,进行调制
                    sym = modu_sym(bit_to_mod);
                    
                    % 不能乘相应的功率因子! 因为如果是QAM调制,乘功率因子变化了
                    % 幅度, 就有可能判错!!!!            
                    % mod_sym(subc_k, n) = sym * pwr_k; % 错误!!
                    mod_sym(subc_k, n) = sym ;          % 正确
                else
                    mod_sym(subc_k, n) = 0;
                end
            end
        %没有自适应调制    
        else
            % 当前用户,当前OFDM符号,所有子载波的比特数(调制方式相同)
            mod_type = mod_subc{u}(1);%调制方式
            tmp = length(user_subc_alloc{u})*mod_type;%每个用户分到的子载波数*调制进制数，即一个OFDM符号包含的比特数
            % 取出用于调制的比特, 并变换为modu_sym认可的输入形式
            tmp_bit = coded_user_bit{u}(pointer : pointer + tmp - 1);
            pointer = pointer + tmp;
            bit_to_mod = reshape(tmp_bit, mod_type , tmp/mod_type);
            sym = modu_sym (bit_to_mod);
            % 乘上相应的功率因子, 把符号放到对应的子载波上
            mod_sym(user_subc_alloc{u}, n) = sym.' .* pwr_subc{u};%按列进行数据的写入，每一列为一个OFDM符号
        end
    end
    
end
            

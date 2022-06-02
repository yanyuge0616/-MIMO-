
function   [user_subc_alloc , mod_subc ,pwr_subc ,pad_bit_cnt] = adpt_mod_para... 
                ( coded_user_bit,N_sym,Idx_data ,AllocMethod , AdptMethod, H , var_noise, TargetBer );
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 功能:自适应调制和多用户复用

% 输入:     coded_user_bit, 输入用户比特序列,为cell结构
%           N_sym, 本帧中的OFDM符号个数
%           Idx_data, 数据OFDM符号的子载波标号
%           AllocMethod, 子载波分配方法, 1--相邻分配, 2--交织分配, 3---跳频分配,4--自适应子载波分配
%           AdptMethod, 自适应调制方法
%           H, 频域信道响应
%           var_noise, 噪声样点的功率
%           TargetBer, 目标误比特率
%输出:      user_subc_alloc, 用户分配的子载波序号,为cell结构
%           pad_bit_cnt, 为保证用户比特在调制器中能正确调制,需要填充的比特数
%           mod_subc, 用户对应user_subc_alloc子载波上的调制方式,为cell结构
%           pwr_subc, 用户对应user_subc_alloc子载波上的功率,为cell结构 
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 4
    
    % 不使用自适应调制, 对多个用户的数据使用固定的子载波分配方法 , 每个用户的子载波
    % 均使用相同的星座调制方式 ; 不同用户的子载波可能会使用不同的调制方式
    
    N_user = size(coded_user_bit,2);%根据得到的用户数据计算用户数
    num_subc_user = length(Idx_data) / N_user ;   % 平均分配,每个用户的子载波数 Idx_data为数据子载波坐标
    user_subc_alloc = cell(1,N_user);
    mod_subc = cell(1,N_user);
    pwr_subc = cell(1,N_user);
    
    for u = 1:N_user
        % 先计算出为保证所有用户的比特恰好分完, 需要填充的比特数, 在本帧末尾填充零
        % 每个用户每个OFDM符号的比特数
        userbit_sym = length(coded_user_bit{u})/N_sym;     %N_sym为一帧所包含的OFDM符号数
        % 每个用户使用的调制方式
        mod_user = ceil(userbit_sym / num_subc_user);     
         % 调制方式对应: 1--BPSK调制, 2--QPSK调制,3--8PSK调制, 4--16QAM调制,6--64QAM调制
        if mod_user > 6
            error('单个用户比特数太多,无法进行调制,子程序adpt_mod_para出错!');
        elseif mod_user == 5 
            mod_user = 6;                  
        end                                  
        pad_bit_cnt(u) = mod_user * num_subc_user * N_sym - length(coded_user_bit{u}) ;%需要填充的0的个数
    
    
        % 然后根据选择的固定子载波分配方法( 1--相邻分配, 2--交织分配, 3---跳频分配 )
        % 把子载波均匀地分配给用户. 用户的比特数不同, 会造成不同用户的调制方式和
        % 填充比特数的不同
    
        switch AllocMethod
           
        case    1           % 相邻分配 
            %user_subc_alloc((u-1)*num_subc_user + 1: u*num_subc_user) = u;
            user_subc_alloc{u} = Idx_data((u-1)*num_subc_user + 1: u*num_subc_user)';%每个用户的子载波连续分配，不同用户子载波相邻分配，即局域化映射
            mod_subc{u} = mod_user*ones(num_subc_user, 1);
            pwr_subc{u} = ones(num_subc_user,1);
            
        case    2           % 交织分配
            
        case    3           % 跳频分配 
        
        otherwise
        
        end
    
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
    % 使用自适应调制, 多用户子载波分配方法由AllocMethod确定, 自适应调制方法由AdptMethod确定
    
    % 如果使用固定子载波分配方法
    if (AllocMethod == 1) | (AllocMethod == 2) | (AllocMethod == 3)
        
        N_user = size(coded_user_bit,2);
        N_data = length(Idx_data);
        % 平均分配,每个用户的子载波数
        num_subc_user = N_data / N_user;   
        user_subc_alloc = cell(1,N_user);
        mod_subc = cell(1,N_user);
        pwr_subc = cell(1,N_user);
        
        for u = 1:N_user
            
            % 先计算出,为保证每个用户每个OFDM符号的比特数为调整步长的整数倍, 需要填充的比特数
            % 如果使用基于功率梯度最小的QAM 算法, 分配给各子载波的比特数为0,2,4,6, 步长为2
            step = 2;
            
            % 每个用户本帧需要填充的比特数      
            if mod(length(coded_user_bit{u}) , step*N_sym) ~= 0
                pad_bit_cnt(u) = step*N_sym - mod(length(coded_user_bit{u}) , step*N_sym);
            else
                pad_bit_cnt(u) = 0;
            end
            
            % 每个用户每个OFDM符号的比特数
            num_userbit_sym = (length(coded_user_bit{u}) + pad_bit_cnt(u))/N_sym;
   
            switch AllocMethod
                case    1           % 相邻分配
                    %user_subc_alloc((u-1)*num_subc_user + 1: u*num_subc_user) = u;
                    user_subc_alloc{u} = Idx_data((u-1)*num_subc_user + 1: u*num_subc_user)';
                    %mod_subc{u} = mod_user*ones(num_subc_user, 1);
                    %pwr_subc{u} = ones(num_subc_user,1);
            
                case    2           % 交织分配
            
                case    3           % 跳频分配 
        
                otherwise
            end
            
            % 当前用户对应子载波的信道相应
            H_user = H{u}(user_subc_alloc{u},1,1);             
            
            switch AdptMethod
                % 自适应调制方法1, 给功率增加最小的子载波分配比特和功率
                case    1               
                    [mod_subc{u},pwr_subc{u}]=adaptive_power1(H_user,TargetBer,...
                                          num_subc_user,var_noise,num_userbit_sym);
                                      
                % 自适应调制方法2, 给误比特性能降低最小的子载波分配比特和增加功率
                case    2              
                    
                % 自适应调制方法3, 按照信道响应降序排列,子载波间争夺比特( 功率?? )
                case    3               
                    mod_subc{u} =adaptive(H_user,num_subc_user,num_userbit_sym);
                    pwr_subc{u} = ones(num_subc_user,1);
                    
                otherwise
            end
    
        end
        
    elseif  (AllocMethod == 4)           % 自适应子载波分配
        
        % 自适应子载波和比特功率分配
        for u = 1:N_user
            % 先计算需要填充的比特数
            step = 2;
            % 每个用户本帧需要填充的比特数              
            pad_bit_cnt(u) = step*N_sym - mod(length(coded_user_bit{u}) , step*N_sym);
            % 每个用户每个OFDM符号的比特数
            num_userbit_sym(u) = (length(coded_user_bit{u}) + pad_bit_cnt(u))/N_sym;
        end
        % 此函数未写
        adaptive_pwr_subc ( H(:,1) ,N_data, var_noise, num_userbit_sym );
        
    end
    
end    
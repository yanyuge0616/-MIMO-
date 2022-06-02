
function   [user_subc_alloc , mod_subc ,pwr_subc ,pad_bit_cnt] = adpt_mod_para... 
                ( coded_user_bit,N_sym,Idx_data ,AllocMethod , AdptMethod, H , var_noise, TargetBer );
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����:����Ӧ���ƺͶ��û�����

% ����:     coded_user_bit, �����û���������,Ϊcell�ṹ
%           N_sym, ��֡�е�OFDM���Ÿ���
%           Idx_data, ����OFDM���ŵ����ز����
%           AllocMethod, ���ز����䷽��, 1--���ڷ���, 2--��֯����, 3---��Ƶ����,4--����Ӧ���ز�����
%           AdptMethod, ����Ӧ���Ʒ���
%           H, Ƶ���ŵ���Ӧ
%           var_noise, ��������Ĺ���
%           TargetBer, Ŀ���������
%���:      user_subc_alloc, �û���������ز����,Ϊcell�ṹ
%           pad_bit_cnt, Ϊ��֤�û������ڵ�����������ȷ����,��Ҫ���ı�����
%           mod_subc, �û���Ӧuser_subc_alloc���ز��ϵĵ��Ʒ�ʽ,Ϊcell�ṹ
%           pwr_subc, �û���Ӧuser_subc_alloc���ز��ϵĹ���,Ϊcell�ṹ 
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 4
    
    % ��ʹ������Ӧ����, �Զ���û�������ʹ�ù̶������ز����䷽�� , ÿ���û������ز�
    % ��ʹ����ͬ���������Ʒ�ʽ ; ��ͬ�û������ز����ܻ�ʹ�ò�ͬ�ĵ��Ʒ�ʽ
    
    N_user = size(coded_user_bit,2);%���ݵõ����û����ݼ����û���
    num_subc_user = length(Idx_data) / N_user ;   % ƽ������,ÿ���û������ز��� Idx_dataΪ�������ز�����
    user_subc_alloc = cell(1,N_user);
    mod_subc = cell(1,N_user);
    pwr_subc = cell(1,N_user);
    
    for u = 1:N_user
        % �ȼ����Ϊ��֤�����û��ı���ǡ�÷���, ��Ҫ���ı�����, �ڱ�֡ĩβ�����
        % ÿ���û�ÿ��OFDM���ŵı�����
        userbit_sym = length(coded_user_bit{u})/N_sym;     %N_symΪһ֡��������OFDM������
        % ÿ���û�ʹ�õĵ��Ʒ�ʽ
        mod_user = ceil(userbit_sym / num_subc_user);     
         % ���Ʒ�ʽ��Ӧ: 1--BPSK����, 2--QPSK����,3--8PSK����, 4--16QAM����,6--64QAM����
        if mod_user > 6
            error('�����û�������̫��,�޷����е���,�ӳ���adpt_mod_para����!');
        elseif mod_user == 5 
            mod_user = 6;                  
        end                                  
        pad_bit_cnt(u) = mod_user * num_subc_user * N_sym - length(coded_user_bit{u}) ;%��Ҫ����0�ĸ���
    
    
        % Ȼ�����ѡ��Ĺ̶����ز����䷽��( 1--���ڷ���, 2--��֯����, 3---��Ƶ���� )
        % �����ز����ȵط�����û�. �û��ı�������ͬ, ����ɲ�ͬ�û��ĵ��Ʒ�ʽ��
        % ���������Ĳ�ͬ
    
        switch AllocMethod
           
        case    1           % ���ڷ��� 
            %user_subc_alloc((u-1)*num_subc_user + 1: u*num_subc_user) = u;
            user_subc_alloc{u} = Idx_data((u-1)*num_subc_user + 1: u*num_subc_user)';%ÿ���û������ز��������䣬��ͬ�û����ز����ڷ��䣬������ӳ��
            mod_subc{u} = mod_user*ones(num_subc_user, 1);
            pwr_subc{u} = ones(num_subc_user,1);
            
        case    2           % ��֯����
            
        case    3           % ��Ƶ���� 
        
        otherwise
        
        end
    
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
    % ʹ������Ӧ����, ���û����ز����䷽����AllocMethodȷ��, ����Ӧ���Ʒ�����AdptMethodȷ��
    
    % ���ʹ�ù̶����ز����䷽��
    if (AllocMethod == 1) | (AllocMethod == 2) | (AllocMethod == 3)
        
        N_user = size(coded_user_bit,2);
        N_data = length(Idx_data);
        % ƽ������,ÿ���û������ز���
        num_subc_user = N_data / N_user;   
        user_subc_alloc = cell(1,N_user);
        mod_subc = cell(1,N_user);
        pwr_subc = cell(1,N_user);
        
        for u = 1:N_user
            
            % �ȼ����,Ϊ��֤ÿ���û�ÿ��OFDM���ŵı�����Ϊ����������������, ��Ҫ���ı�����
            % ���ʹ�û��ڹ����ݶ���С��QAM �㷨, ����������ز��ı�����Ϊ0,2,4,6, ����Ϊ2
            step = 2;
            
            % ÿ���û���֡��Ҫ���ı�����      
            if mod(length(coded_user_bit{u}) , step*N_sym) ~= 0
                pad_bit_cnt(u) = step*N_sym - mod(length(coded_user_bit{u}) , step*N_sym);
            else
                pad_bit_cnt(u) = 0;
            end
            
            % ÿ���û�ÿ��OFDM���ŵı�����
            num_userbit_sym = (length(coded_user_bit{u}) + pad_bit_cnt(u))/N_sym;
   
            switch AllocMethod
                case    1           % ���ڷ���
                    %user_subc_alloc((u-1)*num_subc_user + 1: u*num_subc_user) = u;
                    user_subc_alloc{u} = Idx_data((u-1)*num_subc_user + 1: u*num_subc_user)';
                    %mod_subc{u} = mod_user*ones(num_subc_user, 1);
                    %pwr_subc{u} = ones(num_subc_user,1);
            
                case    2           % ��֯����
            
                case    3           % ��Ƶ���� 
        
                otherwise
            end
            
            % ��ǰ�û���Ӧ���ز����ŵ���Ӧ
            H_user = H{u}(user_subc_alloc{u},1,1);             
            
            switch AdptMethod
                % ����Ӧ���Ʒ���1, ������������С�����ز�������غ͹���
                case    1               
                    [mod_subc{u},pwr_subc{u}]=adaptive_power1(H_user,TargetBer,...
                                          num_subc_user,var_noise,num_userbit_sym);
                                      
                % ����Ӧ���Ʒ���2, ����������ܽ�����С�����ز�������غ����ӹ���
                case    2              
                    
                % ����Ӧ���Ʒ���3, �����ŵ���Ӧ��������,���ز����������( ����?? )
                case    3               
                    mod_subc{u} =adaptive(H_user,num_subc_user,num_userbit_sym);
                    pwr_subc{u} = ones(num_subc_user,1);
                    
                otherwise
            end
    
        end
        
    elseif  (AllocMethod == 4)           % ����Ӧ���ز�����
        
        % ����Ӧ���ز��ͱ��ع��ʷ���
        for u = 1:N_user
            % �ȼ�����Ҫ���ı�����
            step = 2;
            % ÿ���û���֡��Ҫ���ı�����              
            pad_bit_cnt(u) = step*N_sym - mod(length(coded_user_bit{u}) , step*N_sym);
            % ÿ���û�ÿ��OFDM���ŵı�����
            num_userbit_sym(u) = (length(coded_user_bit{u}) + pad_bit_cnt(u))/N_sym;
        end
        % �˺���δд
        adaptive_pwr_subc ( H(:,1) ,N_data, var_noise, num_userbit_sym );
        
    end
    
end    
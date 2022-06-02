
function sym = modu_sym(bit_to_mod)

% 得到调制方式
mod_type = size(bit_to_mod,1);

switch mod_type
    
    % BPSK调制
    case    1 
        % 比特的映射关系: 0: -1, 1: 1
        mapping_matrix = [ -1  1 ];
        %　把输入比特映射为符号
        sym = mapping_matrix(bit_to_mod + 1);
  
    % QPSK调制
    case    2
        %　比特的映射关系,00:-3/4*pi,01:3/4*pi,10: -1/4*pi,11: 1/4*pi
        mapping_matrix = exp(j*[-3/4*pi 3/4*pi -1/4*pi 1/4*pi]);
        index = [2 1]*bit_to_mod;
        %　把输入比特映射为符号
        sym = mapping_matrix(index + 1);

    % 8PSK调制    
    case    3
        % 映射关系参见说明文档
        mapping_matrix = exp(j*[0  1/4*pi 3/4*pi 1/2*pi  -1/4*pi -1/2*pi pi -3/4*pi ]);  
        index = [4 2 1]*bit_to_mod ;
        sym = mapping_matrix(index + 1);%行向量数据
        
        
    % 16QAM调制    
    case    4
        % 映射关系参见说明文档
        m=1;
        for k=-3:2:3
            for l=-3:2:3
                % 对符号能量进行归一化
                mapping_vector(m) = (k+j*l)/sqrt(10);
            m=m+1;
            end;
        end;
        mapping_vector = mapping_vector([0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10]+1);
        index = [8 4 2 1]*bit_to_mod ;
        sym = mapping_vector(index + 1);
        
    % 64QAM调制         
    case    6
        % 映射关系参见说明文档
        m=1;
        for k=-7:2:7
            for l=-7:2:7
                % 对符号能量进行归一化
                mapping_vector(m) = (k+j*l)/sqrt(42); 
            m=m+1;
            end;
        end;
        mapping_vector = mapping_vector(...
         [[ 0  1  3  2  7  6  4  5]...
         8+[ 0  1  3  2  7  6  4  5]... 
         24+[ 0  1  3  2  7  6  4  5]...
         16+[ 0  1  3  2  7  6  4  5]...
         56+[ 0  1  3  2  7  6  4  5]...
         48+[ 0  1  3  2  7  6  4  5]...
         32+[ 0  1  3  2  7  6  4  5]...
         40+[ 0  1  3  2  7  6  4  5]]+1);
        index = [32 16 8 4 2 1]*bit_to_mod ;
        sym = mapping_vector(index + 1);
    otherwise
        error('调制方式有误! 子程序modu_sym出错'); 
end



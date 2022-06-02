

function bit_out = demodu_sym(sym,mod_type)

% sym, 行向量
% bit, mod_type行的矩阵, length(sym)列的矩阵
% 大于0, 硬判决为比特1 ; 小于0 ,硬判决为比特0

bit_out = zeros(mod_type ,size(sym,2));

switch mod_type
    
    % BPSK解调
    case    1 
        bit_out = real(sym) > 0; 
        
    % QPSK解调
    case    2
        % 由QPSK的星座图可以观察到
        bit0 = real(sym) ; 
        bit1 = imag(sym) ;
        
        % 得到2行, 列数为符号数的输出矩阵
        bit_out(1,:) = bit0 > 0;
        bit_out(2,:) = bit1 > 0;
        
    % 8PSK解调  
    case    3
        % 参见8PSK的星座图
        bit0 = -imag( sym * exp(j*pi/8)) ;
        % bit1和bit2解调,都需要进行星座旋转
        bit1 = -real(sym * exp(j*pi/8)) ;
        
        bit2 = [];
        for k = 1:length(sym)
            tmp = sym(k) * exp(-j*pi/8); 
            if ((real(tmp) <0) & (imag(tmp) >0)) | ((real(tmp) >0) & (imag(tmp) <0))
                bit2 = [bit2 0];
            else
                bit2 = [bit2 1];
            end   
        end
        
        bit_out(1,:) = bit0 >0;
        bit_out(2,:) = bit1 >0;
        bit_out(3,:) = bit2 ;    %　已经硬判决
            
    % 16QAM解调   
    case    4
        
        bit0 = real(sym);
        bit2 = imag(sym);

        % 以bit1的生成来说明方法:
        % 2/sqrt(10) 为临界值, abs(real(sym))大于此, 则bit1为负,硬判决得到0 ; 反之为正
        bit1 = 2/sqrt(10)-(abs(real(sym)));
        bit3 = 2/sqrt(10)-(abs(imag(sym)));

        bit_out(1,:) = bit0 > 0;
        bit_out(2,:) = bit1 > 0;
        bit_out(3,:) = bit2 > 0;
        bit_out(4,:) = bit3 > 0;
        
    % 64QAM解调         
    case    6       
        bit0 = real(sym);
        bit3 = imag(sym);
        bit1 = 4/sqrt(42)-abs(real(sym));
        bit4 = 4/sqrt(42)-abs(imag(sym));
        for m=1:size(sym,2)
            for k=1:size(sym,1)
                if abs(4/sqrt(42)-abs(real(sym(k,m)))) <= 2/sqrt(42)  
                    bit2(k,m) = 2/sqrt(42) - abs(4/sqrt(42)-abs(real(sym(k,m))));
                elseif abs(real(sym(k,m))) <= 2/sqrt(42) 
                    bit2(k,m) = -2/sqrt(42) + abs(real(sym(k,m)));
                else
                    bit2(k,m) = 6/sqrt(42)-abs(real(sym(k,m)));
                end;
      
                if abs(4/sqrt(42)-abs(imag(sym(k,m)))) <= 2/sqrt(42)  
                    bit5(k,m) = 2/sqrt(42) - abs(4/sqrt(42)-abs(imag(sym(k,m))));
                elseif abs(imag(sym(k,m))) <= 2/sqrt(42) 
                    bit5(k,m) = -2/sqrt(42) + abs(imag(sym(k,m)));
                else
                    bit5(k,m) = 6/sqrt(42)-abs(imag(sym(k,m)));
                end;
            end;
        end;

        bit_out(1,:) = bit0 > 0;
        bit_out(2,:) = bit1 > 0;
        bit_out(3,:) = bit2 > 0;
        bit_out(4,:) = bit3 > 0;
        bit_out(5,:) = bit4 > 0;
        bit_out(6,:) = bit5 > 0;
        
    otherwise
        error('调制方式有误! 子程序demod_sym出错'); 
end



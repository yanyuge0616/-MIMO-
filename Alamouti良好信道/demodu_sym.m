

function bit_out = demodu_sym(sym,mod_type)

% sym, ������
% bit, mod_type�еľ���, length(sym)�еľ���
% ����0, Ӳ�о�Ϊ����1 ; С��0 ,Ӳ�о�Ϊ����0

bit_out = zeros(mod_type ,size(sym,2));

switch mod_type
    
    % BPSK���
    case    1 
        bit_out = real(sym) > 0; 
        
    % QPSK���
    case    2
        % ��QPSK������ͼ���Թ۲쵽
        bit0 = real(sym) ; 
        bit1 = imag(sym) ;
        
        % �õ�2��, ����Ϊ���������������
        bit_out(1,:) = bit0 > 0;
        bit_out(2,:) = bit1 > 0;
        
    % 8PSK���  
    case    3
        % �μ�8PSK������ͼ
        bit0 = -imag( sym * exp(j*pi/8)) ;
        % bit1��bit2���,����Ҫ����������ת
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
        bit_out(3,:) = bit2 ;    %���Ѿ�Ӳ�о�
            
    % 16QAM���   
    case    4
        
        bit0 = real(sym);
        bit2 = imag(sym);

        % ��bit1��������˵������:
        % 2/sqrt(10) Ϊ�ٽ�ֵ, abs(real(sym))���ڴ�, ��bit1Ϊ��,Ӳ�о��õ�0 ; ��֮Ϊ��
        bit1 = 2/sqrt(10)-(abs(real(sym)));
        bit3 = 2/sqrt(10)-(abs(imag(sym)));

        bit_out(1,:) = bit0 > 0;
        bit_out(2,:) = bit1 > 0;
        bit_out(3,:) = bit2 > 0;
        bit_out(4,:) = bit3 > 0;
        
    % 64QAM���         
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
        error('���Ʒ�ʽ����! �ӳ���demod_sym����'); 
end



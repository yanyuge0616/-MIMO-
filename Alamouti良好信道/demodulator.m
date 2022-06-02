function demod_user_bit = demodulator( st_decoded, user_subc_alloc ,mod_subc ,...
                        pad_bit_cnt, N_sym, AdptMod )   
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���,��������о��ı�������                  
% st_decoded, N_subc �е�����


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

demod_user_bit = [];
p = 1;

for n = 1:N_sym
      % ���ʹ������Ӧ����,��Ҫ�����ز����н��

      if AdptMod == 1
          for k = 1:length(user_subc_alloc)
              subc_k = user_subc_alloc(k);   % ���ز���
              bit_k = mod_subc(k);           % ��Ӧ���ز��ĵ��Ʒ�ʽ
              if bit_k ~= 0
                    %��ȡ������,���н��
                    bit_out = demodu_sym(st_decoded(subc_k,n),bit_k);
                    
                    demod_user_bit = [ demod_user_bit ; bit_out];
              end
          end
      else
          % ���������Ӧ����,���԰ѵ�ǰ�û��ڱ�OFDM�����е��������ز�
          % �������,��������
          mod_type = mod_subc(1);       % �������ز����Ʒ�ʽ��ͬ
          bit_out = demodu_sym(st_decoded(user_subc_alloc,n).' , mod_type);
          demod_user_bit = [ demod_user_bit ; bit_out(:)]; % תΪ������
      end
end

demod_user_bit = demod_user_bit( 1: end - pad_bit_cnt );




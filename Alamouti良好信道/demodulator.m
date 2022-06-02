function demod_user_bit = demodulator( st_decoded, user_subc_alloc ,mod_subc ,...
                        pad_bit_cnt, N_sym, AdptMod )   
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 解调,输出经过判决的比特序列                  
% st_decoded, N_subc 行的向量


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

demod_user_bit = [];
p = 1;

for n = 1:N_sym
      % 如果使用自适应调制,需要逐子载波进行解调

      if AdptMod == 1
          for k = 1:length(user_subc_alloc)
              subc_k = user_subc_alloc(k);   % 子载波号
              bit_k = mod_subc(k);           % 对应子载波的调制方式
              if bit_k ~= 0
                    %　取出符号,进行解调
                    bit_out = demodu_sym(st_decoded(subc_k,n),bit_k);
                    
                    demod_user_bit = [ demod_user_bit ; bit_out];
              end
          end
      else
          % 如果无自适应调制,可以把当前用户在本OFDM符号中的所有子载波
          % 组成向量,送入解调器
          mod_type = mod_subc(1);       % 所有子载波调制方式相同
          bit_out = demodu_sym(st_decoded(user_subc_alloc,n).' , mod_type);
          demod_user_bit = [ demod_user_bit ; bit_out(:)]; % 转为列向量
      end
end

demod_user_bit = demod_user_bit( 1: end - pad_bit_cnt );




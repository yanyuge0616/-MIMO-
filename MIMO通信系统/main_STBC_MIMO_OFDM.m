%main_STBC_MIMO_OFDM.m
%这是一个基于空时分组编码的MIMO_OFDM通信系统的仿真设计。
%此系统包括QPSK调制解调，IFFT调制，空时编解码，基于训
%练符号的信道估计等通信模块。

clear all
close all
clc

%+++++++++++++++++++++++++++变量++++++++++++++++++++++++++++++ 
i=sqrt(-1); 
IFFT_bin_length=512;         %傅立叶变换抽样点数目  
carrier_count=100;           %子载波数目 
symbols_per_carrier=66;      %符号数/载波 
cp_length=10;                %循环前缀长度 
addprefix_length=IFFT_bin_length+cp_length; 
M_psk=4; 
bits_per_symbol=log2(M_psk); %位数/符号 
%[x1 x2;-x2* x1*] 二天线发送矩阵  
% O=[1 2;-2+j 1+j];   
%[x1 -x2 -x3;x2* x1* 0;x3* 0 x1*;0 -x3* x2*] 三天线发送矩阵
O=[1 -2 -3;2+j 1+j 0;3+j 0 1+j;0 -3+j 2+j];   
co_time=size(O,1);                                                                   
Nt=size(O,2);                %发射天线数目  
Nr=2;                        %接收天线数目 
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++发射机++++++++++++++++++++++++++++++ 
disp('--------------start-------------------');
num_X=1; 
for cc_ro=1:co_time 
    for cc_co=1:Nt 
        num_X=max(num_X,abs(real(O(cc_ro,cc_co)))); 
    end 
end 
 
co_x=zeros(num_X,1); 
 
for con_ro=1:co_time    
    for con_co=1:Nt     %用于确定矩阵“O”中元素的位置，符号以及共轭情况 
        if abs(real(O(con_ro,con_co)))~=0 
            delta(con_ro,abs(real(O(con_ro,con_co))))=sign(real(O(con_ro,con_co)));  
            epsilon(con_ro,abs(real(O(con_ro,con_co))))=con_co; 
            co_x(abs(real(O(con_ro,con_co))),1)=co_x(abs(real(O(con_ro,con_co))),1)+1; 
            eta(abs(real(O(con_ro,con_co))),co_x(abs(real(O(con_ro,con_co))),1))=con_ro; 
            coj_mt(con_ro,abs(real(O(con_ro,con_co))))=imag(O(con_ro,con_co)); 
        end 
    end 
end 
 
eta=eta.';                                                                            
eta=sort(eta); 
eta=eta.'; 
 
% 坐标： (1 to 100) + 14=(15:114)
carriers = (1: carrier_count) + (floor(IFFT_bin_length/4) - floor(carrier_count/2));
% 坐标 ：256 - (15:114) + 1= 257 - (15:114) = (242:143) 
conjugate_carriers=IFFT_bin_length-carriers+2;                                          
tx_training_symbols=training_symbol(Nt,carrier_count); 
baseband_out_length = carrier_count * symbols_per_carrier; 
 
snr_min=3;                                     %最小信噪比    
snr_max=15;                                    %最大信噪比 
graph_inf_bit=zeros(snr_max-snr_min+1,2,Nr);   %绘图信息存储矩阵 
graph_inf_sym=zeros(snr_max-snr_min+1,2,Nr);  
 
for SNR=snr_min:snr_max                      
  clc 
  disp('Wait until SNR=');disp(snr_max); 
  SNR 
  n_err_sym=zeros(1,Nr); 
  n_err_bit=zeros(1,Nr); 
  Perr_sym=zeros(1,Nr); 
  Perr_bit=zeros(1,Nr); 
  re_met_sym_buf=zeros(carrier_count,symbols_per_carrier,Nr); 
  re_met_bit=zeros(baseband_out_length,bits_per_symbol,Nr);  
  
  %生成随机数用于仿真
  baseband_out=round(rand(baseband_out_length,bits_per_symbol));  
  %二进制向十进制转换 
  de_data=bi2de(baseband_out); 
  %PSK调制 
  data_buf=pskmod(de_data,M_psk,0);                              
  carrier_matrix=reshape(data_buf,carrier_count,symbols_per_carrier);                     
  %取数为空时编码做准备，此处每次取每个子载波上连续的两个数 
  for tt=1:Nt:symbols_per_carrier                              
     data=[]; 
     for ii=1:Nt 
     tx_buf_buf=carrier_matrix(:,tt+ii-1); 
     data=[data;tx_buf_buf]; 
     end 
     
     XX=zeros(co_time*carrier_count,Nt); 
     for con_r=1:co_time                               %进行空时编码 
        for con_c=1:Nt 
           if abs(real(O(con_r,con_c)))~=0 
             if imag(O(con_r,con_c))==0 
                XX((con_r-1)*carrier_count+1:con_r*carrier_count,con_c)=data((abs(real(O(con_r,con_c)))-1)*carrier_count+1:abs(real(O(con_r,con_c)))... 
                *carrier_count,1)*sign(real(O(con_r,con_c))); 
             else 
                XX((con_r-1)*carrier_count+1:con_r*carrier_count,con_c)=conj(data((abs(real(O(con_r,con_c)))-1)*carrier_count+1:abs(real(O(con_r,con_c)))... 
                *carrier_count,1))*sign(real(O(con_r,con_c))); 
             end 
          end 
        end 
     end                                               %空时编码结束                                                                         
          
    XX=[tx_training_symbols;XX];                       %添加训练序列                      
     
    rx_buf=zeros(1,addprefix_length*(co_time+1),Nr); 
    for rev=1:Nr 
       for ii=1:Nt 
         tx_buf=reshape(XX(:,ii),carrier_count,co_time+1); 
         IFFT_tx_buf=zeros(IFFT_bin_length,co_time+1); 
         IFFT_tx_buf(carriers,:)=tx_buf(1:carrier_count,:); 
         IFFT_tx_buf(conjugate_carriers,:)=conj(tx_buf(1:carrier_count,:)); 
         time_matrix=ifft(IFFT_tx_buf); 
         time_matrix=[time_matrix((IFFT_bin_length-cp_length+1):IFFT_bin_length,:);time_matrix]; 
         tx=time_matrix(:)'; 
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   
%+++++++++++++++++++++++++++信道++++++++++++++++++++++++++++++ 
         %d=randint(1,4,[1,7]);                          %4多经信道模拟   
         %a=randint(1,4,[2,7])/10; 
         tx_tmp=tx; 
         d=[4,5,6,2;4,5,6,2;4,5,6,2;4,5,6,2]; 
         a=[0.2,0.3,0.4,0.5;0.2,0.3,0.4,0.5;0.2,0.3,0.4,0.5;0.2,0.3,0.4,0.5]; 
         for jj=1:size(d,2) 
            copy=zeros(size(tx)) ; 
            for kk = 1 + d(ii,jj): length(tx) 
              copy(kk) = a(ii,jj)*tx(kk - d(ii,jj)) ; 
            end 
            tx_tmp=tx_tmp+copy; 
         end 
          
         txch=awgn(tx_tmp,SNR,'measured');              %添加高斯白噪声 
         rx_buf(1,:,rev)=rx_buf(1,:,rev)+txch; 
       end 
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

%+++++++++++++++++++++++++++接收机++++++++++++++++++++++++++++++ 
    rx_spectrum=reshape(rx_buf(1,:,rev),addprefix_length,co_time+1); 
    rx_spectrum=rx_spectrum(cp_length+1:addprefix_length,:); 
    FFT_tx_buf=zeros(IFFT_bin_length,co_time+1); 
    FFT_tx_buf=fft(rx_spectrum); 
    spectrum_matrix=FFT_tx_buf(carriers,:); 
    Y_buf=(spectrum_matrix(:,2:co_time+1)); 
    Y_buf=conj(Y_buf'); 
  
    spectrum_matrix1=spectrum_matrix(:,1); 
    Wk=exp((-2*pi/carrier_count)*i); 
    L=10; 
     
    p=zeros(L*Nt,1); 
    for jj=1:Nt 
         for l=0:L-1 
             for kk=0:carrier_count-1 
                  p(l+(jj-1)*L+1,1)=p(l+(jj-1)*L+1,1)+spectrum_matrix1(kk+1,1)*conj(tx_training_symbols(kk+1,jj))*Wk^(-(kk*l)); 
             end  
         end 
     end 
                      
     %q=zeros(L*Nt,L*Nt);             
     %for ii=1:Nt                        
     %   for jj=1:Nt 
     %      for l1=0:L-1 
     %          for l2=0:L-1 
     %             for kk=0:carrier_count-1 
     %             q(l2+(ii-1)*L+1,l1+(jj-1)*L+1)= q(l2+(ii-1)*L+1,l1+(jj-1)*L+1)+tx_training_symbols(kk+1,ii)*conj(tx_training_symbols(kk+1,jj))*Wk^(-(kk*(-l1+l2))); 
     %             end  
     %         end 
     %      end 
     %   end 
     %end 
         
    %h=inv(q)*p; 
    h=p/carrier_count; 
     
    H_buf=zeros(carrier_count,Nt); 
    for ii=1:Nt 
       for kk=0:carrier_count-1 
          for l=0:L-1 
             H_buf(kk+1,ii)=H_buf(kk+1,ii)+h(l+(ii-1)*L+1,1)*Wk^(kk*l); 
          end  
       end 
    end 
    H_buf=conj(H_buf'); 
 
    RRR=[]; 
    for kk=1:carrier_count 
        Y=Y_buf(:,kk); 
        H=H_buf(:,kk); 
        for co_ii=1:num_X 
            for co_tt=1:size(eta,2) 
                if eta(co_ii,co_tt)~=0 
                    if coj_mt(eta(co_ii,co_tt),co_ii)==0 
                        r_til(eta(co_ii,co_tt),:,co_ii)=Y(eta(co_ii,co_tt),:); 
                        a_til(eta(co_ii,co_tt),:,co_ii)=conj(H(epsilon(eta(co_ii,co_tt),co_ii),:)); 
                    else 
                        r_til(eta(co_ii,co_tt),:,co_ii)=conj(Y(eta(co_ii,co_tt),:)); 
                        a_til(eta(co_ii,co_tt),:,co_ii)=H(epsilon(eta(co_ii,co_tt),co_ii),:); 
                    end 
                end 
            end 
        end 
         
        RR=zeros(num_X,1); 
         
       for iii=1:num_X                         %接收数据的判决统计 
          for ttt=1:size(eta,2) 
             if eta(iii,ttt)~=0 
                RR(iii,1)=RR(iii,1)+r_til(eta(iii,ttt),1,iii)*a_til(eta(iii,ttt),1,iii)*delta(eta(iii,ttt),iii); 
             end 
          end 
       end 
        
       RRR=[RRR;conj(RR')]; 
    end 
     r_sym=pskdemod(RRR,M_psk,0);  
     re_met_sym_buf(:,tt:tt+Nt-1,rev)=r_sym; 
    end 
  end 
   
  re_met_sym=zeros(baseband_out_length,1,Nr); 
   
  for rev=1:Nr 
    re_met_sym_buf_buf=re_met_sym_buf(:,:,rev); 
    re_met_sym(:,1,rev)= re_met_sym_buf_buf(:); 
    re_met_bit(:,:,rev)=de2bi(re_met_sym(:,1,rev)); 
  
    for con_dec_ro=1:baseband_out_length                                              
       if re_met_sym(con_dec_ro,1,rev)~=de_data(con_dec_ro,1) 
          n_err_sym(1,rev)=n_err_sym(1,rev)+1; 
          for con_dec_co=1:bits_per_symbol 
             if re_met_bit(con_dec_ro,con_dec_co,rev)~=baseband_out(con_dec_ro,con_dec_co) 
                n_err_bit(1,rev)=n_err_bit(1,rev)+1; 
             end 
          end 
       end 
    end 
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++误码率计算+++++++++++++++++++++++++++++    
    graph_inf_sym(SNR-snr_min+1,1,rev)=SNR; 
    graph_inf_bit(SNR-snr_min+1,1,rev)=SNR; 
    Perr_sym(1,rev)=n_err_sym(1,rev)/(baseband_out_length);                                                 
    graph_inf_sym(SNR-snr_min+1,2,rev)=Perr_sym(1,rev); 
    Perr_bit(1,rev)=n_err_bit(1,rev)/(baseband_out_length*bits_per_symbol); 
    graph_inf_bit(SNR-snr_min+1,2,rev)=Perr_bit(1,rev); 
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
  end 
end 

%++++++++++++++++++++++++++性能仿真图++++++++++++++++++++++++++++++
for rev=1:rev 
 x_sym=graph_inf_sym(:,1,rev);                                                                    
 y_sym=graph_inf_sym(:,2,rev); 
 subplot(Nr,1,rev); 
 semilogy(x_sym,y_sym,'b-*'); 
 axis([2 16 0.0001 1]); 
 xlabel('信噪比/dB'); 
 ylabel('误码率'); 
 grid on 
 %hold on 
end 

%hold off 
 
%for rev=1:rev 
 %x_bit=graph_inf_bit(:,1,rev); 
 %y_bit=graph_inf_bit(:,2,rev); 
 %subplot(2,1,2); 
 %semilogy(x_bit,y_bit,'k-v'); 
 %axis([2 16 0.0001 1]); 
 %xlabel('SNR, [dB]'); 
% ylabel('Bit Error Probability'); 
 %grid on 
 %hold on 
%end 
%hold off 
disp('--------------end-------------------');
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

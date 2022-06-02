function noise=gausnoise(Eb_No_dB,transmit_signal_power,length_noise)
%根据信噪比产生高斯白噪声序列
            linear_Eb_No_dB=10^(Eb_No_dB/10);%线性信噪比 
            noise_sigma=transmit_signal_power/linear_Eb_No_dB;
            noise_scale_factor = sqrt(noise_sigma/2);%标准差sigma
            realnoise=randn(1,length_noise,2);%产生正态分布噪声序列实部
            realnoise(:,:,1)=realnoise(:,:,1).*noise_scale_factor(1);
            realnoise(:,:,2)=realnoise(:,:,2).*noise_scale_factor(2);
            imagnoise=randn(1,length_noise,2);%产生正态分布噪声序列虚步
            imagnoise(:,:,1)=imagnoise(:,:,1).*noise_scale_factor(1);
            imagnoise(:,:,2)=imagnoise(:,:,2).*noise_scale_factor(2);
            noise=complex(realnoise,imagnoise);%复噪声序列
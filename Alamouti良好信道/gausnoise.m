function noise=gausnoise(Eb_No_dB,transmit_signal_power,length_noise)
%��������Ȳ�����˹����������
            linear_Eb_No_dB=10^(Eb_No_dB/10);%��������� 
            noise_sigma=transmit_signal_power/linear_Eb_No_dB;
            noise_scale_factor = sqrt(noise_sigma/2);%��׼��sigma
            realnoise=randn(1,length_noise,2);%������̬�ֲ���������ʵ��
            realnoise(:,:,1)=realnoise(:,:,1).*noise_scale_factor(1);
            realnoise(:,:,2)=realnoise(:,:,2).*noise_scale_factor(2);
            imagnoise=randn(1,length_noise,2);%������̬�ֲ����������鲽
            imagnoise(:,:,1)=imagnoise(:,:,1).*noise_scale_factor(1);
            imagnoise(:,:,2)=imagnoise(:,:,2).*noise_scale_factor(2);
            noise=complex(realnoise,imagnoise);%����������
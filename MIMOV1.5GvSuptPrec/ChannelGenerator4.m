function [H PHI Alpha Position Precision]=ChannelGenerator4(N,TapL,Poson,index,Df,Dt)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Yuan Zhengdao
%function����dftmtx��������TotalSubcNumά��׼DFT����Ȼ��������ѡȡ����ΪPhi
%TotalSubcNum: ��Df��Dt�����ά��
%SlctSubc���Ӿ�����ѡȡ����index
%TapL���ŵ���ͷ����Gains��ÿ��ʱ�ӵ����棬Delays��ÿ��ʱ�ӣ�Df���ز������Dt��ʱ��������

%�У�H=Phi*Alpha
%H��Ƶ���ŵ���Phi��ʱ��Ƶ��任����alpha��ϡ��ʱ���ͷ��
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TotalSubcNum=floor(1/(Df*Dt));  %��Dt��Df��������DFT����ά��
%N=length(SlctSubc);       %��������ز�����
SlctSubc=zeros(1,N);
tou=1;
wei=TotalSubcNum-0;
Odd=tou+1:2:(wei); %ȡ���ز�������������   %��ͷȥβ
Even=tou:2:(wei); %ȡ���ز�����ż������   %��ͷȥβ

SlctSubc(1:length(Odd))=Odd;%ѡ�����ز��ȸ�ֵ��������
Rest_Num=randperm(length(Even)); %ʣ�����ز����������ȡֵ,��length��Even��������
Rest=Even(Rest_Num(1:N-length(Odd)));%ʣ�����ز�����ż������ȡ
SlctSubc((length(Odd)+1):N)=Rest; %��ѡ�����ز���ʣ�ಿ�������ż�����ϵ����ȡֵ
SlctSubc=sort(SlctSubc); %���򣬵õ�����ѡ�����ز����

%NonZeroTap=random('poisson',Poson);  %�ྶ����Ч���������ϲ��ɷֲ�
NonZeroTap=Poson;
% index=randperm(TapL);
% index=sort(index(1:NonZeroTap));
% Gain=rand(1,NonZeroTap);                                      %�ྶ��ÿ������
% Gain=floor(Gain*10);
Gain=ones(1,NonZeroTap);
ak=randn(NonZeroTap,1)+1i*randn(NonZeroTap,1);          % ÿ��ϡ����ϵķ��ȣ�
%ak=sqrt(0.5)*(ones(NonZeroTap,1)+1i*ones(NonZeroTap,1));
a = zeros(NonZeroTap,1);
avgPower = 10.^(Gain/10);
avgPower = avgPower/sum(avgPower);                     % normalize average power
for p = 1:NonZeroTap
    a(p) = sqrt(0.5*avgPower(p)) * ak(p);                       %ÿ��ϡ������ֵ�����ڷ��ȳ˶�Ӧ���ز��ŵ�����
end

Position=index; %�����ͷ���
Precision=1./avgPower; %�����ͷ�ľ��ȣ������֮һ��
Alpha = zeros(TapL,1);
Alpha(index,:)=sqrt(0.5*avgPower').*ak;       %����alpha��ϡ��ʱ���ͷ��

%F= sqrt(1/2)*(randn(TotalSubcNum,TotalSubcNum)+1i*randn(TotalSubcNum,TotalSubcNum));
F=dftmtx(TotalSubcNum);         %����DFT����
PHI=F(SlctSubc,1:TapL);             %ȡ�����SlctSubc�У�TapL��

H=PHI*Alpha;

end
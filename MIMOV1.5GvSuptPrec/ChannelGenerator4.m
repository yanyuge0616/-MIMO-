function [H PHI Alpha Position Precision]=ChannelGenerator4(N,TapL,Poson,index,Df,Dt)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Yuan Zhengdao
%function：由dftmtx函数生成TotalSubcNum维标准DFT矩阵，然后从中随机选取行作为Phi
%TotalSubcNum: 由Df，Dt计算的维数
%SlctSubc：从矩阵中选取的行index
%TapL：信道抽头数，Gains：每径时延点增益，Delays：每径时延，Df子载波间隔，Dt：时间抽样间隔

%有：H=Phi*Alpha
%H：频域信道，Phi：时域频域变换矩阵，alpha：稀疏时域抽头。
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TotalSubcNum=floor(1/(Df*Dt));  %由Dt，Df计算总体DFT矩阵维度
%N=length(SlctSubc);       %求出总子载波个数
SlctSubc=zeros(1,N);
tou=1;
wei=TotalSubcNum-0;
Odd=tou+1:2:(wei); %取总载波数的奇数部分   %掐头去尾
Even=tou:2:(wei); %取总载波数的偶数部分   %掐头去尾

SlctSubc(1:length(Odd))=Odd;%选择子载波先赋值奇数部分
Rest_Num=randperm(length(Even)); %剩余子载波个数中随机取值,共length（Even）个数字
Rest=Even(Rest_Num(1:N-length(Odd)));%剩余子载波都从偶数部分取
SlctSubc((length(Odd)+1):N)=Rest; %将选择子载波的剩余部分填充上偶数集合的随机取值
SlctSubc=sort(SlctSubc); %排序，得到所有选择子载波序号

%NonZeroTap=random('poisson',Poson);  %多径的有效径数，复合泊松分布
NonZeroTap=Poson;
% index=randperm(TapL);
% index=sort(index(1:NonZeroTap));
% Gain=rand(1,NonZeroTap);                                      %多径，每径功率
% Gain=floor(Gain*10);
Gain=ones(1,NonZeroTap);
ak=randn(NonZeroTap,1)+1i*randn(NonZeroTap,1);          % 每个稀疏点上的幅度，
%ak=sqrt(0.5)*(ones(NonZeroTap,1)+1i*ones(NonZeroTap,1));
a = zeros(NonZeroTap,1);
avgPower = 10.^(Gain/10);
avgPower = avgPower/sum(avgPower);                     % normalize average power
for p = 1:NonZeroTap
    a(p) = sqrt(0.5*avgPower(p)) * ak(p);                       %每个稀疏点的数值，等于幅度乘对应子载波信道功率
end

Position=index; %非零抽头编号
Precision=1./avgPower; %非零抽头的精度（方差分之一）
Alpha = zeros(TapL,1);
Alpha(index,:)=sqrt(0.5*avgPower').*ak;       %生成alpha（稀疏时域抽头）

%F= sqrt(1/2)*(randn(TotalSubcNum,TotalSubcNum)+1i*randn(TotalSubcNum,TotalSubcNum));
F=dftmtx(TotalSubcNum);         %生成DFT矩阵
PHI=F(SlctSubc,1:TapL);             %取随机的SlctSubc行，TapL列

H=PHI*Alpha;

end
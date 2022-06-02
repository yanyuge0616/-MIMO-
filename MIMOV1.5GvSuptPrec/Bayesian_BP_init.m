%init the Bayesian parameter and variances

msg_p_v=ones(K,1);  %p消息，h-fy消息
msg_p_m=zeros(K,1);

msg_alpha2h_m=zeros(K,L);  %alpha到H的消息
msg_alpha2h_v=ones(K,L); %5.5修改，try

msg_h2alpha_m=zeros(K,L);  %fh到alpha的消息
msg_h2alpha_v=inf(K,L);

blf_alpha_v=zeros(L,1);  %Alpha的belief,5.5日修改，用于测试串行schedule
blf_alpha_m=zeros(L,1);

blf_h_v=ones(K,1);  %Alpha的belief
blf_h_m=zeros(K,1);

SumScndMmt=ones(L,1);%由于抽头alpha全部初始化为0均值1方差，则求精度用到的二阶矩之和
Prec=zeros(L,1);    %抽头精度
epsilon=1;
eta=0;%eta的初始设置
BayesianBP.msg_alpha2h_m=msg_alpha2h_m;
BayesianBP.msg_alpha2h_v=msg_alpha2h_v;
BayesianBP.blf_h_m=blf_h_m;
BayesianBP.blf_h_v=blf_h_v;
BayesianBP.msg_p_v=msg_p_v;
BayesianBP.msg_p_m=msg_p_m;
BayesianBP.blf_alpha_v=blf_alpha_v;
BayesianBP.blf_alpha_m=blf_alpha_m;
BayesianBP.msg_h2alpha_m=msg_h2alpha_m;
BayesianBP.msg_h2alpha_v=msg_h2alpha_v;
BayesianBP.Prec=Prec;
BayesianBP.SumScndMmt=SumScndMmt;
BayesianBP.epsilon=epsilon;
BayesianBP.eta=eta;



%init the Bayesian parameter and variances

msg_p_v=ones(K,1);  %p��Ϣ��h-fy��Ϣ
msg_p_m=zeros(K,1);

msg_alpha2h_m=zeros(K,L);  %alpha��H����Ϣ
msg_alpha2h_v=ones(K,L); %5.5�޸ģ�try

msg_h2alpha_m=zeros(K,L);  %fh��alpha����Ϣ
msg_h2alpha_v=inf(K,L);

blf_alpha_v=zeros(L,1);  %Alpha��belief,5.5���޸ģ����ڲ��Դ���schedule
blf_alpha_m=zeros(L,1);

blf_h_v=ones(K,1);  %Alpha��belief
blf_h_m=zeros(K,1);

SumScndMmt=ones(L,1);%���ڳ�ͷalphaȫ����ʼ��Ϊ0��ֵ1������󾫶��õ��Ķ��׾�֮��
Prec=zeros(L,1);    %��ͷ����
epsilon=1;
eta=0;%eta�ĳ�ʼ����
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



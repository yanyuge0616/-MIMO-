function [BayesianBP2 blf_h_m blf_h_v]=ModifySizeBP(Phi,BayesianBP,y,x,lemmda,pilotSubcIndx,dataSubcIndx)
%author: YUAN
%author: yuan
%time: 2015.4.3AM
%function：修改频域维度，使用导频估计时，频域为导频维度，进行联合时，修改成全部频域维度
[N L]=size(Phi);%由Phi得出本函数的时域频域维数
%%
BayesianBP2=BayesianBP;

blf_alpha_m=BayesianBP.blf_alpha_m; %对导频信道估计出的时域参数赋值到Bayesian结构体中
blf_alpha_v=BayesianBP.blf_alpha_v;

msg_h2alpha_m=zeros(N,L);  %fh到alpha的消息，设为零均值1方差并且把导频估计部分填充上
msg_h2alpha_v=inf(N,L);
msg_h2alpha_m(pilotSubcIndx,:)=BayesianBP.msg_h2alpha_m;
msg_h2alpha_v(pilotSubcIndx,:)=BayesianBP.msg_h2alpha_v;

msg_alpha2h_m=zeros(N,L);  %alpha到H的消息，初始化为零均值1方差,导频部分填充上上次计算值
msg_alpha2h_v=ones(N,L);
msg_alpha2h_m(pilotSubcIndx,:)=BayesianBP.msg_alpha2h_m;
msg_alpha2h_v(pilotSubcIndx,:)=BayesianBP.msg_alpha2h_v;

Prec=BayesianBP.Prec;
% for n=1:length(dataSubcIndx)
%     Nindx=dataSubcIndx(n);
%     for l=1:L
%         msg_alpha2h_v(Nindx,l)=(1/(1/blf_alpha_v(l)-1/msg_h2alpha_v(Nindx,l))); %所有alpha到h消息
%         msg_alpha2h_m(Nindx,l)=(blf_alpha_m(l)/blf_alpha_v(l)-msg_h2alpha_m(Nindx,l)/msg_h2alpha_v(Nindx,l))*msg_alpha2h_v(Nindx,l);
%     end
% end
% 5.5日修改，alpha-fh消息直接用b（alpha）替代
for n=1:length(dataSubcIndx)
    Nindx=dataSubcIndx(n);
    for l=1:L
        msg_alpha2h_v(Nindx,l)=blf_alpha_v(l); %所有alpha到h消息
        msg_alpha2h_m(Nindx,l)=blf_alpha_m(l);
    end
end

msg_fy2h_m=y./x;          %初始化y到h消息,此处为全部消息，应该设置数据部分消息为未知
msg_fy2h_v=1./(lemmda*abs(x).^2);
msg_fy2h_m(dataSubcIndx)=0;%将数据部分消息初始化为零均值，1方差
msg_fy2h_v(dataSubcIndx)=inf;

msg_p_m=zeros(N,1); %P消息初始化，联合估计检测时，频域维度增加到1200，先初始化，然后再将导频部分的频域参数填充
msg_p_v=inf*ones(N,1);
msg_p_m(pilotSubcIndx,:)=BayesianBP.msg_p_m;
msg_p_v(pilotSubcIndx,:)=BayesianBP.msg_p_v;

blf_h_m=zeros(N,1); %初始化频域参数为零均值，1方差，后续直接赋值，其初始化值无意义，只是定义
blf_h_v=ones(N,1);
blf_h_m(pilotSubcIndx,:)=BayesianBP.blf_h_m;
blf_h_v(pilotSubcIndx,:)=BayesianBP.blf_h_v;
for n=1:length(dataSubcIndx)
    Nindx=dataSubcIndx(n);
    msg_p_v(Nindx)=(sum((abs(Phi(Nindx,:)).^2).*msg_alpha2h_v(Nindx,:))); %p消息
    msg_p_m(Nindx)=sum(Phi(Nindx,:).*msg_alpha2h_m(Nindx,:));
    
    blf_h_v(Nindx)=abs(1/(1/msg_p_v(Nindx)+1/msg_fy2h_v(Nindx)));
    blf_h_m(Nindx)=(msg_p_m(Nindx)/msg_p_v(Nindx)+msg_fy2h_m(Nindx)/msg_fy2h_v(Nindx))*blf_h_v(Nindx);%更新b(h)
end

%%
BayesianBP2.msg_p_m=msg_p_m; %将修改过的p消息，s函数反馈到Bayesian结构体中
BayesianBP2.msg_p_v=msg_p_v;

BayesianBP2.blf_h_m=blf_h_m; %重新写入BayesianBP2结构体中
BayesianBP2.blf_h_v=blf_h_v;

BayesianBP2.msg_alpha2h_m=msg_alpha2h_m; %重新写入BayesianBP2结构体中
BayesianBP2.msg_alpha2h_v=msg_alpha2h_v;

BayesianBP2.msg_h2alpha_m=msg_h2alpha_m; %重新写入BayesianBP2结构体中
BayesianBP2.msg_h2alpha_v=msg_h2alpha_v;

BayesianBP2.blf_alpha_m=blf_alpha_m; %对导频信道估计出的时域参数赋值到Bayesian结构体中
BayesianBP2.blf_alpha_v=blf_alpha_v;
BayesianBP2.Prec=Prec;
%BayesianBP2.SumScndMmtExcept=BayesianBP.SumScndMmtExcept;

BayesianBP2.msg_fy2h_m=msg_fy2h_m; 
BayesianBP2.msg_fy2h_v=msg_fy2h_v;

BayesianBP2.epsilon=BayesianBP.epsilon;  
BayesianBP2.eta=BayesianBP.eta;   
end
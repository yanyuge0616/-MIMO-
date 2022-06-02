function [BayesianBP]=SparseChannelEstBayOne(Phi,K,L,M,BayesianBP,msg_y2h_m,msg_y2h_v)
%% function：稀疏贝叶斯估计，第一部分。
%（由于common support，在更新gamma时候需要用到全部alpha二阶矩，此处采用并行方法：全部更新完本次b（alpha）后更新gamma）
%author: yuan
%time: 2015.5.5AM

%% %%%%%%%%%%初始化数值%%%%%%%%%%%%%%%%%%%%%%
msg_q_v=ones(L,1);  %q消息
msg_q_m=zeros(L,1);

msg_alpha2h_m=BayesianBP.msg_alpha2h_m;  %h的belief
msg_alpha2h_v=BayesianBP.msg_alpha2h_v;
blf_alpha_v=BayesianBP.blf_alpha_v;  %Alpha的belief
blf_alpha_m=BayesianBP.blf_alpha_m;
Prec=BayesianBP.Prec;  %估计的信道抽头精度
     
msg_h2alpha_m=BayesianBP.msg_h2alpha_m; %读取alpha到h的消息
msg_h2alpha_v=BayesianBP.msg_h2alpha_v;
msg_p_v=BayesianBP.msg_p_v;                          %读取的p消息
msg_p_m=BayesianBP.msg_p_m;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for l=1:L
    for n=1:K
        msg_h2alpha_v(n,l)=((msg_y2h_v(n)+msg_p_v(n)-abs(Phi(n,l))^2*msg_alpha2h_v(n,l))/abs(Phi(n,l))^2); %fh到alpha的消息
        msg_h2alpha_m(n,l)=(msg_y2h_m(n)-msg_p_m(n)+Phi(n,l)*msg_alpha2h_m(n,l))/Phi(n,l);
    end
    msg_q_v(l)=(1/sum(1./msg_h2alpha_v(:,l))); %q消息
    msg_q_m(l)=sum(msg_h2alpha_m(:,l)./msg_h2alpha_v(:,l))*msg_q_v(l);
    
    blf_alpha_v(l)=msg_q_v(l)/(1+Prec(l)*msg_q_v(l));
    blf_alpha_m(l)=msg_q_m(l)/(1+Prec(l)*msg_q_v(l));
end
%% %%%%%%%%%%%%更新数值%%%%%%%%%%%%%%%%%
BayesianBP.msg_q_v=msg_q_v;  %q消息
BayesianBP.msg_q_m=msg_q_m;

BayesianBP.blf_alpha_v=blf_alpha_v;  %Alpha的belief
BayesianBP.blf_alpha_m=blf_alpha_m;

BayesianBP.msg_h2alpha_m=msg_h2alpha_m; %读取alpha到h的消息
BayesianBP.msg_h2alpha_v=msg_h2alpha_v;                                     

BayesianBP.msg_y2h_m=msg_y2h_m; %
BayesianBP.msg_y2h_v=msg_y2h_v;  




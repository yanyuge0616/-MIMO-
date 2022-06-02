function [BayesianBP blf_h_m blf_h_v]=SparseChannelEstBayTwo(Phi,K,L,M,BayesianBP,ChnlCell,msg_y2h_m,msg_y2h_v,EstPrec)
%% author:
%author: yuan
%time: 2015.4.3AM
%BayesianBP:含有所有迭代参数的结构体%
% Phi,M,L:混合矩阵parameter
%blf_alpha_m,blf_alpha_v:alpha的belief
%msg_y2h_m,msg_y2h_v,从Y传入的消息
%gamma,gamma_inv，gamma的期望和-1阶矩
%eta：
%% %%%%%%%%%%初始化数值%%%%%%%%%%%%%%%%%%%%%%
msg_q_v=BayesianBP.msg_q_v;  %q消息
msg_q_m=BayesianBP.msg_q_m;

blf_h_v=BayesianBP.blf_h_v;  %h的belief
blf_h_m=BayesianBP.blf_h_m;

msg_alpha2h_m=BayesianBP.msg_alpha2h_m;  %h的belief
msg_alpha2h_v=BayesianBP.msg_alpha2h_v;

blf_alpha_v=BayesianBP.blf_alpha_v;  %Alpha的belief
blf_alpha_m=BayesianBP.blf_alpha_m;

Prec=BayesianBP.Prec;  %估计的信道抽头精度
SumScndMmt=BayesianBP.SumScndMmt;  %所有抽头二阶矩对r求和
epsilon=BayesianBP.epsilon;  
eta=BayesianBP.eta;         

msg_h2alpha_m=BayesianBP.msg_h2alpha_m; %读取alpha到h的消息
msg_h2alpha_v=BayesianBP.msg_h2alpha_v;

msg_p_v=BayesianBP.msg_p_v;                          %读取的p消息
msg_p_m=BayesianBP.msg_p_m;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for l=1:L
    if EstPrec
        Prec(l)=(epsilon+M)/abs(eta+SumScndMmt(l));
    else
        Prec(l)=ChnlCell.Prec(l);
    end
    %Prec(l)=(epsilon+1)/(eta+blf_alpha_v(l)+abs(blf_alpha_m(l))^2); %针对没有common support的情况
    blf_alpha_v(l)=msg_q_v(l)/(1+Prec(l)*msg_q_v(l));
    blf_alpha_m(l)=msg_q_m(l)/(1+Prec(l)*msg_q_v(l));
end
%%
for n=1:K
    for l=1:L
        msg_alpha2h_v(n,l)=(1/(1/blf_alpha_v(l)-1/msg_h2alpha_v(n,l))); %所有alpha到h消息
        msg_alpha2h_m(n,l)=(blf_alpha_m(l)/blf_alpha_v(l)-msg_h2alpha_m(n,l)/msg_h2alpha_v(n,l))*msg_alpha2h_v(n,l);
    end
    msg_p_v(n)=(sum((abs(Phi(n,:)).^2).*msg_alpha2h_v(n,:))); %p消息
    msg_p_m(n)=sum(Phi(n,:).*msg_alpha2h_m(n,:));
    
    blf_h_v(n)=(1/(1/msg_p_v(n)+1/msg_y2h_v(n)));
    blf_h_m(n)=(msg_p_m(n)/msg_p_v(n)+msg_y2h_m(n)/msg_y2h_v(n))*blf_h_v(n);%更新b(h)
end
%% %%%%%%%%%%%%更新数值%%%%%%%%%%%%%%%%%
BayesianBP.blf_h_v=blf_h_v;  %h的belief
BayesianBP.blf_h_m=blf_h_m;
BayesianBP.msg_alpha2h_m=msg_alpha2h_m;  %h的belief
BayesianBP.msg_alpha2h_v=msg_alpha2h_v;
BayesianBP.blf_alpha_v=blf_alpha_v;  %Alpha的belief
BayesianBP.blf_alpha_m=blf_alpha_m;
BayesianBP.Prec=Prec;  %估计的信道抽头精度
BayesianBP.msg_h2alpha_m=msg_h2alpha_m; %读取alpha到h的消息
BayesianBP.msg_h2alpha_v=msg_h2alpha_v;                                     
BayesianBP.msg_p_v=msg_p_v;                          %读取的p消息
BayesianBP.msg_p_m=msg_p_m;
BayesianBP.epsilon=epsilon;  
BayesianBP.eta=eta;    




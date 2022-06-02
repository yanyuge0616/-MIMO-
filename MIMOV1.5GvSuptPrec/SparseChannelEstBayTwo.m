function [BayesianBP blf_h_m blf_h_v]=SparseChannelEstBayTwo(Phi,K,L,M,BayesianBP,ChnlCell,msg_y2h_m,msg_y2h_v,EstPrec)
%% author:
%author: yuan
%time: 2015.4.3AM
%BayesianBP:�������е��������Ľṹ��%
% Phi,M,L:��Ͼ���parameter
%blf_alpha_m,blf_alpha_v:alpha��belief
%msg_y2h_m,msg_y2h_v,��Y�������Ϣ
%gamma,gamma_inv��gamma��������-1�׾�
%eta��
%% %%%%%%%%%%��ʼ����ֵ%%%%%%%%%%%%%%%%%%%%%%
msg_q_v=BayesianBP.msg_q_v;  %q��Ϣ
msg_q_m=BayesianBP.msg_q_m;

blf_h_v=BayesianBP.blf_h_v;  %h��belief
blf_h_m=BayesianBP.blf_h_m;

msg_alpha2h_m=BayesianBP.msg_alpha2h_m;  %h��belief
msg_alpha2h_v=BayesianBP.msg_alpha2h_v;

blf_alpha_v=BayesianBP.blf_alpha_v;  %Alpha��belief
blf_alpha_m=BayesianBP.blf_alpha_m;

Prec=BayesianBP.Prec;  %���Ƶ��ŵ���ͷ����
SumScndMmt=BayesianBP.SumScndMmt;  %���г�ͷ���׾ض�r���
epsilon=BayesianBP.epsilon;  
eta=BayesianBP.eta;         

msg_h2alpha_m=BayesianBP.msg_h2alpha_m; %��ȡalpha��h����Ϣ
msg_h2alpha_v=BayesianBP.msg_h2alpha_v;

msg_p_v=BayesianBP.msg_p_v;                          %��ȡ��p��Ϣ
msg_p_m=BayesianBP.msg_p_m;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for l=1:L
    if EstPrec
        Prec(l)=(epsilon+M)/abs(eta+SumScndMmt(l));
    else
        Prec(l)=ChnlCell.Prec(l);
    end
    %Prec(l)=(epsilon+1)/(eta+blf_alpha_v(l)+abs(blf_alpha_m(l))^2); %���û��common support�����
    blf_alpha_v(l)=msg_q_v(l)/(1+Prec(l)*msg_q_v(l));
    blf_alpha_m(l)=msg_q_m(l)/(1+Prec(l)*msg_q_v(l));
end
%%
for n=1:K
    for l=1:L
        msg_alpha2h_v(n,l)=(1/(1/blf_alpha_v(l)-1/msg_h2alpha_v(n,l))); %����alpha��h��Ϣ
        msg_alpha2h_m(n,l)=(blf_alpha_m(l)/blf_alpha_v(l)-msg_h2alpha_m(n,l)/msg_h2alpha_v(n,l))*msg_alpha2h_v(n,l);
    end
    msg_p_v(n)=(sum((abs(Phi(n,:)).^2).*msg_alpha2h_v(n,:))); %p��Ϣ
    msg_p_m(n)=sum(Phi(n,:).*msg_alpha2h_m(n,:));
    
    blf_h_v(n)=(1/(1/msg_p_v(n)+1/msg_y2h_v(n)));
    blf_h_m(n)=(msg_p_m(n)/msg_p_v(n)+msg_y2h_m(n)/msg_y2h_v(n))*blf_h_v(n);%����b(h)
end
%% %%%%%%%%%%%%������ֵ%%%%%%%%%%%%%%%%%
BayesianBP.blf_h_v=blf_h_v;  %h��belief
BayesianBP.blf_h_m=blf_h_m;
BayesianBP.msg_alpha2h_m=msg_alpha2h_m;  %h��belief
BayesianBP.msg_alpha2h_v=msg_alpha2h_v;
BayesianBP.blf_alpha_v=blf_alpha_v;  %Alpha��belief
BayesianBP.blf_alpha_m=blf_alpha_m;
BayesianBP.Prec=Prec;  %���Ƶ��ŵ���ͷ����
BayesianBP.msg_h2alpha_m=msg_h2alpha_m; %��ȡalpha��h����Ϣ
BayesianBP.msg_h2alpha_v=msg_h2alpha_v;                                     
BayesianBP.msg_p_v=msg_p_v;                          %��ȡ��p��Ϣ
BayesianBP.msg_p_m=msg_p_m;
BayesianBP.epsilon=epsilon;  
BayesianBP.eta=eta;    




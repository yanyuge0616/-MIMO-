function [BayesianBP]=SparseChannelEstBayOne(Phi,K,L,M,BayesianBP,msg_y2h_m,msg_y2h_v)
%% function��ϡ�豴Ҷ˹���ƣ���һ���֡�
%������common support���ڸ���gammaʱ����Ҫ�õ�ȫ��alpha���׾أ��˴����ò��з�����ȫ�������걾��b��alpha�������gamma��
%author: yuan
%time: 2015.5.5AM

%% %%%%%%%%%%��ʼ����ֵ%%%%%%%%%%%%%%%%%%%%%%
msg_q_v=ones(L,1);  %q��Ϣ
msg_q_m=zeros(L,1);

msg_alpha2h_m=BayesianBP.msg_alpha2h_m;  %h��belief
msg_alpha2h_v=BayesianBP.msg_alpha2h_v;
blf_alpha_v=BayesianBP.blf_alpha_v;  %Alpha��belief
blf_alpha_m=BayesianBP.blf_alpha_m;
Prec=BayesianBP.Prec;  %���Ƶ��ŵ���ͷ����
     
msg_h2alpha_m=BayesianBP.msg_h2alpha_m; %��ȡalpha��h����Ϣ
msg_h2alpha_v=BayesianBP.msg_h2alpha_v;
msg_p_v=BayesianBP.msg_p_v;                          %��ȡ��p��Ϣ
msg_p_m=BayesianBP.msg_p_m;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for l=1:L
    for n=1:K
        msg_h2alpha_v(n,l)=((msg_y2h_v(n)+msg_p_v(n)-abs(Phi(n,l))^2*msg_alpha2h_v(n,l))/abs(Phi(n,l))^2); %fh��alpha����Ϣ
        msg_h2alpha_m(n,l)=(msg_y2h_m(n)-msg_p_m(n)+Phi(n,l)*msg_alpha2h_m(n,l))/Phi(n,l);
    end
    msg_q_v(l)=(1/sum(1./msg_h2alpha_v(:,l))); %q��Ϣ
    msg_q_m(l)=sum(msg_h2alpha_m(:,l)./msg_h2alpha_v(:,l))*msg_q_v(l);
    
    blf_alpha_v(l)=msg_q_v(l)/(1+Prec(l)*msg_q_v(l));
    blf_alpha_m(l)=msg_q_m(l)/(1+Prec(l)*msg_q_v(l));
end
%% %%%%%%%%%%%%������ֵ%%%%%%%%%%%%%%%%%
BayesianBP.msg_q_v=msg_q_v;  %q��Ϣ
BayesianBP.msg_q_m=msg_q_m;

BayesianBP.blf_alpha_v=blf_alpha_v;  %Alpha��belief
BayesianBP.blf_alpha_m=blf_alpha_m;

BayesianBP.msg_h2alpha_m=msg_h2alpha_m; %��ȡalpha��h����Ϣ
BayesianBP.msg_h2alpha_v=msg_h2alpha_v;                                     

BayesianBP.msg_y2h_m=msg_y2h_m; %
BayesianBP.msg_y2h_v=msg_y2h_v;  




function [BayesianBP2 blf_h_m blf_h_v]=ModifySizeBP(Phi,BayesianBP,y,x,lemmda,pilotSubcIndx,dataSubcIndx)
%author: YUAN
%author: yuan
%time: 2015.4.3AM
%function���޸�Ƶ��ά�ȣ�ʹ�õ�Ƶ����ʱ��Ƶ��Ϊ��Ƶά�ȣ���������ʱ���޸ĳ�ȫ��Ƶ��ά��
[N L]=size(Phi);%��Phi�ó���������ʱ��Ƶ��ά��
%%
BayesianBP2=BayesianBP;

blf_alpha_m=BayesianBP.blf_alpha_m; %�Ե�Ƶ�ŵ����Ƴ���ʱ�������ֵ��Bayesian�ṹ����
blf_alpha_v=BayesianBP.blf_alpha_v;

msg_h2alpha_m=zeros(N,L);  %fh��alpha����Ϣ����Ϊ���ֵ1����Ұѵ�Ƶ���Ʋ��������
msg_h2alpha_v=inf(N,L);
msg_h2alpha_m(pilotSubcIndx,:)=BayesianBP.msg_h2alpha_m;
msg_h2alpha_v(pilotSubcIndx,:)=BayesianBP.msg_h2alpha_v;

msg_alpha2h_m=zeros(N,L);  %alpha��H����Ϣ����ʼ��Ϊ���ֵ1����,��Ƶ����������ϴμ���ֵ
msg_alpha2h_v=ones(N,L);
msg_alpha2h_m(pilotSubcIndx,:)=BayesianBP.msg_alpha2h_m;
msg_alpha2h_v(pilotSubcIndx,:)=BayesianBP.msg_alpha2h_v;

Prec=BayesianBP.Prec;
% for n=1:length(dataSubcIndx)
%     Nindx=dataSubcIndx(n);
%     for l=1:L
%         msg_alpha2h_v(Nindx,l)=(1/(1/blf_alpha_v(l)-1/msg_h2alpha_v(Nindx,l))); %����alpha��h��Ϣ
%         msg_alpha2h_m(Nindx,l)=(blf_alpha_m(l)/blf_alpha_v(l)-msg_h2alpha_m(Nindx,l)/msg_h2alpha_v(Nindx,l))*msg_alpha2h_v(Nindx,l);
%     end
% end
% 5.5���޸ģ�alpha-fh��Ϣֱ����b��alpha�����
for n=1:length(dataSubcIndx)
    Nindx=dataSubcIndx(n);
    for l=1:L
        msg_alpha2h_v(Nindx,l)=blf_alpha_v(l); %����alpha��h��Ϣ
        msg_alpha2h_m(Nindx,l)=blf_alpha_m(l);
    end
end

msg_fy2h_m=y./x;          %��ʼ��y��h��Ϣ,�˴�Ϊȫ����Ϣ��Ӧ���������ݲ�����ϢΪδ֪
msg_fy2h_v=1./(lemmda*abs(x).^2);
msg_fy2h_m(dataSubcIndx)=0;%�����ݲ�����Ϣ��ʼ��Ϊ���ֵ��1����
msg_fy2h_v(dataSubcIndx)=inf;

msg_p_m=zeros(N,1); %P��Ϣ��ʼ�������Ϲ��Ƽ��ʱ��Ƶ��ά�����ӵ�1200���ȳ�ʼ����Ȼ���ٽ���Ƶ���ֵ�Ƶ��������
msg_p_v=inf*ones(N,1);
msg_p_m(pilotSubcIndx,:)=BayesianBP.msg_p_m;
msg_p_v(pilotSubcIndx,:)=BayesianBP.msg_p_v;

blf_h_m=zeros(N,1); %��ʼ��Ƶ�����Ϊ���ֵ��1�������ֱ�Ӹ�ֵ�����ʼ��ֵ�����壬ֻ�Ƕ���
blf_h_v=ones(N,1);
blf_h_m(pilotSubcIndx,:)=BayesianBP.blf_h_m;
blf_h_v(pilotSubcIndx,:)=BayesianBP.blf_h_v;
for n=1:length(dataSubcIndx)
    Nindx=dataSubcIndx(n);
    msg_p_v(Nindx)=(sum((abs(Phi(Nindx,:)).^2).*msg_alpha2h_v(Nindx,:))); %p��Ϣ
    msg_p_m(Nindx)=sum(Phi(Nindx,:).*msg_alpha2h_m(Nindx,:));
    
    blf_h_v(Nindx)=abs(1/(1/msg_p_v(Nindx)+1/msg_fy2h_v(Nindx)));
    blf_h_m(Nindx)=(msg_p_m(Nindx)/msg_p_v(Nindx)+msg_fy2h_m(Nindx)/msg_fy2h_v(Nindx))*blf_h_v(Nindx);%����b(h)
end

%%
BayesianBP2.msg_p_m=msg_p_m; %���޸Ĺ���p��Ϣ��s����������Bayesian�ṹ����
BayesianBP2.msg_p_v=msg_p_v;

BayesianBP2.blf_h_m=blf_h_m; %����д��BayesianBP2�ṹ����
BayesianBP2.blf_h_v=blf_h_v;

BayesianBP2.msg_alpha2h_m=msg_alpha2h_m; %����д��BayesianBP2�ṹ����
BayesianBP2.msg_alpha2h_v=msg_alpha2h_v;

BayesianBP2.msg_h2alpha_m=msg_h2alpha_m; %����д��BayesianBP2�ṹ����
BayesianBP2.msg_h2alpha_v=msg_h2alpha_v;

BayesianBP2.blf_alpha_m=blf_alpha_m; %�Ե�Ƶ�ŵ����Ƴ���ʱ�������ֵ��Bayesian�ṹ����
BayesianBP2.blf_alpha_v=blf_alpha_v;
BayesianBP2.Prec=Prec;
%BayesianBP2.SumScndMmtExcept=BayesianBP.SumScndMmtExcept;

BayesianBP2.msg_fy2h_m=msg_fy2h_m; 
BayesianBP2.msg_fy2h_v=msg_fy2h_v;

BayesianBP2.epsilon=BayesianBP.epsilon;  
BayesianBP2.eta=BayesianBP.eta;   
end
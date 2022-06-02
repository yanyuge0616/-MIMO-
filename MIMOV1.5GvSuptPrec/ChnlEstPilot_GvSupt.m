function [ChnlEstCell LmdEst]=ChnlEstPilot_GvSupt(SysSturct,SendCell,RecvCell,ChnlCell,DecodeStruct,Lmd,EstimateLmd,EstPrec,Niter)
%function���������õ�Ƶ����Ҷ˹���ƣ�����schedule
%time��5.6PM
%ע�ͣ���֪support,����schedule

M=SysSturct.M;
N=SysSturct.N;
pilotSubcIndxTotal=DecodeStruct.pilotSubcIndx;
[~,K]=size(pilotSubcIndxTotal); %�����ز�����
Support=ChnlCell{1,1}.Support;  % ʱ���ά��Ϊsupport����
L=length(Support);
Bayesian_BP_init;           %��ʼ���ֲ㱴Ҷ˹ģ��
ChnlEstCell=cell(M,N);
if EstimateLmd==0
    LmdEst=Lmd; %���������lembda������ʵֵ�����
else
    LmdEst=10; %if estimate the precision, just use 10 to initiate Lmd;
end
MeanAlphaV=zeros(1,Niter);
for m=1:M
    for n=1:N
        ChnlEstCell{m,n}=BayesianBP; %��cell��ʼ��Ϊ��Ӧ�ṹ��
        ChnlEstCell{m,n}.MeanAlphaV=MeanAlphaV;%��ʼ��ƽ������
    end
end

%% ȫ�ֵ���
for iter=1:Niter
    for n=1:N
        for m=1:M
            %% ��һ���֣���������alpha
            pilotSubcIndx=pilotSubcIndxTotal(n,:);  %ȡ��Ӧ���Ͷ�n�ĵ�Ƶ
            x=SendCell{n}.x(pilotSubcIndx);
            y=RecvCell{m}.y(pilotSubcIndx);
            Support=ChnlCell{m,n}.Support;
            Phi=ChnlCell{m,n}.Phi;      
            phi=Phi(pilotSubcIndx,Support);   %phiֻȡ��Ƶ�����У�support������
            msg_fy2h_m=y./x;
            msg_fy2h_v=1./(LmdEst*abs(x).^2);
            %ϡ�豴Ҷ˹���ƣ���һ���֣���������alpha
            [ChnlEstCell{m,n}]=SparseChannelEstBayOne(phi,K,L,M,ChnlEstCell{m,n},msg_fy2h_m,msg_fy2h_v);
            
            %% ���¶�Ӧmn��alpha�Ķ��׾ض�����M���
            SumScndMmt=zeros(L,1);
            for mm=1:M
                blf_alpha_m=ChnlEstCell{mm,n}.blf_alpha_m;
                blf_alpha_v=ChnlEstCell{mm,n}.blf_alpha_v;
                SumScndMmt=SumScndMmt+abs(blf_alpha_m).^2+blf_alpha_v;  %�����ж��׾����
            end
            ChnlEstCell{m,n}.SumScndMmt=SumScndMmt; %д��cell
            
            %% �ڶ����֣�����gamma��alpha��alpha-h��Ϣ��b��h����
            [ChnlEstCell{m,n}]=SparseChannelEstBayTwo(phi,K,L,M,ChnlEstCell{m,n},ChnlCell{m,n},msg_fy2h_m,msg_fy2h_v,EstPrec);
            alpha=ChnlCell{m,n}.alpha(Support); %ֻȡsupport���ֵ�alpha��MSE����
            ChnlEstCell{m,n}.MSE_Alpha(iter) = mean(abs(ChnlEstCell{m,n}.blf_alpha_m-alpha).^2);
            blf_alpha_v=ChnlEstCell{m,n}.blf_alpha_v;
            Mean=mean(blf_alpha_v);
            ChnlEstCell{m,n}.MeanAlphaV(iter)=Mean;%ͳ��mean��blf_alpha_v����ţ�С��2e-3�ܴﵽ������ܡ�
        end
    end
    %% �������֣�������������
    if EstimateLmd % ����lemmda
        Sum_OvAll_m=zeros(K,1); %
        for m=1:M
            sum_xn_hn=zeros(K,1);    %xn,hn �����˻�����n���
            sum_xn_vhmn=zeros(K,1);     %xn,vhn,vxn,hn���棬��n���
            y=RecvCell{m}.y(pilotSubcIndx);
            for n=1:N
                blf_x_m=SendCell{n}.x(pilotSubcIndx);
                blf_x_v=zeros(length(blf_x_m),1);
                blf_h_m=ChnlEstCell{m,n}.blf_h_m;
                blf_h_v=ChnlEstCell{m,n}.blf_h_v;
                
                sum_xn_vhmn=sum_xn_vhmn+abs(blf_x_m).^2.*blf_h_v+abs(blf_h_m).^2.*blf_x_v+blf_x_v.*blf_h_v;  %xn,vhn,vxn,hn���棬��n���
                sum_xn_hn=sum_xn_hn+blf_x_m.*blf_h_m; %xn,hn �����˻�����n���
            end
            Sum_OvAll_m=Sum_OvAll_m+abs(y-sum_xn_hn).^2+sum_xn_vhmn; %��m���
        end
        LmdEst=M*K/sum(Sum_OvAll_m);    %��k���
    end
%     blf_alpha_v=ChnlEstCell{1,1}.blf_alpha_v;
%     mean_alphav=mean(blf_alpha_v);
%     if mean_alphav<threshold
%         break;
%     end
end
end




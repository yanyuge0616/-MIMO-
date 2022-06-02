function [ChnlEstCell]=SparseChnlEstGlobal_Ser(SysSturct,ChnlEstCell,ChnlCell,DecodeStruct,Niter)
%function��ȫ�֣���Ƶ�����ݺϼ���ϡ�豴Ҷ˹����
%time��16.5.5PM
%ע�ͣ���1����ȫ��ChnlEstCell��ֵ������ChnlEstCell����2��������Ա�cell�ĺϼ���Ƶ��ĺϼ���ֵ������ChnlEstCell��
%��3������ChnlEstCell����ϡ����ơ���4������д��ȫ��ChnlEstCell��
M=SysSturct.M;
N=SysSturct.N;
pilotSubcIndxTotal=DecodeStruct.pilotSubcIndx;
dataSubcIndx=DecodeStruct.dataSubcIndx;
pilotSubcIndx=pilotSubcIndxTotal(1,:);
GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %�ı�indexλ��1
%GlobalSubcIndx=dataSubcIndx;
[~,K]=size(GlobalSubcIndx);
Phi=ChnlCell{1,1}.Phi;
[~, L]=size(Phi);
%% ��1��
SubChnlEstCell=ChnlEstCell;
%% ��2��
for n=1:N
    dataSubcIndx=DecodeStruct.dataSubcIndx;
    pilotSubcIndx=pilotSubcIndxTotal(n,:);
    GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %�ı�indexλ��1
    for m=1:M
        SubChnlEstCell{m,n}.msg_alpha2h_v=ChnlEstCell{m,n}.msg_alpha2h_v(GlobalSubcIndx,:);
        SubChnlEstCell{m,n}.msg_alpha2h_m=ChnlEstCell{m,n}.msg_alpha2h_m(GlobalSubcIndx,:);
        
        SubChnlEstCell{m,n}.msg_h2alpha_v=ChnlEstCell{m,n}.msg_h2alpha_v(GlobalSubcIndx,:);
        SubChnlEstCell{m,n}.msg_h2alpha_m=ChnlEstCell{m,n}.msg_h2alpha_m(GlobalSubcIndx,:);
        
        SubChnlEstCell{m,n}.blf_h_v=ChnlEstCell{m,n}.blf_h_v(GlobalSubcIndx);
        SubChnlEstCell{m,n}.blf_h_m=ChnlEstCell{m,n}.blf_h_m(GlobalSubcIndx);
        
        SubChnlEstCell{m,n}.msg_p_v=ChnlEstCell{m,n}.msg_p_v(GlobalSubcIndx);
        SubChnlEstCell{m,n}.msg_p_m=ChnlEstCell{m,n}.msg_p_m(GlobalSubcIndx);
        
        SubChnlEstCell{m,n}.msg_fy2h_m=ChnlEstCell{m,n}.msg_fy2h_m(GlobalSubcIndx);
        SubChnlEstCell{m,n}.msg_fy2h_v=ChnlEstCell{m,n}.msg_fy2h_v(GlobalSubcIndx);
    end
end
%% ��3��
for iter=1:Niter
    for n=1:N
        for m=1:M
            %% ��һ���֣���������alpha
            pilotSubcIndx=pilotSubcIndxTotal(n,:);
            GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %�ı�indexλ��2
            %GlobalSubcIndx=dataSubcIndx;    %���ԣ�ֻ�������ݲ��֣�������Ƶ�����ݹ��õ����
            Phi=ChnlCell{m,n}.Phi;
            phi=Phi(GlobalSubcIndx,:);
            msg_fy2h_m=SubChnlEstCell{m,n}.msg_fy2h_m;
            msg_fy2h_v=SubChnlEstCell{m,n}.msg_fy2h_v;
            %һ��ϡ�豴Ҷ˹���ơ�
            [SubChnlEstCell{m,n}]=SparseChannelEstBayOne(phi,K,L,M,SubChnlEstCell{m,n},msg_fy2h_m,msg_fy2h_v);
            
            %% �ڶ����֣����¶�Ӧmn��alpha�Ķ��׾ض�����M���
            SumScndMmt=zeros(L,1);
            for mm=1:M
                blf_alpha_m=SubChnlEstCell{mm,n}.blf_alpha_m;
                blf_alpha_v=SubChnlEstCell{mm,n}.blf_alpha_v;
                SumScndMmt=SumScndMmt+abs(blf_alpha_m).^2+blf_alpha_v;  %�����ж��׾����
            end
            SubChnlEstCell{m,n}.SumScndMmt=SumScndMmt; %д��cell

            %% �������֣�����gamma��alpha��alpha-h��Ϣ��b��h����
            [SubChnlEstCell{m,n}]=SparseChannelEstBayTwo(phi,K,L,M,SubChnlEstCell{m,n},msg_fy2h_m,msg_fy2h_v);
            %             alpha=ChnlCell{m,n}.alpha;  %��ʵ�ĳ�ͷ
            %             alpha_est=SubChnlEstCell{m,n}.blf_alpha_m;
            %             SubChnlEstCell{m,n}.MSE_Alpha(iter) = mean(abs(SubChnlEstCell{m,n}.blf_alpha_m-alpha).^2);
        end
    end
end
%% ��4��
for n=1:N
    dataSubcIndx=DecodeStruct.dataSubcIndx;
    pilotSubcIndx=pilotSubcIndxTotal(n,:);
    GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %�ı�indexλ��1
    for m=1:M
        %�ٽ�ȥ����ȱ�Ժ���ŵ����ƽ����д���Ͻṹ�壨ֻд���ǿ�ȱ��λ�ã���
        ChnlEstCell{m,n}.msg_alpha2h_v(GlobalSubcIndx,:)=SubChnlEstCell{m,n}.msg_alpha2h_v;
        ChnlEstCell{m,n}.msg_alpha2h_m(GlobalSubcIndx,:)=SubChnlEstCell{m,n}.msg_alpha2h_m;
        
        ChnlEstCell{m,n}.msg_h2alpha_v(GlobalSubcIndx,:)=SubChnlEstCell{m,n}.msg_h2alpha_v;
        ChnlEstCell{m,n}.msg_h2alpha_m(GlobalSubcIndx,:)=SubChnlEstCell{m,n}.msg_h2alpha_m;
        
        ChnlEstCell{m,n}.blf_h_v(GlobalSubcIndx)=SubChnlEstCell{m,n}.blf_h_v;
        ChnlEstCell{m,n}.blf_h_m(GlobalSubcIndx)=SubChnlEstCell{m,n}.blf_h_m;
        
        ChnlEstCell{m,n}.msg_p_v(GlobalSubcIndx)=SubChnlEstCell{m,n}.msg_p_v;
        ChnlEstCell{m,n}.msg_p_m(GlobalSubcIndx)=SubChnlEstCell{m,n}.msg_p_m;
        
        ChnlEstCell{m,n}.msg_fy2h_m(GlobalSubcIndx)=SubChnlEstCell{m,n}.msg_fy2h_m;
        ChnlEstCell{m,n}.msg_fy2h_v(GlobalSubcIndx)=SubChnlEstCell{m,n}.msg_fy2h_v;
    end
end
end
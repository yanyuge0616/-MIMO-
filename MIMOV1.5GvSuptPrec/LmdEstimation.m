function LmdEst=LmdEstimation(SysSturct,DecodeStruct,RecvCell,SendCell,ChnlEstCell,XnCell)
%function:����lembda,��δ��ɣ�
%time: 16.5.4PM
%note: �˴�����lemmdaֻ�������ݲ��֣������ǵ�Ƶ�����ݹ�ͬ����
M=SysSturct.M;
N=SysSturct.N;
pilotSubcIndxTotal=DecodeStruct.pilotSubcIndx;
dataSubcIndx=DecodeStruct.dataSubcIndx;
pilotSubcIndx=pilotSubcIndxTotal(1,:);
%GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %�ı�indexλ��1
%Kglobal=length(GlobalSubcIndx);% ֻ����data+pilot���ֵ�size
K=length(RecvCell{1}.y);   %�������ز�����
Sum_OvAll_m=zeros(K,1); 
blf_x_m=zeros(K,1);
blf_x_v=zeros(K,1);
for m=1:M
    sum_xn_hn=zeros(K,1);    %xn,hn �����˻�����n���
    sum_xn_vhmn=zeros(K,1);     %xn,vhn,vxn,hn���棬��n���
    y=RecvCell{m}.y;
    for n=1:N
        pilotSubcIndx=pilotSubcIndxTotal(n,:);  %ȡ�ô˷�������n��pilot index
        %GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %ȡ�ô˷�������n��global index
        blf_x_m(pilotSubcIndx)=SendCell{n}.x(pilotSubcIndx);    %��Դ�pilot index ������ʵ��x������Ϊ0
        blf_x_v(pilotSubcIndx)=0;
        blf_x_m(dataSubcIndx)=XnCell{n}.blf_x_m;    %ʣ���data index �������Ƶõ���b(x)
        blf_x_v(dataSubcIndx)=XnCell{n}.blf_x_v;
        
        blf_h_m=ChnlEstCell{m,n}.blf_h_m;
        blf_h_v=ChnlEstCell{m,n}.blf_h_v;
        
        sum_xn_vhmn=sum_xn_vhmn+abs(blf_x_m).^2.*blf_h_v+abs(blf_h_m).^2.*blf_x_v+blf_x_v.*blf_h_v;  %xn,vhn,vxn,hn���棬��n���
        sum_xn_hn=sum_xn_hn+blf_x_m.*blf_h_m; %xn,hn �����˻�����n���
    end
    Sum_OvAll_m=Sum_OvAll_m+abs(y-sum_xn_hn).^2+sum_xn_vhmn;
end
LmdEst=M*K/sum(Sum_OvAll_m);
end
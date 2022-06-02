function output=stbc_code_TX(input)
%----------------------------------------------------------------------

%�������OFDM���Ž��п�ʱ���룬�����������ĸ��������ߡ�
%inputΪ������źţ�input������Ϊ������������
%input��ÿһ����һ��OFDM���ţ�
%outputΪ�����OFDM���ţ������˿�ʱ������룩

% ��д: ������ , 2004.3
%----------------------------------------------------------------------
index=size(input,2);
if index==2   %����������Ϊ2
    Xe=input(:,1);%ȡ��һ�У�����һ��OFDM����
    Xo=input(:,2);%ȡ�ڶ��У����ڶ���OFDM����
    output=[Xe Xo;-conj(Xo) conj(Xe)];%alamouti����
elseif index==4
    X1=input(:,1);
    X2=input(:,2);
    X3=input(:,3);
    X4=input(:,4);
    output=[X1 X2 X3  X4;...
        -X2 X1 -X4 X3;...
        -X3 X4 X1 -X2;...
        -X4 -X3 X2 X1;...
        conj(X1) conj(X2) conj(X3) conj(X4);...
        -conj(X2) conj(X1) -conj(X4) conj(X3);...
        -conj(X3) conj(X4) conj(X1) -conj(X2);...
        -conj(X4) -conj(X3) conj(X2) conj(X1)];
else fprintf('���벻��ȷ������������')
end


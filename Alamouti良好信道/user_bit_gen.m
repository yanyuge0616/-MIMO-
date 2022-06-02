
function [user_bit,user_bit_cnt]  = user_bit_gen( N_user, N_data ,N_sym , Modulation )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����:       ������ͬ�û�һ֡�ڵķ��ͱ���
%           ��cell�ṹ���װ��ͬ�û�������,��Ϊcell�ṹ��ľ���Ԫ�ؿ���ά����ͬ
% ����:     N_user,�û���
%           N_data,�������ز��� 
%           N_sym,ÿ֡OFDM������
%           Modulation, ���Ʒ�ʽ
% ���:     user_bit, ÿ���û��ı�������,Ϊcell�ṹ
%           user_bit_cnt, ÿ���û������г���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ÿ���û���һ��OFDM�����ڼ䷢�͵ı�����
user_bit_tmp = cell( 1,N_user );
bit_per_sym = Modulation * N_data;%�����û���һ��OFDM�����ڴ��͵���bit��

% ����ѡ���û����طֲ�Ϊ��
% 1) �����û�������ͬ�� 
bit_cnt_sym = repmat(bit_per_sym/N_user,1,N_user);

% 2) �û����ձ��� (1:N_user)/((1 + N_user)*N_user/2) ���ͱ�������
% Ŀ����Ϊ�˷��治ͬ�û�����Ϣ���س��Ȳ�ͬ�����,Ҳ�����޸ĵõ��������û����ݱ���
% bit_cnt_sym = round( [1:N_user]/((1 + N_user)*N_user/2) * bit_per_sym );

user_bit_cnt = bit_cnt_sym * N_sym ;%ÿ�û�һ֡�ڱ�����

for u = 1:N_user 
    user_bit_tmp{u} = rand (  user_bit_cnt(u) ,1 ) > 0.5 ;%�����������������
end


user_bit = user_bit_tmp;
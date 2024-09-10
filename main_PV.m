%% ���ģ�Ͳ���ʶ��ʵ��
% parameter extraction of photovoltaic models
%% ��ע΢�Ź��ںţ��Ż��㷨��   Swarm-Opti
% https://mbd.pub/o/author-a2mVmGpsYw==
clc
clear 
close all
%% 1.һЩ��������
run_times= 5; % ���д����������޸ģ�
nPop=30;%�Ż��㷨����Ⱥ��
Max_iter=100;%�Ż��㷨������������
%--------------------------------------------------------------------------
%                                     ѡ��PVģ��
%--------------------------------------------------------------------------
pv_type='PMM'; % pvģ��ѡ�����
% pv_type='1DM'; ѡ�� single-diode model��1DM 
% pv_type='2DM'; ѡ�� double-diode model��2DM 
% pv_type='3DM'; ѡ�� three-diode model��3DM 
% pv_type='4DM'; ѡ�� four-diode model��4DM 
% pv_type='PMM'; ѡ�� PV module-diode model��PMM
% ����Ż������ĸ�Ԫ�أ�lb-���ޣ�ub-���ޣ�dim-����������fobj-Ŀ�꺯��
% x_str-��������
[lb,ub,dim,fobj,x_str] = select_PV_model(pv_type);
%% 2.�����Ż��㷨-���������㷨
addpath(genpath('optimization')); % �������Ż��㷨���ļ����뵽·����
Optimal_results={}; % ���������Optimal results
% ��1�У��㷨����
% ��2�У���������
% ��3�У����ź���ֵ
% ��4�У����Ž�
% ��5�У�����ʱ��
disp('��ע΢�Ź��ںţ��Ż��㷨��   Swarm-Opti')
disp('---------------------------Runing------------------------------')
for run_time=1:run_times
% ----------------------------------����㷨������λ����DBOΪ��--------------------------------
tic
[Best_f,Best_x,cg_curve]=DBO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,1}='DBO';         % �㷨����
Optimal_results{2,1}(run_time,:)=cg_curve;      % ��������
Optimal_results{3,1}(run_time,:)=Best_f;          % ���ź���ֵ
Optimal_results{4,1}(run_time,:)=Best_x;          % ���ű���
Optimal_results{5,1}(run_time,:)=toc;               % ����ʱ��
%---------------------------------������㷨Ϊ�Աȵ��㷨----------------------------------
%----------------------------------- HHO----------------------------------- 
tic
[Best_f,Best_x,cg_curve]=HHO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,2}='HHO';
Optimal_results{2,2}(run_time,:)=cg_curve;
Optimal_results{3,2}(run_time,:)=Best_f;
Optimal_results{4,2}(run_time,:)=Best_x;
Optimal_results{5,2}(run_time,:)=toc;

%-----------------------------------  GWO----------------------------------- 
tic
[Best_f,Best_x,cg_curve]=GWO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,3}='GWO';
Optimal_results{2,3}(run_time,:)=cg_curve;
Optimal_results{3,3}(run_time,:)=Best_f;
Optimal_results{4,3}(run_time,:)=Best_x;
Optimal_results{5,3}(run_time,:)=toc;


end
% �������������Ż��㷨�� ��ͬ����֮ͬ������
% ֻ���޸�������1.�㷨����(ǰ�����㷨�������ͳһ��ʽ)��2��Optimal_results{m,n}�е�λ��n
rmpath(genpath('optimization')); % ʹ������Ƴ�·��

%% 3.����ͳ�Ʋ���
%     Results�ĵ�1�� = �㷨����
%     Results�ĵ�2�� =ƽ����������
%     Results�ĵ�3�� =���ֵworst
%     Results�ĵ�4�� = ����ֵbest
%     Results�ĵ�5�� =��׼��ֵ std
%     Results�ĵ�6�� = ƽ��ֵ mean
%     Results�ĵ�7�� = ��ֵ   median
[Results,wilcoxon_test,friedman_p_value]=Cal_stats(Optimal_results);
% �Զ�ν��������ֵ ��Ϊ���ս��
for k=1:size(Optimal_results, 2)
    [m,n]=min(Optimal_results{3, k}); % �ҵ� best_f �����Сֵ������ ��m�� ��n��
    opti_para(k,:)=Optimal_results{4, k}(n, :) ; % ������С����ֵ �ҵ���Ӧ�����Ž⣬��Ϊ�㷨���յĽ��
end
%% 4.���浽excel
filename = [pv_type '-RMSE.xlsx']; % ������ļ�����
sheet = 1; % ���浽��1��sheet
str1={'name';'ave-cg';'worst';'best';'std';'mean';'median'};
xlswrite(filename, str1, sheet, 'A1' )
xlswrite(filename,Results, sheet, 'B1' ) % ͳ��ָ��
% �������Ž�
sheet = 2 ;% ���浽��2��sheet
xlswrite(filename, x_str, sheet, 'B1' ) % ��������
xlswrite(filename, Optimal_results(1,:)', sheet, 'A2' ) % �㷨����
xlswrite(filename,opti_para, sheet, 'B2' ) % ���Ž�
% ����wilcoxon_test
sheet = 3 ;% ���浽��3��sheet
str2={'wilcoxon-sign';'wilcoxon-ranksum';'friedman'};
% ����Ϊ��Ŀ���㷨���㷨1��Ŀ���㷨���㷨3��Ŀ���㷨���㷨3.......
xlswrite(filename, str2, sheet, 'A1' ) % 
xlswrite(filename, wilcoxon_test.signed_p_value, sheet, 'B1' ) % wilcoxon-sign
xlswrite(filename, wilcoxon_test.ranksum_p_value, sheet, 'B2' ) % wilcoxon-ranksum
xlswrite(filename, friedman_p_value, sheet, 'B3' ) % friedman
%% ���浽mat(�������棬���Խ��˲���ע�͵�)
% �� ��� ���� mat
save ([pv_type '-results.mat'], 'Optimal_results', 'Results','wilcoxon_test','friedman_p_value','opti_para')
%% 5. �����Ų�������������յ����
% �����㷨�ҵ�����ֵ���룬�������ǵ��㷨��DBO����opti_para��һ�У�opti_para(1,:)

[Vm,Im,Pm,Io,Po,IIAE,IRE,PIAE,PRE]=Cal_models(opti_para(1,:),pv_type);

% ������
sheet = 4 ;% ���浽��3��sheet
str3={'Vm','Im','Pm','Io','Po','I_IAE','I_RE','P_IAE','P_RE'};
% ��str3��˳�򽫽����������
RR=[Vm,Im,Pm,Io,Po,IIAE,IRE,PIAE,PRE];
xlswrite(filename, str3, sheet, 'A1' ) % 
xlswrite(filename, RR, sheet, 'A2' ) %

%% 6. ��ͼ
figure('name','ƽ����������')
for i = 1:size(Optimal_results, 2)
%     plot(mean(Optimal_results{2, i},1),'Linewidth',2)
    semilogy(mean(Optimal_results{2, i},1),'Linewidth',2)
    hold on
end
title(['Convergence curve on ' pv_type])
xlabel('Iteration');ylabel(['Best score']);
grid on; box on
set(gcf,'Position',[100 200 400 250]);
legend(Optimal_results{1, :})
saveas(gcf,[pv_type '-��������']) % ����ͼ��
%-------------------------------------------------------------------------
% boxplot ����ͼ-��Ҫÿ�ε�׼ȷ�ʣ�Optimal_results�ĵ�7�У�

boxplot_mat = []; % ����
for i=1:size(Optimal_results,2)
    boxplot_mat = cat(2,boxplot_mat,Optimal_results{3,i});
end
figure('Position',[200 200 400 200]) % ͼ��λ�ü���С
boxplot(boxplot_mat)
ylabel('Accuracy');xlabel('Different Algorithms'); % ����x������ǩ
title(['Boxplot on ' pv_type])
set(gca,'XTickLabel',{Optimal_results{1, :}},'color','none'); % ����x�̶ȱ�ǩ
saveas(gcf,[pv_type '-����ͼ']) % ����ͼ��
%-------------------------------------------------------------------
%                      ����ֻչʾ Ŀ���㷨 
%------------------------------------------------------------------
figure('name','I-V����')
plot(Vm,Im,'LineWidth',2)
hold on
plot(Vm,Io,'o','LineWidth',2,'MarkerFaceColor','black')
xlabel('Voltage(V)')
ylabel('Current(A)')
title(['I-V of ' pv_type])
set(gcf,'Position',[400 300 400 250]);
legend('Measured','Estimated','location','southwest')
saveas(gcf,[pv_type '-I-V����']) % ����ͼ��
%-----------------------------------------------------------------------
figure('name','P-V����')
plot(Vm,Pm,'LineWidth',2)
hold on
plot(Vm,Po,'o','LineWidth',2,'MarkerFaceColor','black')
xlabel('Voltage(V)')
ylabel('Power(W)')
title(['P-V of ' pv_type])
set(gcf,'Position',[700 300 400 250]);
legend('Measured','Estimated','location','northwest')
saveas(gcf,[pv_type '-P-V����']) % ����ͼ��
%%
disp('--------------------------End-------------------------------')
disp('��ע΢�Ź��ںţ��Ż��㷨��   Swarm-Opti')
%% 光伏模型参数识别实验
% parameter extraction of photovoltaic models
%% 关注微信公众号：优化算法侠   Swarm-Opti
% https://mbd.pub/o/author-a2mVmGpsYw==
clc
clear 
close all
%% 1.一些参数设置
run_times= 5; % 运行次数（自行修改）
nPop=30;%优化算法的种群数
Max_iter=100;%优化算法的最大迭代次数
%--------------------------------------------------------------------------
%                                     选择PV模型
%--------------------------------------------------------------------------
pv_type='PMM'; % pv模型选择变量
% pv_type='1DM'; 选择 single-diode model，1DM 
% pv_type='2DM'; 选择 double-diode model，2DM 
% pv_type='3DM'; 选择 three-diode model，3DM 
% pv_type='4DM'; 选择 four-diode model，4DM 
% pv_type='PMM'; 选择 PV module-diode model，PMM
% 输出优化问题四个元素：lb-下限，ub-上限，dim-变量个数，fobj-目标函数
% x_str-变量名字
[lb,ub,dim,fobj,x_str] = select_PV_model(pv_type);
%% 2.调用优化算法-可用其他算法
addpath(genpath('optimization')); % 将放有优化算法的文件加入到路径中
Optimal_results={}; % 结果保存在Optimal results
% 第1行：算法名字
% 第2行：收敛曲线
% 第3行：最优函数值
% 第4行：最优解
% 第5行：运行时间
disp('关注微信公众号：优化算法侠   Swarm-Opti')
disp('---------------------------Runing------------------------------')
for run_time=1:run_times
% ----------------------------------你的算法放在首位：以DBO为例--------------------------------
tic
[Best_f,Best_x,cg_curve]=DBO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,1}='DBO';         % 算法名字
Optimal_results{2,1}(run_time,:)=cg_curve;      % 收敛曲线
Optimal_results{3,1}(run_time,:)=Best_f;          % 最优函数值
Optimal_results{4,1}(run_time,:)=Best_x;          % 最优变量
Optimal_results{5,1}(run_time,:)=toc;               % 运行时间
%---------------------------------后面的算法为对比的算法----------------------------------
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
% 发现上述调用优化算法的 不同和相同之处了吗？
% 只需修改两处：1.算法名字(前提是算法需整理成统一格式)，2，Optimal_results{m,n}中的位置n
rmpath(genpath('optimization')); % 使用完后移除路径

%% 3.计算统计参数
%     Results的第1行 = 算法名字
%     Results的第2行 =平均收敛曲线
%     Results的第3行 =最差值worst
%     Results的第4行 = 最优值best
%     Results的第5行 =标准差值 std
%     Results的第6行 = 平均值 mean
%     Results的第7行 = 中值   median
[Results,wilcoxon_test,friedman_p_value]=Cal_stats(Optimal_results);
% 以多次结果的最优值 作为最终结果
for k=1:size(Optimal_results, 2)
    [m,n]=min(Optimal_results{3, k}); % 找到 best_f 里的最小值索引： 第m行 第n列
    opti_para(k,:)=Optimal_results{4, k}(n, :) ; % 利用最小索引值 找到对应的最优解，作为算法最终的结果
end
%% 4.保存到excel
filename = [pv_type '-RMSE.xlsx']; % 保存的文件名字
sheet = 1; % 保存到第1个sheet
str1={'name';'ave-cg';'worst';'best';'std';'mean';'median'};
xlswrite(filename, str1, sheet, 'A1' )
xlswrite(filename,Results, sheet, 'B1' ) % 统计指标
% 保存最优解
sheet = 2 ;% 保存到第2个sheet
xlswrite(filename, x_str, sheet, 'B1' ) % 变量名字
xlswrite(filename, Optimal_results(1,:)', sheet, 'A2' ) % 算法名字
xlswrite(filename,opti_para, sheet, 'B2' ) % 最优解
% 保存wilcoxon_test
sheet = 3 ;% 保存到第3个sheet
str2={'wilcoxon-sign';'wilcoxon-ranksum';'friedman'};
% 依次为：目标算法与算法1，目标算法与算法3，目标算法与算法3.......
xlswrite(filename, str2, sheet, 'A1' ) % 
xlswrite(filename, wilcoxon_test.signed_p_value, sheet, 'B1' ) % wilcoxon-sign
xlswrite(filename, wilcoxon_test.ranksum_p_value, sheet, 'B2' ) % wilcoxon-ranksum
xlswrite(filename, friedman_p_value, sheet, 'B3' ) % friedman
%% 保存到mat(若不保存，可以将此部分注释掉)
% 将 结果 保存 mat
save ([pv_type '-results.mat'], 'Optimal_results', 'Results','wilcoxon_test','friedman_p_value','opti_para')
%% 5. 将最优参数代入计算最终的输出
% 将你算法找的最优值代入，这里我们的算法是DBO，即opti_para第一行：opti_para(1,:)

[Vm,Im,Pm,Io,Po,IIAE,IRE,PIAE,PRE]=Cal_models(opti_para(1,:),pv_type);

% 保存结果
sheet = 4 ;% 保存到第3个sheet
str3={'Vm','Im','Pm','Io','Po','I_IAE','I_RE','P_IAE','P_RE'};
% 按str3的顺序将结果整理起来
RR=[Vm,Im,Pm,Io,Po,IIAE,IRE,PIAE,PRE];
xlswrite(filename, str3, sheet, 'A1' ) % 
xlswrite(filename, RR, sheet, 'A2' ) %

%% 6. 绘图
figure('name','平均收敛曲线')
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
saveas(gcf,[pv_type '-收敛曲线']) % 保存图窗
%-------------------------------------------------------------------------
% boxplot 箱线图-需要每次的准确率（Optimal_results的第7行）

boxplot_mat = []; % 矩阵
for i=1:size(Optimal_results,2)
    boxplot_mat = cat(2,boxplot_mat,Optimal_results{3,i});
end
figure('Position',[200 200 400 200]) % 图框位置及大小
boxplot(boxplot_mat)
ylabel('Accuracy');xlabel('Different Algorithms'); % 设置x轴和轴标签
title(['Boxplot on ' pv_type])
set(gca,'XTickLabel',{Optimal_results{1, :}},'color','none'); % 设置x刻度标签
saveas(gcf,[pv_type '-箱线图']) % 保存图窗
%-------------------------------------------------------------------
%                      这里只展示 目标算法 
%------------------------------------------------------------------
figure('name','I-V曲线')
plot(Vm,Im,'LineWidth',2)
hold on
plot(Vm,Io,'o','LineWidth',2,'MarkerFaceColor','black')
xlabel('Voltage(V)')
ylabel('Current(A)')
title(['I-V of ' pv_type])
set(gcf,'Position',[400 300 400 250]);
legend('Measured','Estimated','location','southwest')
saveas(gcf,[pv_type '-I-V曲线']) % 保存图窗
%-----------------------------------------------------------------------
figure('name','P-V曲线')
plot(Vm,Pm,'LineWidth',2)
hold on
plot(Vm,Po,'o','LineWidth',2,'MarkerFaceColor','black')
xlabel('Voltage(V)')
ylabel('Power(W)')
title(['P-V of ' pv_type])
set(gcf,'Position',[700 300 400 250]);
legend('Measured','Estimated','location','northwest')
saveas(gcf,[pv_type '-P-V曲线']) % 保存图窗
%%
disp('--------------------------End-------------------------------')
disp('关注微信公众号：优化算法侠   Swarm-Opti')
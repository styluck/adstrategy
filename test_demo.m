% demo of testing recurrence algorithm
%
% create: L.Xiao 07-2022
clc; clear; close all;
tic;
A = dir('data/*.mat');
% params
N_test = 50;
N_data = length(A);
prtflg = 0;
alflg = 0;
L = logspace(-10,0,N_test);
clist = zeros(N_test, 4);
clist2 = zeros(N_test, 4);
X_sum = zeros(24,N_test);
for i = 1:N_test
    [clist(i,1), clist(i,2), clist(i,3), X_sum(:,i)] = recurrence_algo(L(i), prtflg, alflg);
    clist(i,4) = sum(X_sum(:,i));
%      [clist2(i,1), clist2(i,2), clist2(i,3), clist2(i,4)] = recurrence_algo(L(i), prtflg, 0);
end

%% ploting

scrsz = get(0,'ScreenSize');
figure('Position',[100 scrsz(4)*.22 scrsz(3)*.65 scrsz(4)*.65])
subplot(2,2,1)
semilogx(L, clist(:,3), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% semilogx(L, clist2(:,3), 'g-o','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('Probability');
grid on
% legend('inefficient','efficient','location', 'Northeast');
title(['(a). $P(Buy | \{c \in \mathcal{F}^s\})$'],'Interpreter','latex');
y_axes1 = string(linspace(0,500,6)) + 'B';
set(gca,'yticklabel', y_axes1,'TickLabelInterpreter', 'none')

subplot(2,2,2)
loglog(L, clist(:,2), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% loglog(L, clist2(:,2), 'g-o','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('Probability');
grid on
% legend('inefficient','efficient','location', 'Northwest');
title(['(b). $P(\{c \in \mathcal{F}^s\})$'],'Interpreter','latex');

subplot(2,2,3)
loglog(L, clist(:,1), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% semilogx(L, clist2(:,1), 'g-o','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('Probability');
grid on
% legend('inefficient','efficient','location', 'Northwest');
title(['(c). $P(Buy \cap \{c \in \mathcal{F}^s\})$'],'Interpreter','latex');
% set(gca,'YTick', logspace(0,1,6))
y_axes3 = string(logspace(-10,0,6)) + 'B';
set(gca,'yticklabel', y_axes3,'TickLabelInterpreter', 'none')

subplot(2,2,4)
semilogx(L, clist(:,4), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% semilogx(L, clist2(:,4), 'g-o','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('number');
grid on
% legend('inefficient','efficient','location', 'Northeast');
title(['(d). Number of feature selected'],'Interpreter','latex');

set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'fig1','-dpdf','-r0')
% %% q ploting
% figure('Position',[100 scrsz(4)*.22 scrsz(3)*.8 scrsz(4)*.7])
% semilogx(clist(:,2), clist(:,3).*clist(:,1), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% % semilogx(L, clist2(:,3), 'g-o','MarkerSize',20,'linewidth',1);
% xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('Probability');
% grid on
% % legend('inefficient','efficient','location', 'Northeast');
% title(['(a). $P(Buy | \{c \in \mathcal{F}^s\})$'],'Interpreter','latex');
% % y_axes1 = string(linspace(0,300,7)) + 'B';
% % set(gca,'yticklabel', y_axes1,'TickLabelInterpreter', 'none')

%% signal ploting
y_axes = {};
for i=1:N_data
    y_axes(i) = {A(i).name(1:end-4)};
end

figure('Position',[100 scrsz(4)*.22 scrsz(3)*.5 scrsz(4)*.45]);
[r, c] = size(X_sum);                          % Get the matrix size
a=imagesc(L, (1:r)+0.5, X_sum);                  % Plot the image
% colormap([0 1 0]);                              % Use a gray colormap
set(gca,'XScale','log');
xlabel('Required minimum coverage $L$', 'Interpreter','latex');
yticks(1:N_data)
set(gca,'yticklabel', y_axes,'TickLabelInterpreter', 'none')
colormap([1 1 1; 0 0 0]);          % cool


set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'fig2','-dpdf','-r0')
%% feature ploting
X_freq = sum(X_sum,2);
figure('Position',[100 scrsz(4)*.22 scrsz(3)*.4 scrsz(4)*.6]); 
bar(1:N_data, X_freq);
set(gca,'XTick', 1:N_data)
set(gca,'xticklabel', y_axes,'TickLabelInterpreter', 'none')
xtickangle(90)
grid on

set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'fig3','-dpdf','-r0')
%% derivative
logP = log((clist(:,1)));
logL = log(L)';
logLsq = logL.*logL;

mdl = fitlm([logL, logLsq],logP);
derip = mdl.Coefficients.Estimate(2) + mdl.Coefficients.Estimate(3)*logL;
%%
figure('Position',[100 scrsz(4)*.22 scrsz(3)*.6 scrsz(4)*.4]);
subplot(1,2,1)
loglog(L, clist(:,1), 'r-s','MarkerSize',10,'linewidth',1); hold on;
loglog(L, exp(mdl.Fitted), 'k','MarkerSize',20,'linewidth',1);
loglog(L, exp(mdl.Fitted+2*mdl.RMSE), 'b-.','MarkerSize',20,'linewidth',1);
loglog(L, exp(mdl.Fitted-2*mdl.RMSE), 'b-.','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('Probability');
grid on
legend('original','fitted','location', 'Northwest');
title(' $P(Buy \cap \{c \in \mathcal{F}^s\})$','Interpreter','latex');
set(gca,'yticklabel', y_axes3, 'TickLabelInterpreter', 'none')

subplot(1,2,2)
loglog(L, derip(:,1), 'r-s','MarkerSize',10,'linewidth',1); hold on;
loglog(L,derip(20,1)*ones(N_test,1),'g-o','MarkerSize',10,'linewidth',1)
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   
ylabel('\partial P/\partial L');
legend('derivative of probability','optimal derivative','location', 'Northeast');
grid on
title(' $\partial P(Buy \cap \{c \in \mathcal{F}^s\})/\partial L$','Interpreter','latex');

set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'fig4','-dpdf','-r0')
%%

toc;
% [EOF]
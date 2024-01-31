% use linear programming to solve multiple choice knapsack problem
clc; clear; close all;

% define params & load data
N_test = 50;
L = logspace(-10,0,N_test);
prtflg = 0;
saveplot = 0;
exclusions = [];
% exclusions = {'Ages','Life_stage','Credit_level',...
%     'Purchasing_power_in_sinking_market', 'purchasing_power_level'};
[p, q, groups, list_name] = loaddata(exclusions);
Lx = length(p);

% accumulators
clist = zeros(N_test, 5);
clist2 = zeros(N_test, 4);
X_sum = zeros(Lx,N_test);
tic;
for iter = 1:N_test
   [clist(iter,1), clist(iter,2), clist(iter,3), X_sum(:,iter), clist(iter,5)] = ...
       linprog_mckp(L(iter), p, q, groups, prtflg);

   clist(iter,4) = sum(X_sum(:,iter));
end
toc;

%% ploting

scrsz = get(0,'ScreenSize');
figure('Position',[100 scrsz(4)*.22 scrsz(3)*.65 scrsz(4)*.5])
subplot(1,2,1)
semilogx(L, clist(:,3), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% semilogx(L, clist2(:,3), 'g-o','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('Probability');
grid on
% legend('inefficient','efficient','location', 'Northeast');
title(['(a). $P(Buy | \{c \in \mathcal{F}^s\})$'],'Interpreter','latex');
y_axes1 = string(linspace(0,500,6)) + 'B';
set(gca,'yticklabel', y_axes1,'TickLabelInterpreter', 'none')

subplot(1,2,2)
loglog(L, clist(:,2), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% loglog(L, clist2(:,2), 'g-o','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('Probability');
grid on
% legend('inefficient','efficient','location', 'Northwest');
title(['(b). $P(\{c \in \mathcal{F}^s\})$'],'Interpreter','latex');


if saveplot
    set(gcf,'Units','Inches');
    pos = get(gcf,'Position');
    set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(gcf,'fig1','-dpdf','-r0')
end

% subplot(2,2,3)
figure
loglog(L, clist(:,1), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% semilogx(L, clist2(:,1), 'g-o','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('Probability');
grid on
% legend('inefficient','efficient','location', 'Northwest');
title(['(c). $P(Buy \cap \{c \in \mathcal{F}^s\})$'],'Interpreter','latex');
% set(gca,'YTick', logspace(0,1,6))
y_axes3 = string(logspace(-10,0,6)) + 'B';
set(gca,'yticklabel', y_axes3,'TickLabelInterpreter', 'none')



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


%% feature ploting
y_axes = list_name;

X_freq = sum(X_sum,2);
N_group = length(list_name);
List_count = zeros(N_group, 1);
X_group = zeros(N_group, N_test);
for i = 1:Lx
    if X_freq(i) > 0
        idx = groups(i);
        List_count(idx) = List_count(idx) + X_freq(i);
        X_group(idx, :) = X_group(idx, :) + X_sum(i, :);
    end
end

figure('Position',[100 scrsz(4)*.22 scrsz(3)*.7 scrsz(4)*.5]);
subplot(1,2,1)
bar(1:N_group, List_count);
set(gca,'XTick', 1:N_group)
set(gca,'xticklabel', y_axes,'TickLabelInterpreter', 'none')
xtickangle(30)
grid on
title(['(a). The frequency of features'],'Interpreter','latex');

subplot(1,2,2)
semilogx(L, clist(:,4), 'r-s','MarkerSize',10,'linewidth',1); hold on;
% semilogx(L, clist2(:,4), 'g-o','MarkerSize',20,'linewidth',1);
xlabel('Required minimum coverage $L$', 'Interpreter','latex');   ylabel('number');
grid on
% legend('inefficient','efficient','location', 'Northeast');
title(['(b). Number of feature selected'],'Interpreter','latex');
if saveplot
    set(gcf,'Units','Inches');
    pos = get(gcf,'Position');
    set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(gcf,'fig3','-dpdf','-r0')
end

%% signal ploting

figure('Position',[100 scrsz(4)*.22 scrsz(3)*.68 scrsz(4)*.45]);
[r, c] = size(X_group);                          % Get the matrix size
a=imagesc(L, (1:r)+0.5, X_group);                  % Plot the image
% colormap([0 1 0]);                              % Use a gray colormap
set(gca,'XScale','log');
xlabel('Required minimum coverage $L$', 'Interpreter','latex');
yticks(1:N_group)
set(gca,'yticklabel', y_axes,'TickLabelInterpreter', 'none')
colormap([1 1 1; 0 0 0]);          % cool

if saveplot
    set(gcf,'Units','Inches');
    pos = get(gcf,'Position');
    set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(gcf,'fig2','-dpdf','-r0')
end

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

if saveplot
    set(gcf,'Units','Inches');
    pos = get(gcf,'Position');
    set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(gcf,'fig4','-dpdf','-r0')
end
%%

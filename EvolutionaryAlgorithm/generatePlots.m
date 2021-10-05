%runEA generates a results file containing all the results
load results
figure('PaperType','<custom>','PaperSize',[6 4],'Color',[1 1 1]);
counter = 3;
hold on
tt = 1:size(results{counter}.phi,2);

if(results{counter}.settings.nArm == 2)
    plot(tt,results{counter}.aveBehaviorDist(1,:),'-','Color', [0.07,0.62,1.00], 'Linewidth', 3)
    plot(tt,results{counter}.aveBehaviorDist(2,:),'-','Color', 'g', 'Linewidth', 3)
end

plot(tt,median(results{counter}.nIL),'Color', 'k', 'Linewidth', 2)


med = median(results{counter}.nIL);
stdX = std(results{counter}.nIL);
x = 1:numel(med);
x2 = [x, fliplr(x)];
std_dev = stdX;
curve1 = med + 1.*std_dev;
curve2 = med - 1.*std_dev;
inBetween = [curve1, fliplr(curve2)];
f = fill(x2, inBetween, 'k', 'FaceAlpha',0.1, 'EdgeColor','none');
set(get(get(f(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');




plot(tt,median(results{counter}.nSL),'Color', 'r', 'Linewidth', 2)

med = median(results{counter}.nSL);
stdX = std(results{counter}.nSL);
x = 1:numel(med);
x2 = [x, fliplr(x)];
std_dev = stdX;
curve1 = med + 1.*std_dev;
curve2 = med - 1.*std_dev;
inBetween = [curve1, fliplr(curve2)];
f = fill(x2, inBetween, 'r', 'FaceAlpha',0.1, 'EdgeColor','none');
set(get(get(f(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

xlabel('Generations (t)')
ylabel('Ratio of the Population')
set(gca,'FontSize',20);
ylim([0,1.1])
% xlim([500,800])

yyaxis right
ylabel('Average Population Reward');% (\phi(t))')
set(gca,'ycolor','m');
ylim([0,1.1])
% xlim([500,800])

    
plot(tt, mean(results{counter}.phi), 'Color', 'm','Linewidth', 2)
plot(tt, mean(results{1}.phi), 'Color', 'b','Linewidth', 2)

if(results{counter}.settings.nArm == 2)
    legend({'A_1','A_2','IL','SL', '\psi(t)','\psi(t)-ILonly'}, ...
        'Position',[0.22 0.85 0.64 0.08], ...
        'FontSize',19,...
        'NumColumns',8,...
        'color','none');
    legend boxoff
else
%     legend({'IL','SL', '\phi(t)'}, ...
    legend({'IL','SL', '\psi(t)','\psi(t)-ILonly'}, ...
        'Position',[0.22 0.85 0.64 0.08], ...
        'FontSize',19,...
        'NumColumns',8,...
        'color','none');
    legend boxoff
end


figure('PaperType','<custom>','PaperSize',[6 4],'Color',[1 1 1]);
hold on;

k=[];
genotypes = [];
for i=1:length(results)
k=[k; median(sum(results{i}.phi,2)) std(sum(results{i}.phi,2))];
plot(results{i}.fitnessHistory, 'LineWidth',1.5)
genotypes = [genotypes; median(sum(results{i}.phi,2)) std(sum(results{i}.phi,2)) results{i}.bestGenotype];
end

xlabel('Generations')
ylabel('Median of the Cumulative Reward')
grid on;
set(gca,'FontSize',15);


figure('PaperType','<custom>','PaperSize',[6 4],'Color',[1 1 1]);

scatter(k(:,2), k(:,1),'*','LineWidth', 2)
xlabel('Standard Deviation of Cumulative Reward')
ylabel('Median of the Cumulative Reward')
grid on;

set(gca,'FontSize',15);


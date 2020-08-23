function runEA()


settings.numOfAgents = 100;
settings.decay = 1/5;
settings.epsilon = 0.1;
settings.T = 300;
settings.visualize = 0;
settings.mutationProb = 5*1e-3;
settings.tau = 1;
settings.period = 100;
nRun = 60;
settings.nArm = 2;

settings.strategy = 'conformist';
runAlgorithm();

%settings.strategy = 'anti-conformist';
%runAlgorithm();

%settings.strategy = 'unbiased';
%runAlgorithm();

%settings.strategy = 'success-based';
%runAlgorithm();



    function runAlgorithm()
        
        results.nIL = zeros(nRun,settings.T);
        results.nSL = zeros(nRun,settings.T);
        results.phi = zeros(nRun,settings.T);
        results.B1 = zeros(nRun,settings.T);
        results.B2 = zeros(nRun,settings.T);

        for i=1:nRun
            res = EvolutionaryAlgorithm(settings);
            results.nIL(i,:) = res.nIL;
            results.nSL(i,:) = res.nSL;
            results.phi(i,:) = res.phi;
            results.B1(i,:) = res.behaviorDist(1,:);
            results.B2(i,:) = res.behaviorDist(2,:);
        end
        results.settings = settings;

        
        %generating the plots
        figure;
        hold on
        tt = 1:settings.T;
        plot(tt,mean(results.nIL),'Color', 'k', 'Linewidth', 2)
        
        
        med = median(results.nIL);
        stdX = std(results.nIL);
        x = 1:numel(med);
        x2 = [x, fliplr(x)];
        std_dev = stdX;
        curve1 = med + 1.*std_dev;
        curve2 = med - 1.*std_dev;
        inBetween = [curve1, fliplr(curve2)];
        f = fill(x2, inBetween, 'k', 'FaceAlpha',0.1, 'EdgeColor','none');
        set(get(get(f(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        plot(tt,median(results.nSL),'Color', 'r', 'Linewidth', 2)
        
        med = median(results.nSL);
        stdX = std(results.nSL);
        x = 1:numel(med);
        x2 = [x, fliplr(x)];
        std_dev = stdX;
        curve1 = med + 1.*std_dev;
        curve2 = med - 1.*std_dev;
        inBetween = [curve1, fliplr(curve2)];
        f = fill(x2, inBetween, 'r', 'FaceAlpha',0.1, 'EdgeColor','none');
        set(get(get(f(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        
        plot(tt,median(results.B1),'--','Color', [0.07,0.62,1.00], 'Linewidth', 2)
        plot(tt,median(results.B2),'--','Color', 'g', 'Linewidth', 2)
        xlabel('Time (t)')
        ylabel('Ratio')
        set(gca,'FontSize',15);
        ylim([0,1.1])

        yyaxis right
        ylabel('\phi(t)')
        set(gca,'ycolor','m');
        ylim([0,1.1])

        plot(tt, median(results.phi), 'Color', 'm','Linewidth', 2)
        legend({'IL','SL','B_1','B_2', '\phi(t)'}, ...
            'Position',[0.22 0.85 0.64 0.08], ...
            'FontSize',13,...
            'NumColumns',5,...
            'color','none');
        legend boxoff
    end


end

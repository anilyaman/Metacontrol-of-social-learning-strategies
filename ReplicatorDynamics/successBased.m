function successBased
T = 399;

tau = 20; %delay for social learners
epsilon  = 0.105; %

phiArr = [];
Tarr = [];

payOpt = normrnd(1,0,1,1000); %introducing some noise for the payoff of optimum behavior
paySOpt = normrnd(0.4,0,1,1000);%introducing some noise for the payoff of sub-optimum behavior1


fB1 = @(t)(1-epsilon)*piB1(t) + epsilon*piB2(t); %Fitness of behavior 1
fB2 = @(t)(1-epsilon)*piB2(t) + epsilon*piB1(t); %Fitness of behavior 2

B10  = 1/3;
B20  = 1/3;
S10  = 1/3;

Y0 = [B10; B20; S10];
tspan   = [0:0.01:T];
[tt, y] = ode45(@sls,tspan,Y0);


%generating the plots
figure('PaperType','<custom>','PaperSize',[6 4],'Color',[1 1 1]);
hold on
plot(tt,y(:,1),'-','Color', [0.07,0.62,1.00], 'Linewidth', 3)
plot(tt,y(:,2),'-','Color', 'g', 'Linewidth', 3)
plot(tt,y(:,1) + y(:,2),'Color', 'k', 'Linewidth', 2)
plot(tt,y(:,3),'Color', 'r', 'Linewidth', 2)
xlabel('Time (t)')
ylabel('Ratio of the Population')
set(gca,'FontSize',20);
ylim([0,1.1])

yyaxis right
ylabel('Average Population Reward');% (\psi(t))')
set(gca,'ycolor','m');
ylim([0,1.1])

inx = Tarr == 0;
Tarr(inx) = [];
phiArr(inx) = [];
plot(Tarr, phiArr, 'Color', 'm','Linewidth', 2)
load individualOnly
plot(Tarr, phiArr, 'Color', 'b','Linewidth', 2)


%legend({'IL','SL','A_1','A_2', '\phi(t)'}, ...
legend({'A_1','A_2','IL','SL', '\psi(t)', '\psi(t)-ILonly'}, ...
            'Position',[0.22 0.85 0.64 0.08], ...
            'FontSize',19,...
            'NumColumns',8,...
            'color','none');
legend boxoff




    function dxdt = sls(t,x)
        %mutation matrix Q       
        Q = [[0.999, 0, 0.001]; [0, 0.999, 0.001]; [0.001, 0.001, 0.998]];
        
        fSt = 0;
        if(t-tau >= 0)
            if(fB1(t-tau) > fB2(t-tau))
                fSt = piB1(t);
            else
                fSt = piB2(t);
            end
        end
        
        f = [fB1(t) fB2(t) fSt];
        phi = f*x; 
        phiArr(floor(t*10)+1) = phi;
        Tarr(floor(t*10)+1) = t;
        
        
        dxdt1 = f*(x.*Q(:,1)) - x(1)*phi; %B1 equation
        dxdt2 = f*(x.*Q(:,2)) - x(2)*phi; %B2 equation
        dxdt3 = f*(x.*Q(:,3)) - x(3)*phi; %S equation
        dxdt = [dxdt1;dxdt2;dxdt3];
    end
    
    function y = piB1(t) %Payoff of behavior 1
        if(t<200)
            y = payOpt(floor(t+1));
        else
            y = paySOpt(floor(t+1));
        end
    end

    function y = piB2(t) %Payoff of behavior 2
        if(t<200)
            y = paySOpt(floor(t+1));
        else
            y = payOpt(floor(t+1));
        end
    end
end
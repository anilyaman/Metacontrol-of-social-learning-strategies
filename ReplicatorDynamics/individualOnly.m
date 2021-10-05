function individualOnly
T = 399;

tau = 1; %delay for social learners
epsilon  = 0.1; %

std_dev = 0; % introduce some noise to the payoffs
payOpt = normrnd(1,0,1,1000); %introducing some noise for the payoff of optimum behavior
paySOpt = normrnd(0.4,0,1,1000);%introducing some noise for the payoff of sub-optimum behavior

%Arrays to keep track of the results at t
Xarr = zeros(2, T);
Tarr = [];
phiArr = [];

%Fitness functions for behavior 1 and 2 
fB1 = @(t)(1-epsilon)*piB1(t) + epsilon*piB2(t); %Fitness of behavior 1
fB2 = @(t)(1-epsilon)*piB2(t) + epsilon*piB1(t); %Fitness of behavior 1

%initial value assignments for B1, B2 and S
B10  = 1/2;
B20  = 1/2;

%Solving the system
Y0 = [B10; B20];
tspan   = [0:0.01:T];
[tt, y] = ode45(@sls,tspan,Y0);


%generating the plots
figure;
hold on
plot(tt,y(:,1) + y(:,2),'Color', 'k', 'Linewidth', 2)
% plot(tt,y(:,1),'--','Color', [0.07,0.62,1.00], 'Linewidth', 2)
% plot(tt,y(:,2),'--','Color', 'g', 'Linewidth', 2)
xlabel('Time (t)')
ylabel('Ratio')
set(gca,'FontSize',15);
ylim([0,1.1])

yyaxis right
ylabel('Average Population Reward (\phi(t))')
set(gca,'ycolor','m');
ylim([0,1.1])

inx = Tarr == 0;
Tarr(inx) = [];
phiArr(inx) = [];
plot(Tarr, phiArr, 'Color', 'm','Linewidth', 2)
save individualOnly Tarr phiArr

% legend({'IL','SL','B_1','B_2', '\phi(t)'}, ...
legend({'IL', '\phi(t)'}, ...
            'Position',[0.22 0.85 0.64 0.08], ...
            'FontSize',13,...
            'NumColumns',5,...
            'color','none');
legend boxoff


    
    function dxdt = sls(t,x)
        
        Xarr(:,floor(t)+1) = x;
        
        Q = [[0.995, 0.005]; [0.005, 0.995]];
        
        f = [fB1(t) fB2(t)];
        phi = f*x; 
        phiArr(floor(t*1)+1) = phi;
        Tarr(floor(t*1)+1) = t;
        
        dxdt1 = f*(x.*Q(:,1)) - x(1)*phi; %B1 equation
        dxdt2 = f*(x.*Q(:,2)) - x(2)*phi; %B2 equation
        dxdt = [dxdt1;dxdt2];
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
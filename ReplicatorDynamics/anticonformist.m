function antiConformist
T = 300;

tau = 5; %delay for social learners
epsilon  = 0.1; %

std_dev = 0; % introduce some noise to the payoffs
payOpt = normrnd(0.8,std_dev,1000); %introducing some noise for the payoff of optimum behavior
paySOpt = normrnd(0.2,std_dev,1000);%introducing some noise for the payoff of sub-optimum behavior

%Arrays to keep track of the results at t
Xarr = zeros(3, T);

%Fitness functions for behavior 1 and 2 
fB1 = @(t)(1-epsilon)*piB1(t) + epsilon*piB2(t); %Fitness of behavior 1
fB2 = @(t)(1-epsilon)*piB2(t) + epsilon*piB1(t); %Fitness of behavior 2

%initial value assignments for B1, B2 and S
B10  = 1/3;
B20  = 1/3;
S10  = 1/3;

%Solving the system
Y0 = [B10; B20; S10];
tspan   = [0:0.01:T];
[tt, y] = ode45(@sls,tspan,Y0);


%generating the plots
figure;
hold on
plot(tt,y(:,1) + y(:,2),'Color', 'k', 'Linewidth', 2)
plot(tt,y(:,3),'Color', 'r', 'Linewidth', 2)
plot(tt,y(:,1),'--','Color', [0.07,0.62,1.00], 'Linewidth', 2)
plot(tt,y(:,2),'--','Color', 'g', 'Linewidth', 2)
xlabel('Time (t)')
ylabel('Ratio')
set(gca,'FontSize',15);
ylim([0,1.1])

yyaxis right
ylabel('\phi(t)')
set(gca,'ycolor','m');
ylim([0,1.1])



phiArr = [];
for i=1:length(tt)
    p1 = piB1(tt(i));
    p2 = piB2(tt(i));
    fs = 0;
    if(p1>p2)
        fs = p1;
    else
        fs = p2;
    end
    f = [fB1(tt(i)) fB2(tt(i)) fs];
    phi = f*y(i,:)'; 
    phiArr(end+1) = phi;
end



plot(tt,phiArr, 'Color', 'm','Linewidth', 2)

legend({'IL','SL','B_1','B_2', '\phi(t)'}, ...
            'Position',[0.22 0.85 0.64 0.08], ...
            'FontSize',13,...
            'NumColumns',5,...
            'color','none');
legend boxoff



    
    function y = fS(t)
        gSB1 = [];
        gSB2 = [];
        gB1 = []; 
        gB2 = [];
        if(tau == 0)
            i= floor(t)+1;
            gSB1(end+1) = Xarr(1,i)^a / (Xarr(1,i)^a + Xarr(2,i)^a);
            gSB2(end+1) = Xarr(2,i)^a / (Xarr(1,i)^a + Xarr(2,i)^a);
        end
            
        for i=1:tau:floor(t)+1
            if(i-tau<=0)
                gSB1(end+1) = 0.001;
                gSB2(end+1) = 0.001;
                gB1(end+1) = Xarr(1,i);
                gB2(end+1) = Xarr(2,i);
            else
                if(gB1(end) < gB2(end))
                    gSB1(end+1) = 1;
                    gSB2(end+1) = 0;
                elseif(gB1(end) > gB2(end))
                    gSB1(end+1) = 0;
                    gSB2(end+1) = 1;
                else
                    gSB1(end+1) = 1;
                    gSB2(end+1) = 0;
                    if(rand<0.5)
                        gSB1(end+1) = 0;
                        gSB2(end+1) = 1;
                    end
                end
                if(Xarr(1,i) <= 0), continue; end
                if(Xarr(2,i) <= 0), continue; end
                gB1(end+1) = Xarr(1,i) + Xarr(3,i)*gSB1(end);
                gB2(end+1) = Xarr(2,i) + Xarr(3,i)*gSB2(end);
            end
        end
                
        
        y = gSB1(end)*piB1(t) + gSB2(end)*piB2(t);
    end

    function dxdt = sls(t,x)
        
             
        
        Xarr(:,floor(t)+1) = x;
        
        Q = [[0.995, 0, 0.005]; [0, 0.995, 0.005]; [0.0025, 0.0025, 0.995]];
        
        f = [fB1(t) fB2(t) fS(t)];
        phi = f*x; 
        
        
        dxdt1 = f*(x.*Q(:,1)) - x(1)*phi; %B1 equation
        dxdt2 = f*(x.*Q(:,2)) - x(2)*phi; %B2 equation
        dxdt3 = f*(x.*Q(:,3)) - x(3)*phi; %S equation
        dxdt = [dxdt1;dxdt2;dxdt3];
    end
    
    function y = piB1(t) %Payoff of behavior 1
        if(t<100 || t>200)
            y = payOpt(floor(t+1));
        else
            y = paySOpt(floor(t+1));
        end
    end

    function y = piB2(t) %Payoff of behavior 2
        if(t<100 || t>200)
            y = paySOpt(floor(t+1));
        else
            y = payOpt(floor(t+1));
        end
    end
end

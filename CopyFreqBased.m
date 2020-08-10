function CopyFreqBased
T = 300;

tau = 1; %delay for social learners
a = -1; %Strength of selection
epsilon  = 0.1; %

payOpt = normrnd(0.2,0,1000); %introducing some noise for the payoff of optimum behavior
paySOpt = normrnd(0.8,0,1000);%introducing some noise for the payoff of sub-optimum behavior


Xarr = zeros(3, T);
Tarr = zeros(1,T);

fB1 = @(t)(1-epsilon)*piB1(t) + epsilon*piB2(t); %Fitness of behavior 1
fB2 = @(t)(1-epsilon)*piB2(t) + epsilon*piB1(t); %Fitness of behavior 2

B10  = 1/3;
B20  = 1/3;
S10  = 1/3;

Y0 = [B10; B20; S10];
tspan   = [0:0.01:T];
[tt, y] = ode45(@sls,tspan,Y0);

clf
subplot(2,1,1)
hold on
plot(tt,y(:,1),'Color', 'b', 'Linewidth', 2)
plot(tt,y(:,2),'Color', 'g', 'Linewidth', 2)
plot(tt,y(:,3),'Color', 'k', 'Linewidth', 2)
legend({'B1','B2','S'})


subplot(2,1,2)
hold on
plot(tt,y(:,1) + y(:,2),'Color', 'b', 'Linewidth', 2)
plot(tt,y(:,3),'Color', 'r', 'Linewidth', 2)
legend({'IL','SL'})

    
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
                gSB1(end+1) = gB1(end)^a / (gB1(end)^a + gB2(end)^a);
                gSB2(end+1) = gB2(end)^a / (gB1(end)^a + gB2(end)^a);
                if(Xarr(1,i) == 0), continue; end
                gB1(end+1) = Xarr(1,i) + Xarr(3,i)*gSB1(end);
                gB2(end+1) = Xarr(2,i) + Xarr(3,i)*gSB2(end);
            end
        end
                
        y = gSB1(end)*piB1(t) + gSB2(end)*piB2(t);
    end

    function dxdt = sls(t,x)
        
        Xarr(:,floor(t)+1) = x;
        Tarr(floor(t)+1) = t;
        
        Q = [[0.999, 0, 0.001]; [0, 0.999, 0.001]; [0.001, 0.001, 0.998]];
        %Q = [[0.98, 0, 0.01]; [0, 0.98, 0.01]; [0.01, 0.01, 0.98]];
        
        
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

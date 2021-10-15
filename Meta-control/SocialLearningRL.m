function results = SocialLearningRL(settings, env)

settings.period = env.period;
settings.mu1 =  env.def(1,:);
settings.std1 = env.def(2,:);
settings.mu2 =  env.def(3,:);
settings.std2 = env.def(4,:);
settings.randReversal = env.randReversal;


%Multi-armed bandit payoff assignments
nArm = zeros(settings.nArm,2);
nArm(:,1) = settings.mu2(1);
nArm(:,2) = settings.std2(1);
nArm(1,:) = [settings.mu1(1) settings.std1(1)];

numOfAgents = settings.numOfAgents;


selectedOpt = zeros(numOfAgents,settings.T);
rewReceived = zeros(numOfAgents,settings.T);
phi = zeros(1,settings.T);

conformityCoef = zeros(1,settings.T);
varCoef = zeros(1,settings.T);


nS = zeros(1,settings.T);
nC = zeros(1,settings.T);
nU = zeros(1,settings.T);
nIL = zeros(1,settings.T);


%agent initialization
agents = cell(settings.numOfAgents,1);
for i=1:settings.numOfAgents
    agents{i}.socialReward = rand(1,3).*0.1 + 1;
    agents{i}.narmReward = rand(1,settings.nArm).*0.1 + 1.4;
    agents{i}.narmRewardHist = zeros(settings.T, settings.nArm);
    agents{i}.rewDist = cell(settings.nArm,1);
    agents{i}.beta = settings.beta;
    agents{i}.epsilon = settings.epsilon;
    agents{i}.reward = 0;
end

rewMeans = zeros(settings.nArm,settings.T);
rewStd = zeros(settings.nArm,settings.T);
freq = zeros(settings.nArm,settings.T);

converged = 0;
environmentChange = 0;
uncertain = 0;
kObs = 0;

%Evolutionary algorithm
for t=1:settings.T
    
    if(~isempty(find(settings.period==t,1)))
        rewInx = find(t<=settings.period,1)+1;
        [mV, mInx] = max(nArm(:,1));
        if(settings.randReversal(rewInx))
            r = randi([1,settings.nArm]);
            while r == mInx, r = randi([1,settings.nArm]); end
        else
            r = mInx;
        end
        nArm(:,1) = settings.mu2(rewInx);
        nArm(:,2) = settings.std2(rewInx);
        nArm(r,:) = [settings.mu1(rewInx) settings.std1(rewInx)];
    end
    
    %Behavior frequencies at t-tau
    freqB = zeros(1,settings.nArm);
    v = zeros(numOfAgents,1);
    if(t-settings.tau > 0)
        v = selectedOpt(:,t-settings.tau);
        h = tabulate(v);
        if(h(1,1) == 0), h(1,:) = []; end
        freqB(h(:,1)) = h(:,2);
        
    end
    
    conformityCoef(t) = max(freqB)/settings.numOfAgents;
    if(t-settings.tau > 0)
        varCoef(t) = sum(h(:,2)>1)/settings.nArm;
        varCoef(t) = var(v(v~=0));
        
        indicesF = find(freqB>0);
        nfreq = freqB(indicesF);
        indicesS = find(selectedOpt(:,t-settings.tau)>0);
        rew = rewReceived(indicesS,t-settings.tau);
    end
    
    
    if(t>1)
        for kk=1:settings.nArm
            rewMeans(kk,t-1) = mean(rewReceived(selectedOpt(:,t-1)==kk,t-1));
            rewStd(kk,t-1) = std(rewReceived(selectedOpt(:,t-1)==kk,t-1));
        end
        freq(:,t-1) = freqB';
        
        
    end
    
    
    for i=1:numOfAgents
        
        [mv, strategySelection] = max(agents{i}.socialReward);
        
        
        if(rand<0.1)
            r=randi([1,3]);
            while r==strategySelection
                r=randi([1,3]);
            end
            strategySelection = r;
        end
        if(t==1)
            strategySelection = 3;
        end
        
        
        if(strategySelection == 1) %success-based
            [mv, ind] = max(rew);
            select = selectedOpt(indicesS(ind),t-settings.tau);
            reward = normrnd(nArm(select,1),nArm(select,2));
            agents{i}.narmReward(select) = agents{i}.narmReward(select) +...
                agents{i}.beta*(reward - agents{i}.narmReward(select));
            rewReceived(i,t) = reward;
            selectedOpt(i,t) = select;
            agents{i}.reward = reward;
            nS(t) = nS(t) + 1;
            
        elseif(strategySelection == 2)%conformist
            [mV, select] = max(freqB);
            reward = normrnd(nArm(select,1),nArm(select,2));
            agents{i}.narmReward(select) = agents{i}.narmReward(select) +...
                agents{i}.beta*(reward - agents{i}.narmReward(select));
            
            rewReceived(i,t) = reward;
            selectedOpt(i,t) = select;
            agents{i}.reward = reward;
            
            nC(t) = nC(t) + 1;
            
        elseif(strategySelection == 3)%individual learning
            [mV, ind] = max(agents{i}.narmReward);
            select = ind;
            %exploration of other options
            if(rand < agents{i}.epsilon)
                select = randi([1,settings.nArm]);
                while select == ind
                    select = randi([1,settings.nArm]);
                end
            end
            
            reward = normrnd(nArm(select,1),nArm(select,2));
            agents{i}.narmReward(select) = agents{i}.narmReward(select) +...
                agents{i}.beta*(reward - agents{i}.narmReward(select));

            
            rewReceived(i,t) = reward;
            selectedOpt(i,t) = select;
            agents{i}.reward = reward;
            
            
            nIL(t) = nIL(t) + 1;
            
        elseif(strategySelection == 4) %Uniform
            select = indicesF(randi([1,length(nfreq)]));
            reward = normrnd(nArm(select,1),nArm(select,2));
            
            agents{i}.narmReward(select) = agents{i}.narmReward(select) +...
                agents{i}.beta*(reward - agents{i}.narmReward(select));

            
            rewReceived(i,t) = reward;
            selectedOpt(i,t) = select;
            agents{i}.reward = reward;
            
            nU(t) = nU(t) + 1;
        end
        
        agents{i}.socialReward(strategySelection) = agents{i}.socialReward(strategySelection) +...
                agents{i}.beta*(agents{i}.reward - agents{i}.socialReward(strategySelection));
        
    end
    
    phi(t) = mean(rewReceived(selectedOpt(:,t)~=0, t));
end



results.nIL = nIL./numOfAgents;
results.nS = nS./numOfAgents;
results.nU = nU./numOfAgents;
results.nC = nC./numOfAgents;
results.phi = phi;
results.behaviorDist = freq;
results.conformityCoef = conformityCoef;
results.varCoef = varCoef;
results.settings = settings;
end
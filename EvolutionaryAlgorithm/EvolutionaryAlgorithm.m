function results = EvolutionaryAlgorithm(settings)
 
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

nSL = zeros(1,settings.T);
nIL = zeros(1,settings.T);
behaviorDist = zeros(settings.nArm,settings.T);

types = cell(numOfAgents,1);

%agent initialization
agents = cell(settings.numOfAgents,1);
for i=1:settings.numOfAgents
    agents{i}.narmReward = rand(1,settings.nArm).*0.05 + 1.1; %initial reward values
    agents{i}.beta = settings.beta; %learning step
    agents{i}.epsilon = settings.epsilon; %exploration parameter
    agents{i}.reward = 0;
    %social or individual learner
    if(rand<0.5)
        agents{i}.type = 'SL';
    else
        agents{i}.type = 'IL';
    end
end


%Evolutionary algorithm
for t=1:settings.T
    
    %Periodic environment change
    %reward reversal point check and change
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
    freqB = zeros(1,2);
    v = zeros(numOfAgents,1);
    if(t-settings.tau > 0)
        v = selectedOpt(:,t-settings.tau);
        h = tabulate(v);
        if(h(1,1) == 0), h(1,:) = []; end
        freqB(h(:,1)) = h(:,2);
        
    end
    
    %conformity and variance statistics
    conformityCoef(t) = max(freqB)/settings.numOfAgents;
    if(t-settings.tau > 0)
        varCoef(t) = sum(h(:,2)>1)/settings.nArm;
        varCoef(t) = var(v(v~=0));
        if(strcmp(settings.strategy,'conformity'))
            indices = find(freqB>0);
            nfreq = freqB(indices);
        elseif(strcmp(settings.strategy,'success-based'))
            indices = find(selectedOpt(:,t-settings.tau)>0);
            rew = rewReceived(indices,t-settings.tau);
        end
    end
    
    
    for i=1:numOfAgents
        types{i} = agents{i}.type;
        if(strcmp(agents{i}.type,'SL')) %Social Learner
            reward = 0;
            select = 0;
            if(t-settings.tau > 0)
                if(strcmp(settings.strategy,'conformity')) %conformist social learning
                    [mv, ind] = max(nfreq);
                    select = indices(ind);
                elseif(strcmp(settings.strategy,'success-based'))%success-based social learning
                    [mv, ind] = max(rew);
                    select = selectedOpt(indices(ind),t-settings.tau);
                end
                reward = normrnd(nArm(select,1),nArm(select,2));
                if(reward < 0), reward = 0; end
                agents{i}.narmReward(select) = agents{i}.narmReward(select) +...
                    agents{i}.beta*(reward - agents{i}.narmReward(select));
            end
                
            rewReceived(i,t) = reward;
            selectedOpt(i,t) = select;
            agents{i}.reward = reward;
            nSL(t) = nSL(t) + 1;
            
        else %Individual Learner
            [mV, mInx] = max(agents{i}.narmReward);
            select = mInx;
            %exploration of other options
            if(rand < agents{i}.epsilon)
                select = randi([1,settings.nArm]);
                while select == mInx
                     select = randi([1,settings.nArm]);
                end
            end
            
            reward = normrnd(nArm(select,1),nArm(select,2));
            if(reward < 0), reward = 0; end
            agents{i}.narmReward(select) = agents{i}.narmReward(select) +...
                    agents{i}.beta*(reward - agents{i}.narmReward(select));
                
            rewReceived(i,t) = reward;
            selectedOpt(i,t) = select;
            behaviorDist(select,t) = behaviorDist(select,t) + 1;
            agents{i}.reward = reward;
            nIL(t) = nIL(t) + 1;
            
        end
        
        
        
        
    end
    
    phi(t) = mean(rewReceived(selectedOpt(:,t)~=0, t));
    
    %Selection of individuals and constructing the next generation
    fitness = rewReceived(:,t);
    nFit = (fitness)./sum(fitness);
    cFit = cumsum(nFit);
    
    tempAgents = agents;
    for i=1:numOfAgents 
        copyInx = find(cFit >= rand, 1);
        tempAgents{i} = agents{copyInx};
        if(rand < settings.mutationProb) % Mutation 
            if(strcmp(tempAgents{i}.type,'SL'))
                tempAgents{i}.type = 'IL';
            else
                tempAgents{i}.type = 'SL';
            end
        end
                
    end
    agents = tempAgents;
    
    
end



results.nIL = nIL./numOfAgents;
results.nSL = nSL./numOfAgents;
results.behaviorDist = behaviorDist./numOfAgents;
results.phi = phi;
results.conformityCoef = conformityCoef;
results.varCoef = varCoef;
results.settings = settings;
end
function results = EvolutionaryAlgorithm(settings)

%Multi-armed bandit payoff assignments
nArm = zeros(settings.nArm,2);
nArm(:,1) = 0.2;
nArm(:,2) = 0.1;
nArm(randi([1,settings.nArm]),1) = 0.8;

numOfAgents = settings.numOfAgents;


selectedOpt = zeros(numOfAgents,settings.T); 
rewReceived = zeros(numOfAgents,settings.T); 
phi = zeros(1,settings.T);


nSL = zeros(1,settings.T);
nIL = zeros(1,settings.T);
behaviorDist = zeros(settings.nArm,settings.T);

types = cell(numOfAgents,1);

%agent initialization
agents = cell(settings.numOfAgents,1);
for i=1:settings.numOfAgents
    agents{i}.narmReward = zeros(1,settings.nArm);
    agents{i}.decay = settings.decay;
    agents{i}.epsilon = settings.epsilon;
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
    if(mod(t,settings.period) == 0) 
        [mV, mInx] = max(nArm(:,1));
        r = randi([1,settings.nArm]);
        while r == mInx, r = randi([1,settings.nArm]); end
        temp = nArm(r,1);
        nArm(mInx,1) = temp;
        nArm(r,1) = mV;
    end
    
    %Behavior frequencies at t-tau
    freqB = zeros(1,2);
    if(t-settings.tau > 0)
        v = selectedOpt(:,t-settings.tau);
        h = tabulate(v);
        if(h(1,1) == 0), h(1,:) = []; end
        freqB(h(:,1)) = h(:,2);
    end
    
    
    for i=1:numOfAgents
        types{i} = agents{i}.type;
        if(strcmp(agents{i}.type,'SL')) %Social Learner
            reward = 0;
            select = 0;
            if(t-settings.tau > 0)
                %Behavior frequencies to selection probabilities
                if(strcmp(settings.strategy,'conformist'))
                    [mV, select] = max(freqB);            
                elseif(strcmp(settings.strategy,'anti-conformist'))
                    [mV, select] = min(freqB);            
                elseif(strcmp(settings.strategy,'unbiased'))
                    select = randi([1,settings.nArm]);
                elseif(strcmp(settings.strategy,'success-based'))
                    [sv, sInx] = sort(rewReceived(:,t-settings.tau),'descend');
                    freqB = zeros(1,2);
                    for k=1:3
                        freqB(selectedOpt(sInx(k),t-settings.tau)) = freqB(selectedOpt(sInx(k),t-settings.tau)) + 1;
                    end
                    [mV, select] = max(freqB);    
                end
                reward = normrnd(nArm(select,1),nArm(select,2));
                if(reward < 0), reward = 0; end
                agents{i}.narmReward(select) = (1-agents{i}.decay)*agents{i}.narmReward(select) + ...
                    agents{i}.decay*reward;
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
            agents{i}.narmReward(select) = (1-agents{i}.decay)*agents{i}.narmReward(select) + ...
                    agents{i}.decay*reward;
                
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
results.settings = settings;
end
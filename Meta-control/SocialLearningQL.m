function results = SocialLearningQL(settings, env)

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


selectedBehavior = zeros(numOfAgents,settings.T);
stateIndices = zeros(1,settings.T);
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
uncertain = 0;
kObs = 0;
environmentChange = 0;

QTable = settings.QTable;
actions = zeros(numOfAgents,settings.T);
actionMeanRewards = zeros(3,settings.T);
nActions = zeros(3,settings.T);


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
        v = selectedBehavior(:,t-settings.tau);
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
        indicesS = find(selectedBehavior(:,t-settings.tau)>0);
        rew = rewReceived(indicesS,t-settings.tau);
    end
    
    
    if(t>1)
        for kk=1:settings.nArm
            rewMeans(kk,t-1) = mean(rewReceived(selectedBehavior(:,t-1)==kk,t-1));
            rewStd(kk,t-1) = std(rewReceived(selectedBehavior(:,t-1)==kk,t-1));
        end
        freq(:,t-1) = freqB';
        
        
         
        [mV, mrInx] = max(rewMeans(:,t-1));
        [mV, mfInx] = max(freq(:,t-1));
        
        k1 = sum(selectedBehavior(:,t-1)==mrInx);
        k2 = sum(selectedBehavior(:,t-1)~=mrInx);
        rewMeanBest = mean(rewReceived(selectedBehavior(:,t-1)==mrInx,t-1));
        rewStdBest = std(rewReceived(selectedBehavior(:,t-1)==mrInx,t-1));
        rewMeanRest = mean(rewReceived(selectedBehavior(:,t-1)~=mrInx,t-1));
        rewStdRest = std(rewReceived(selectedBehavior(:,t-1)~=mrInx,t-1));
        if(rewStdBest==0), rewStdBest = 0.0001; end
        if(rewStdRest==0), rewStdRest = 0.0001; end
        ODPU = NaN;
        if(~isnan(rewMeanBest) && ~isnan(rewStdBest) &&...
                ~isnan(rewMeanRest) && ~isnan(rewStdRest))
            ODPU = uncertaintyFormula(rewMeanBest,rewStdBest,k1,rewMeanRest,rewStdRest,k2);%1 - normcdf((rewMeanBest-rewMeanRest)/ sqrt(rewStdBest^2 + rewStdRest^2),0,1);
        end
        if(ODPU >= 0.1)
            uncertain = 1;
        elseif(isnan(ODPU))
%             uncertain = NaN;
        else
            uncertain = 0;
        end



        if(mfInx == mrInx)
            converged = 1;
            settings.pIL = 0;
        else
            converged = 0; 
            settings.pIL = 1;
        end

        

        if(t>2)
            if(abs(rewMeans(mrInx,t-2)-rewMeans(mrInx,t-1)) > 0.15)
                converged = 0;
                kObs = 0;
                settings.pIL = 1;
                environmentChange = 1;
            else
                environmentChange = 0;
            end
        end
        
        
    end
    
    currState = strcat(num2str(converged),num2str(uncertain), num2str(environmentChange));
    stateInx = find(strcmp(settings.states, currState),1);
    stateIndices(t) = stateInx;
    [mV, currActionInx] = max(QTable(stateInx,:));
    if(t==1), currActionInx = 3; end
    
    if(t>2 && settings.epsilonQ > 0)

        at = actions(1,t-1);
        st = stateIndices(t-1);
        rt  =mean(rewReceived(:,t-1));
        QTable(st,at) = QTable(st,at) + ...
                settings.alphaQ*(rt + settings.gammaQ*max(QTable(stateIndices(t),:)) - QTable(st,at));

    end
    
    choice = currActionInx;
    if(t>1 && rand<settings.epsilonQ)
        choice = randi([1,3]);
        while choice == currActionInx
            choice = randi([1,3]);
        end
    end

    
    for i=1:numOfAgents
        
        
        actions(i,t) = choice;
        nActions(choice,t) = nActions(choice,t) + 1; 
        
        if(choice == 1) %success-based
            [mv, ind] = max(rew);
            select = selectedBehavior(indicesS(ind),t-settings.tau);
            reward = normrnd(nArm(select,1),nArm(select,2));
            agents{i}.narmReward(select) = agents{i}.narmReward(select) +...
                agents{i}.beta*(reward - agents{i}.narmReward(select));
            rewReceived(i,t) = reward;
            selectedBehavior(i,t) = select;
            agents{i}.reward = reward;
            nS(t) = nS(t) + 1;
            
        elseif(choice == 2)%conformist
            [mV, select] = max(freqB);
            reward = normrnd(nArm(select,1),nArm(select,2));
            agents{i}.narmReward(select) = agents{i}.narmReward(select) +...
                agents{i}.beta*(reward - agents{i}.narmReward(select));
            
            rewReceived(i,t) = reward;
            selectedBehavior(i,t) = select;
            agents{i}.reward = reward;
            
            nC(t) = nC(t) + 1;
            
        elseif(choice == 3)%individual learning
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
            selectedBehavior(i,t) = select;
            agents{i}.reward = reward;
            
            
            nIL(t) = nIL(t) + 1;
            
        end
        
        
        phi(t) = mean(rewReceived(selectedBehavior(:,t)~=0, t));
        actionMeanRewards(choice,t) = actionMeanRewards(choice,t) + reward; 
    end
    actionMeanRewards(:,t) = actionMeanRewards(:,t)./nActions(:,t);
    
    settings.QTable = QTable;
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
function runEA()
%simulating the evolution of individuals that use individual, conformist or
%success-based social learning strategies



% parpool('local',28);
settings.numOfAgents = 100;
settings.beta = 1/5; %step in individual learning model
settings.epsilon = 0.1;
settings.T = 599; %total time step of the simulation
settings.visualize = 0;
settings.mutationProb = 5*1e-3;
settings.tau = 1;
settings.period = [100 300:300:10000]; %the period of the change of the environment
settings.mu1 =  [1  1  1]; %mean of the reward distributions for the first arm in each period
settings.std1 = [0.05 0.05  0.05];%std of the reward distributions for the first arm in each period
settings.mu2 =  [0.5 0.5  0.7];%mean of the reward distributions for the second arm in each period
settings.std2 = [0.05 0.05  0.5];%std of the reward distributions for the second arm in each period
settings.randReversal = [1 1 1]; %whether to apply reward reversal that is swithcing the means and stds of the arms for each period
nRun = 4*28; %the number of runs


settings.nArm = 2; %the number of arms



%type of strategy: individual learning
settings.strategy = 'individual';
nIL = zeros(nRun,settings.T);
nSL = zeros(nRun,settings.T);
phi = zeros(nRun,settings.T);
conformityCoef = zeros(nRun,settings.T);
varCoef = zeros(nRun,settings.T);

parfor i=1:nRun
    res = onlyIndividualLearning(settings);
    nIL(i,:) = res.nIL;
    nSL(i,:) = res.nSL;
    phi(i,:) = res.phi;
    conformityCoef(i,:) = res.conformityCoef;
    varCoef(i,:) = res.varCoef;
end
results{1}.settings = settings;
results{1}.nIL = nIL;
results{1}.nSL = nSL;
results{1}.phi = phi;
results{1}.conformityCoef = conformityCoef;
results{1}.varCoef = varCoef;


%type of strategy: conformist social learning
counter = 2;
settings.strategy = 'conformity';
runAlgorithm();


%type of strategy: success-based social learning
counter = 3;
settings.strategy = 'success-based';
runAlgorithm();


save results results



    function runAlgorithm()
        
        nIL = zeros(nRun,settings.T);
        nSL = zeros(nRun,settings.T);
        phi = zeros(nRun,settings.T);
        behaviorDist = zeros(settings.nArm,settings.T);
        conformityCoef = zeros(nRun,settings.T);
        varCoef = zeros(nRun,settings.T);
        
        parfor i=1:nRun
            res = EvolutionaryAlgorithm(settings);
            nIL(i,:) = res.nIL;
            nSL(i,:) = res.nSL;
            phi(i,:) = res.phi;
            conformityCoef(i,:) = res.conformityCoef;
            varCoef(i,:) = res.varCoef;
            behaviorDist = behaviorDist + res.behaviorDist;
        end
        results{counter}.nIL = nIL;
        results{counter}.nSL = nSL;
        results{counter}.phi = phi;
        results{counter}.conformityCoef = conformityCoef;
        results{counter}.varCoef = varCoef;
        results{counter}.settings = settings;
        results{counter}.aveBehaviorDist = behaviorDist./nRun;
        
        
    end


end

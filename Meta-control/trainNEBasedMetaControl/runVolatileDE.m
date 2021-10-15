function bestResutls = runVolatileDE()
rng(1);


env = environmentSettings(5);
settings.period = env.period;
settings.mu1 =  env.def(1,:);
settings.std1 = env.def(2,:);
settings.mu2 =  env.def(3,:);
settings.std2 = env.def(4,:);
settings.randReversal = env.randReversal;
settings.T = env.T;


settings.numOfAgents = 100;
settings.beta = 1/5;
settings.epsilon = 0.1;
settings.visualize = 0;
settings.mutationProb = 5*1e-3;
settings.tau = 1;
nEpisodes = 112;

settings.pIL = 1;

settings.nArm = 2;

settings.F = 0.5;
settings.CR = 0.1;


settings.input = 6;
settings.hidden = 12;
settings.output = 3;
gLenght = settings.hidden*(settings.input+1) + settings.output*(settings.hidden+1);


bestFitness = 0;
np = 50;
pop = unifrnd(-1,1,np,gLenght);
bestGenotype = [];
bestResutls = {};
fitness = zeros(np,1);

fitnessHistory = [];

for p=1:np
    settings.genotype = pop(p,:);
    results = evaluate();
    fitness(p) = median(sum(results.phi,2));
    
    if(fitness(p) > bestFitness)
        bestGenotype = settings.genotype;
        bestFitness = fitness(p);
        bestResutls = results;
    end
end
stagnate = 1;
iter = 1;
fitnessHistory(iter) = bestFitness;


while iter < 100000
    
    
    for j = 1:np
        
        targetVector = pop(j,:);
        targetFitness = fitness(j);
        
        r = randperm(np);
        r(r== j) = [];
        
        
        mutantVector = pop(r(1),:) + settings.F.*(pop(r(2),:) - pop(r(3),:));
        select = rand(size(mutantVector)) < settings.CR;
        
        candidateVector = targetVector;
        candidateVector(select) = mutantVector(select);
        
        settings.genotype = candidateVector;
        results = evaluate();
        candateFitness = median(sum(results.phi,2));
        if(candateFitness >= targetFitness)
            pop(j,:) = candidateVector;
            fitness(j) = candateFitness;
        end
            
        if(candateFitness > bestFitness)
            bestGenotype = settings.genotype;
            bestFitness = candateFitness;
            bestResutls = results;
            stagnate = 0;
        end
        
        
        
    end
    
        
    
    iter = iter + 1;stagnate = stagnate + 1;
    
    fitnessHistory(iter) = bestFitness;
    
    save resutlsWorking
    
    
    if(stagnate >= 50), break; end
    
end
bestResutls.fitnessHistory = fitnessHistory;
bestResutls.pop = pop;
bestResutls.fitness = fitness;
bestResutls.bestFitness = bestFitness;
bestResutls.bestGenotype = bestGenotype;


    function results = evaluate()
        nS = zeros(nEpisodes,settings.T);
        nC = zeros(nEpisodes,settings.T);
        nU = zeros(nEpisodes,settings.T);
        nIL = zeros(nEpisodes,settings.T);
        phi = zeros(nEpisodes,settings.T);
        conformityCoef = zeros(nEpisodes,settings.T);
        varCoef = zeros(nEpisodes,settings.T);
        parfor i=1:nEpisodes
            res = SocialLearningNE(settings);
            nS(i,:) = res.nS;
            nC(i,:) = res.nC;
            nU(i,:) = res.nU;
            nIL(i,:) = res.nIL;
            phi(i,:) = res.phi;
            conformityCoef(i,:) = res.conformityCoef;
            varCoef(i,:) = res.varCoef;
        end
        
        results.settings = settings;
        results.nS = nS;
        results.nC = nC;
        results.nU = nU;
        results.nIL = nIL;
        results.phi = phi;
        results.conformityCoef = conformityCoef;
        results.varCoef = varCoef;
    end

end
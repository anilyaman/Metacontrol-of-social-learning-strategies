function bestResutls = runVolatile()
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
elites = 5;

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


while iter < 10000
    
    
    
    
    [sf, si] = sort(fitness,'descend');
    
    nPop = zeros(size(pop));
    nFit = zeros(size(fitness));
    nPop(1:elites,:) = pop(si(1:elites),:);
    nFit(1:elites) = fitness(si(1:elites));
    rest = elites + 1;
    nf = fitness./sum(fitness);
    cf = cumsum(nf);
    while rest <= np
        
        s1 = find(rand<cf,1);
        s2 = find(rand<cf,1);
        while s1 == s2
            s2 = find(rand<cf,1);
        end
        p1 = pop(s1,:);
        off = p1;
        if(rand<0.8)
            p2 = pop(s2,:);
            cp = randi([2,length(p1)]);
            off(cp:end) = p2(cp:end);
        end
        off = off + normrnd(0,0.1,size(off));
        nPop(rest,:)= off;
        settings.genotype = off;
        results = evaluate();
        nFit(rest) = median(sum(results.phi,2));
        if(nFit(rest) > bestFitness)
            bestGenotype = settings.genotype;
            bestFitness = nFit(rest);
            bestResutls = results;
            stagnate = 0;
        end
        rest = rest+1;
    end
    pop = nPop;
    fitness = nFit;
    
    
    
    iter = iter + 1;stagnate = stagnate + 1;
    
    fitnessHistory(iter) = bestFitness;
    
    save resutlsWorkingGA
    
    
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
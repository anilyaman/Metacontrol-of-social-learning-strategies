function runSLNE(settings,saveFile, envID)


env = environmentSettings(envID, settings.nArm);


settings.input = 6;
settings.hidden = 12;
settings.output = 3;
gLenght = settings.hidden*(settings.input+1) + settings.output*(settings.hidden+1);

load GenotypeNE
settings.states = {'000','010','100','110','001','011','101','111'};
 
settings.genotype = genotype;
nS = zeros(settings.nRun,settings.T);
nC = zeros(settings.nRun,settings.T);
nU = zeros(settings.nRun,settings.T);
nIL = zeros(settings.nRun,settings.T);
phi = zeros(settings.nRun,settings.T);
conformityCoef = zeros(settings.nRun,settings.T);
varCoef = zeros(settings.nRun,settings.T);
% 
parfor i=1:settings.nRun
    res = SocialLearningNE(settings, env{i});
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


save(saveFile, 'results');



end
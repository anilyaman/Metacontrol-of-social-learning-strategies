function runSLCRL(settings,saveFile, envID)


env = environmentSettings(envID, settings.nArm);

settings.pIL = 0;
settings.epsilonRL = 0.1;
settings.epsilonDecay = 0.9;

nS = zeros(settings.nRun,settings.T);
nC = zeros(settings.nRun,settings.T);
nU = zeros(settings.nRun,settings.T);
nIL = zeros(settings.nRun,settings.T);
phi = zeros(settings.nRun,settings.T);
conformityCoef = zeros(settings.nRun,settings.T);
varCoef = zeros(settings.nRun,settings.T);
% 
parfor i=1:settings.nRun
    res = SocialLearningCRL(settings, env{i});
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
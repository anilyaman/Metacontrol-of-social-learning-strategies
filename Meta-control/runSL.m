%parpool('local',28);
rng(1);
settings.numOfAgents = 100;
settings.beta = 1/5;
settings.epsilon = 0.1;
settings.visualize = 0;
settings.mutationProb = 5*1e-3;
settings.tau = 1; 
settings.nRun = 100;
settings.nArm = 2; 
settings.T = 119;

%%%%  SL-EC-Conf-Unc %%%%%%%%%%
runSLUnc(settings, strcat('env1Sta',num2str(settings.nArm),'ASLUnc.mat'), 1)
runSLUnc(settings, strcat('env2Sta',num2str(settings.nArm),'ASLUnc.mat'), 2)
runSLUnc(settings, strcat('env1Vol',num2str(settings.nArm),'ASLUnc.mat'), 3)
runSLUnc(settings, strcat('env2Vol',num2str(settings.nArm),'ASLUnc.mat'), 4)
% runSLUnc(settings, strcat('envRand',num2str(settings.nArm),'ASLUnc.mat'), 5)

%%%%  SL-GA %%%%%%%%%%
runSLGA(settings, strcat('env1Sta',num2str(settings.nArm),'ASLGA.mat'), 1)
runSLGA(settings, strcat('env2Sta',num2str(settings.nArm),'ASLGA.mat'), 2)
runSLGA(settings, strcat('env1Vol',num2str(settings.nArm),'ASLGA.mat'), 3)
runSLGA(settings, strcat('env2Vol',num2str(settings.nArm),'ASLGA.mat'), 4)
% runSLGA(settings, strcat('envRand',num2str(settings.nArm),'ASLGA.mat'), 5)


%%%%  SL-NE %%%%%%%%%%
runSLNE(settings, strcat('env1Sta',num2str(settings.nArm),'ASLNE.mat'), 1)
runSLNE(settings, strcat('env2Sta',num2str(settings.nArm),'ASLNE.mat'), 2)
runSLNE(settings, strcat('env1Vol',num2str(settings.nArm),'ASLNE.mat'), 3)
runSLNE(settings, strcat('env2Vol',num2str(settings.nArm),'ASLNE.mat'), 4)
% runSLNE(settings, strcat('envRand',num2str(settings.nArm),'ASLNE.mat'), 5)



%%%%%  SL-EC-Conf %%%%%%%%%%
runSLECConf(settings, strcat('env1Sta',num2str(settings.nArm),'ASLECConf.mat'), 1)
runSLECConf(settings, strcat('env2Sta',num2str(settings.nArm),'ASLECConf.mat'), 2)
runSLECConf(settings, strcat('env1Vol',num2str(settings.nArm),'ASLECConf.mat'), 3)
runSLECConf(settings, strcat('env2Vol',num2str(settings.nArm),'ASLECConf.mat'), 4)
% runSLECConf(settings, strcat('envRand',num2str(settings.nArm),'ASLECConf.mat'), 5)



%%%%  SL-EC-Succ %%%%%%%%%%
runSLECSucc(settings, strcat('env1Sta',num2str(settings.nArm),'ASLECSucc.mat'), 1)
runSLECSucc(settings, strcat('env2Sta',num2str(settings.nArm),'ASLECSucc.mat'), 2)
runSLECSucc(settings, strcat('env1Vol',num2str(settings.nArm),'ASLECSucc.mat'), 3)
runSLECSucc(settings, strcat('env2Vol',num2str(settings.nArm),'ASLECSucc.mat'), 4)
% runSLECSucc(settings, strcat('envRand',num2str(settings.nArm),'ASLECSucc.mat'), 5)



%%%%%% SLQL-UNC %%%%%%%%%
load QTable
settings.QTable = QTable;
runSLUncQL(settings, strcat('env1Sta',num2str(settings.nArm),'ASLUncQL.mat'), 1)
runSLUncQL(settings, strcat('env2Sta',num2str(settings.nArm),'ASLUncQL.mat'), 2)
runSLUncQL(settings, strcat('env1Vol',num2str(settings.nArm),'ASLUncQL.mat'), 3)
runSLUncQL(settings, strcat('env2Vol',num2str(settings.nArm),'ASLUncQL.mat'), 4)
% runSLUncQL(settings, strcat('envRand',num2str(settings.nArm),'ASLUncQL.mat'), 5)



%%%%%  SL-CRL %%%%%%%%%%
runSLCRL(settings, strcat('env1Sta',num2str(settings.nArm),'ASLCRL.mat'), 1)
runSLCRL(settings, strcat('env2Sta',num2str(settings.nArm),'ASLCRL.mat'), 2)
runSLCRL(settings, strcat('env1Vol',num2str(settings.nArm),'ASLCRL.mat'), 3)
runSLCRL(settings, strcat('env2Vol',num2str(settings.nArm),'ASLCRL.mat'), 4)
% runSLCRL(settings, strcat('envRand',num2str(settings.nArm),'ASLCRL.mat'), 5)



%%%%%  SL-UCB %%%%%%%%%%
runSLUCB(settings, strcat('env1Sta',num2str(settings.nArm),'ASLUCB.mat'), 1)
runSLUCB(settings, strcat('env2Sta',num2str(settings.nArm),'ASLUCB.mat'), 2)
runSLUCB(settings, strcat('env1Vol',num2str(settings.nArm),'ASLUCB.mat'), 3)
runSLUCB(settings, strcat('env2Vol',num2str(settings.nArm),'ASLUCB.mat'), 4)
% runSLUCB(settings, strcat('envRand',num2str(settings.nArm),'ASLUCB.mat'), 5)



%%%%%% SL-RL %%%%%%%%%
runSLRL(settings, strcat('env1Sta',num2str(settings.nArm),'ASLRL.mat'), 1)
runSLRL(settings, strcat('env2Sta',num2str(settings.nArm),'ASLRL.mat'), 2)
runSLRL(settings, strcat('env1Vol',num2str(settings.nArm),'ASLRL.mat'), 3)
runSLRL(settings, strcat('env2Vol',num2str(settings.nArm),'ASLRL.mat'), 4)
% runSLRL(settings, strcat('envRand',num2str(settings.nArm),'ASLRL.mat'), 5)


%%%%%% IL-Only %%%%%%%%%
%1 success, 2 conformist, 3 individual
settings.prob = [0 0 1];
settings.cprob = cumsum(settings.prob./sum(settings.prob));
runSLProp(settings, strcat('env1Sta',num2str(settings.nArm),'AIL.mat'), 1)
runSLProp(settings, strcat('env2Sta',num2str(settings.nArm),'AIL.mat'), 2)
runSLProp(settings, strcat('env1Vol',num2str(settings.nArm),'AIL.mat'), 3)
runSLProp(settings, strcat('env2Vol',num2str(settings.nArm),'AIL.mat'), 4)
% runSLProp(settings, strcat('envRand',num2str(settings.nArm),'AIL.mat'), 5)

%%%%%% SL-PROP %%%%%%%%%
%1 success, 2 conformist, 3 individual
settings.prob = [0.45 0.45 0.05];
settings.cprob = cumsum(settings.prob./sum(settings.prob));
runSLProp(settings, strcat('env1Sta',num2str(settings.nArm),'ASLProp.mat'), 1)
runSLProp(settings, strcat('env2Sta',num2str(settings.nArm),'ASLProp.mat'), 2)
runSLProp(settings, strcat('env1Vol',num2str(settings.nArm),'ASLProp.mat'), 3)
runSLProp(settings, strcat('env2Vol',num2str(settings.nArm),'ASLProp.mat'), 4)
% runSLProp(settings, strcat('envRand',num2str(settings.nArm),'ASLProp.mat'), 5)

%%%%%% SL-Conf %%%%%%%%%
%1 success, 2 conformist, 3 individual
settings.prob = [0 0.95 0.05];
settings.cprob = cumsum(settings.prob./sum(settings.prob));
runSLProp(settings, strcat('env1Sta',num2str(settings.nArm),'ASLConf.mat'), 1)
runSLProp(settings, strcat('env2Sta',num2str(settings.nArm),'ASLConf.mat'), 2)
runSLProp(settings, strcat('env1Vol',num2str(settings.nArm),'ASLConf.mat'), 3)
runSLProp(settings, strcat('env2Vol',num2str(settings.nArm),'ASLConf.mat'), 4)
% runSLProp(settings, strcat('envRand',num2str(settings.nArm),'ASLConf.mat'), 5)

%%%%%% SL-Succ %%%%%%%%%
%1 success, 2 conformist, 3 individual
settings.prob = [0.95 0 0.05];
settings.cprob = cumsum(settings.prob./sum(settings.prob));
runSLProp(settings, strcat('env1Sta',num2str(settings.nArm),'ASLSucc.mat'), 1)
runSLProp(settings, strcat('env2Sta',num2str(settings.nArm),'ASLSucc.mat'), 2)
runSLProp(settings, strcat('env1Vol',num2str(settings.nArm),'ASLSucc.mat'), 3)
runSLProp(settings, strcat('env2Vol',num2str(settings.nArm),'ASLSucc.mat'), 4)
% runSLProp(settings, strcat('envRand',num2str(settings.nArm),'ASLSucc.mat'), 5)



%%%%%% SL-Rand %%%%%%%%%
%1 success, 2 conformist, 3 individual
settings.prob = [0.33 0.33 0.34];
settings.cprob = cumsum(settings.prob./sum(settings.prob));
runSLProp(settings, strcat('env1Sta',num2str(settings.nArm),'ASLRand.mat'), 1)
runSLProp(settings, strcat('env2Sta',num2str(settings.nArm),'ASLRand.mat'), 2)
runSLProp(settings, strcat('env1Vol',num2str(settings.nArm),'ASLRand.mat'), 3)
runSLProp(settings, strcat('env2Vol',num2str(settings.nArm),'ASLRand.mat'), 4)
% runSLProp(settings, strcat('envRand',num2str(settings.nArm),'ASLRand.mat'), 5)


delete(gcp)
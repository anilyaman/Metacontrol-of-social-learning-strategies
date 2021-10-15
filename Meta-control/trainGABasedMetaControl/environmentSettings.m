function env = environmentSettings(envID)
%(1) envSta1 (2) envSta2 (3) envVol1 (4) envVol2 (5) train

env.d1 = [1 0.1;
    1 0.1;
    1 0.1;
    1 0.5;
    1 0.5;
    1 0.1;
    1, 0.1;
    1, 0.2;
    1, 0.3;
    1, 0.4;
    1, 0.5;
    1, 0.1
    ];
d1 = env.d1;

env.d2 = [0.5 0.5;
    0.7 0.25;
    0.8 0.15;
    0.5 0.5;
    0.5 0.1;
    0.5 0.1;
    0.8 0.4;
    0.6 0.4;
    0.7 0.4;
    0.5 0.4;
    0.7 0.1;
    0.8 0.1    
    ];
d2 = env.d2;


if(envID == 1) %StableEnv1
    env.T = 119;
    env.period = [40:40:120]; %the eriod of the change of the environment
    env.def =  [1 1 1;
        d1(2,2) d1(6,2) d1(1,2);
        d2(2,1) d2(6,1) d2(1,1);
        d2(2,2) d2(6,2) d2(1,2)];
    env.randReversal = [ 1  1    1];
elseif(envID==2) %StableEnv2
    env.T = 119;
    env.period = [40:40:120]; %the eriod of the change of the environment
    env.def = [1 1 1;
        d1(5,2) d1(4,2) d1(5,2);
        d2(5,1) d2(4,1) d2(5,1);
        d2(5,2) d2(4,2) d2(5,2)];
    env.randReversal = [ 1  1    1];
elseif(envID == 3) %VolatileEnv1
    env.T = 119;
    env.period = [20:20:120]; %the eriod of the change of the environment
    env.def = [1 1 1 1 1 1;
        d1(1,2) d1(6,2) d1(1,2) d1(5,2) d1(2,2) d1(6,2);
        d2(1,1) d2(6,1) d2(1,1) d2(5,1) d2(2,1) d2(6,1);
        d2(1,2) d2(6,2) d2(1,2) d2(5,2) d2(2,2) d2(6,2)];
    env.randReversal = [ 1 1 1 1 1 1];
elseif(envID == 4) %VolatileEnv2
    env.T = 119;
    env.period = [20:20:120]; %the eriod of the change of the environment
    env.def = [1 1 1 1 1 1;
        d1(5,2) d1(3,2) d1(6,2) d1(4,2) d1(5,2) d1(4,2);
        d2(5,1) d2(3,1) d2(6,1) d2(4,1) d2(5,1) d2(4,1);
        d2(5,2) d2(3,2) d2(6,2) d2(4,2) d2(5,2) d2(4,2)];
    env.randReversal = [ 1 1 1 1 1 1];
elseif(envID == 5) %Training environment
    env.T = 219;
    env.period = [20 40 60 100 120 160 180 200 220]; %the eriod of the change of the environment
    env.def = [1 1 1 1 1 1 1 1 1;
        d1(10,2) d1(7,2) d1(12,2) d1(9,2) d1(11,2) d1(8,2) d1(7,2) d1(10,2) d1(9,2);
        d2(10,1) d2(7,1) d2(12,1) d2(9,1) d2(11,1) d2(8,1) d2(7,1) d2(10,1) d2(9,1);
        d2(10,2) d2(7,2) d2(12,2) d2(9,2) d2(11,2) d2(8,2) d2(7,2) d2(10,2) d2(9,2)];
    env.randReversal = [ 1 1 1 1 1 1 1 1 1];
end


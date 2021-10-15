function env = environmentSettings(envID, nArm)
%(1) envStaHighUnc (2) envStaLowUnc (3) envVolHighUnc (4) envVolLowUnc

d1 = [1 0.1;
    1 0.1;
    1 0.1;
    1 0.5;
    1 0.5;
    %     1 0.1;
    %     1 0.1;
    1 0.1];

d2 = [0.5 0.5;
    0.7 0.25;
    0.8 0.15;
    0.5 0.5;
    0.5 0.1;
    0.5 0.1];


if(envID == 1) %StableEnv1
    for i=1:112
        env{i}.period = [40:40:120].*log2(nArm); %the eriod of the change of the environment
        env{i}.def =  [1 1 1;
            d1(2,2) d1(6,2) d1(1,2);
            d2(2,1) d2(6,1) d2(1,1);
            d2(2,2) d2(6,2) d2(1,2)];
        env{i}.randReversal = [ 1  1    1];
    end
elseif(envID==2) %StableEnv2
    for i=1:112
        env{i}.period = [40:40:120].*log2(nArm); %the eriod of the change of the environment
        env{i}.def = [1 1 1;
            d1(5,2) d1(4,2) d1(5,2);
            d2(5,1) d2(4,1) d2(5,1);
            d2(5,2) d2(4,2) d2(5,2)];
        env{i}.randReversal = [ 1  1  1];
    end
elseif(envID == 3) %VolatileEnv1
    for i=1:112
        env{i}.period = [20:20:120].*log2(nArm); %the eriod of the change of the environment
        env{i}.def = [1 1 1 1 1 1;
            d1(1,2) d1(6,2) d1(1,2) d1(5,2) d1(2,2) d1(6,2);
            d2(1,1) d2(6,1) d2(1,1) d2(5,1) d2(2,1) d2(6,1);
            d2(1,2) d2(6,2) d2(1,2) d2(5,2) d2(2,2) d2(6,2)];
        env{i}.randReversal = [ 1 1 1 1 1 1];
    end
elseif(envID == 4) %VolatileEnv2
    for i=1:112
        env{i}.period = [20:20:120].*log2(nArm); %the eriod of the change of the environment
        env{i}.def = [1 1 1 1 1 1;
            d1(5,2) d1(3,2) d1(6,2) d1(4,2) d1(5,2) d1(4,2);
            d2(5,1) d2(3,1) d2(6,1) d2(4,1) d2(5,1) d2(4,1);
            d2(5,2) d2(3,2) d2(6,2) d2(4,2) d2(5,2) d2(4,2)];
        env{i}.randReversal = [ 1 1 1 1 1 1];
    end
    
elseif(envID == 5)
    load envVolRand
    
    return;
    
    nEnvChange = randi([10,30],112,1);
    inx = 1:120;
    intervals = false(112,120);
    intervals(:,end) = 1;
    for i=1:112
        for j=1:nEnvChange(i)
            inx = randi([3,117]);
            while intervals(i,inx)
                inx = randi([3,117]);
            end
            intervals(i,inx) = true;
        end
        env{i}.period = find(intervals(i,:));
    end
    
    for i=1:112
        env{i}.def = [];
        first = randi([1,6]);
        second = randi([1,6]);
        env{i}.def = [d1(first,1);d1(first,2);d2(first,1);d2(first,2)];
        for j=2:sum(intervals(i,:))
            r = randi([1,6]);
            while r==first(end)
                r = randi([1,6]);
            end
            first(end+1) = r;
            r = randi([1,6]);
            while r==second(end)
                r = randi([1,6]);
            end
            second(end+1) = r;
            
            env{i}.def = [env{i}.def [d1(first(end),1);d1(first(end),2);...
                d2(first(end),1);d2(first(end),2)]];
        end
        env{i}.randReversal = ones(1,sum(intervals(i,:)));
        
    end
%     save envVolRand
end


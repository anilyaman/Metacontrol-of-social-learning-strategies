%k1 = 1;
%k2 = 99;
%for i=1:size(resList,1)
%	resList(i,8) = uncertainty(resList(i,1), resList(i,2),k1, resList(i,3),resList(i,4), k2);
%end
% k=[];
% for k1=1:99
% k(end+1,:) = uncertainty(1, 0.5, k1, 0.90, 0.05, 100-k1);
% end


% for i=1:size(resList,1)
% k=[];
% for k1=1:99
% k(end+1,:) = uncertainty(resList(i,1), resList(i,2),k1, resList(i,3),resList(i,4), 100-k2);
% end
% resList(i,8) = sum(k)/100;
% end

function prob = uncertainty(m1,s1,k1,m2,s2,k2)

% k1 = 10;
% k2 = 100;

% m1 = 1;
% s1 = 0.05;
% m2 = 0.95;
% s2 = 0.05;


nTrial = 50000;
trial = zeros(nTrial,1);
for i=1:nTrial
    x1 = normrnd(m1,s1,k1,1);
    x2 = normrnd(m2,s2,k2,1);
    x = [x1 ones(k1,1); x2 ones(k2,1).*2];
    [a,b] = max(x(:,1));
    trial(i) = x(b,2);
end
prob = sum(trial==2)/nTrial;



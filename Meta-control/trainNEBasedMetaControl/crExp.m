f = [];
for k=1:10000
s = rand(1,123);
g = zeros(size(s));
r = randi([1,122]);
i=r+1;
cr = 0.96;
while i~=r
    g(i) = 1;
    i=i+1;
    if(i>=123), i=1; end
    if(s(i)>cr), break; end
end
f(k) = sum(g);
end

t =tabulate(f);
% plot(cumsum(t(:,3)))
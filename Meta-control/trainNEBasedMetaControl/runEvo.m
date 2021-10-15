function runEvo()
parpool('local',28);
results= {};
for i=1:10
    results{i} = runVolatile();
    save resultsNEGA results
end
delete(gcp);
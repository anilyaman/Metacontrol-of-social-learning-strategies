function network = computeNetwork(network, input)

network.Ah = tansig(network.Whi*input);
%network.Ah(network.Ah<0) = 0;
network.Ao = network.Woh*[network.Ah; 1];
[mv, mx] = max(network.Ao);
network.out = mx;
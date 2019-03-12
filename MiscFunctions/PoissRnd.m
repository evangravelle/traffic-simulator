function S = PoissRnd(lambda, n)
% Generate a random sample S of size n from the (discrete)
% Poisson distribution with parameter lambda.
% Fixed error:
%    CHANGED k = 1; produ = 1; produ = produ*rand
%    TO      k = 0; produ = rand;
% Derek O'Connor, 24 July 2012.  derekroconnor@eircom.net

S = zeros(n,1);
for i = 1:n
    k = 0;
    produ = rand;
    while produ >= exp(-lambda)
        produ = produ*rand;
        k = k+1;
    end
    S(i) = k;
end

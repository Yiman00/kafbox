% Kernel Normalized Least-Mean-Square algorithm with Coherence Criterion
% Author: Steven Van Vaerenbergh, 2013
% Reference: http://dx.doi.org/10.1109/TSP.2008.2009895
% Comment: memories are initialized empty in this implementation
%
% This file is part of the Kernel Adaptive Filtering Toolbox for Matlab.
% http://sourceforge.net/projects/kafbox/

classdef knlmscc
    
    properties (GetAccess = 'public', SetAccess = 'private')
        mu0 = 1; % coherence criterion threshold
        eta = 0.1; % step size
        eps = 1E-4; % regularization
        kerneltype = 'gauss'; % kernel type
        kernelpar = 1; % kernel parameter
    end
    
    properties (GetAccess = 'public', SetAccess = 'private')
        dict = []; % dictionary
        alpha = []; % expansion coefficients
        grow = false; % flag
    end
    
    methods
        
        function kaf = knlmscc(parameters) % constructor
            if (nargin > 0)
                kaf.mu0 = parameters.mu0;
                kaf.eta = parameters.eta;
                kaf.eps = parameters.eps;
                kaf.kerneltype = parameters.kerneltype;
                kaf.kernelpar = parameters.kernelpar;
            end
        end
        
        function y_est = evaluate(kaf,x) % evaluate the algorithm
            if size(kaf.dict,1)>0
                k = kernel(kaf.dict,x,kaf.kerneltype,kaf.kernelpar);
                y_est = k'*kaf.alpha;
            else
                y_est = 0;
            end
        end
        
        function kaf = train(kaf,x,y) % train the algorithm
            if size(kaf.dict,2)==0 % initialize
                kaf.dict = x;
                kaf.alpha = 0;
                kaf.grow = true;
            else
                k = kernel(x,kaf.dict,kaf.kerneltype,kaf.kernelpar);
                kaf.grow = false;
                if (max(k) <= kaf.mu0), % coherence criterion
                    kaf.grow = true;
                    kaf.dict = [kaf.dict; x]; % order increase
                    kaf.alpha = [kaf.alpha; 0]; % order increase
                end
            end
            
            h = kernel(x,kaf.dict,kaf.kerneltype,kaf.kernelpar);
            kaf.alpha = kaf.alpha + ...
                kaf.eta / (kaf.eps + h*h') * (y - h*kaf.alpha) * h';
        end
        
    end
end
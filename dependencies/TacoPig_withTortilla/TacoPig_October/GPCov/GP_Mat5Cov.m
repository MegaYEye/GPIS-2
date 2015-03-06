classdef GP_Mat5Cov < GP_CovFunc
   
    % Most covariance functions will be static
    methods(Static) 
        
        function n_theta = npar(D)
            n_theta = D+1; % each dimension + signal variance
        end
        
        function [K z] = eval(X1, X2, par)
            [D,N1] = size(X1); %number of points in X1
            N2 = size(X2,2); %number of points in X2
            if D~=size(X2,1)
                error('Dimensionality of X1 and X2 must be the same');
            end
            if (length(par)~=D+1)
                error('Wrong number of hyperparameters for SqExp');
            end
            %Compute weighted squared distances:
            w = par(1:D)'.^(-2);
            XX1 = sum(w(:,ones(1,N1)).*X1.*X1,1);
            XX2 = sum(w(:,ones(1,N2)).*X2.*X2,1);
            X1X2 = (w(:,ones(1,N1)).*X1)'*X2;
            XX1T = XX1';
            % numerical effects can drive z slightly negative 
            z = max(0,XX1T(:,ones(1,N2)) + XX2(ones(1,N1),:) - 2*X1X2);%z IS normalised by l
            K = par(D+1)^2 *(1+sqrt(5*z)+(5/3)*z).* exp(-sqrt(5*z)); 
        end
        
        function [g] = gradient(X, par)
            
          %Gradient currently not working correctly.
          
            [Kg z] = GP_Mat5Cov.eval(X, X, par);

            [d,n] = size(X);
            g = cell(1,d+1);
            for i=1:d
 
                %Compute weighted squared distance
                row = X(i,:);
                XXi = row.*row;
                XTXi = row'*row;
                XXi = XXi(ones(1,n),:);
                zi = max(0,XXi+XXi'-2*XTXi); %zi is not normalised by l
                g{i} =  par(d+1)^2*(5/3).*(zi/par(i)^3).*(sqrt(5*z)+1).*exp(-sqrt(5*z));

            end
            g{d+1} = Kg*(2/par(d+1));
        end
        
        
        % Also overload the point covariance kx*x* - its trivial
        function v = pointval(x_star, par)
            v = par(end).^2 * ones(1,size(x_star,2));
        end
        
    end
end

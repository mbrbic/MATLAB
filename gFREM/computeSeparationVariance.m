function [vard, I3d]=computeSeparationVariance(x,l1,l2,sig,int_vec, pixelizeversion, offset)
% [vard, I3d]=computeSeparationVariance(x,l1,l2,sig,int_vec, pixelizeversion)
% Computes variance (as a inverse of the Fisher Information) of two points
% separated by a distance d=l1-l2.

if ~exist('offset','var')
    offset = 0; % background 
end

int1_vec=int_vec(1,:);
int2_vec=int_vec(2,:);

lint1=length(int1_vec);
lint2=length(int2_vec);
ll = length(l2);
vard = zeros(1, ll);
I3d = zeros(2,2, ll);

if ndims(x) == 2 %1D vector
    f1=makeGauss(x,l1,sig(1));                  % creates PSF (gauss approx -> !!! Different to simulationtools/makegauss.m !!!)
else 
    f1_2D=makeGauss2D(x,l1,sig(1));
    f1 = reshape(f1_2D,1,numel(f1_2D));          % making 1D vector by concatenating 2D array
end

for ind_dist=1:ll                           % distance
    I=zeros(2);    
    if ndims(x)==2 %1D vector
        f2=makeGauss(x,l2(ind_dist),sig(2));    % creates PSF (gauss approx) shifted to l2
    else
        f2_2D=makeGauss2D(x,l2(ind_dist),sig(2));
        f2 = reshape(f2_2D,1,numel(f2_2D));     % making 1D vector by concatenating 2D array
    end
    for ind_int1=1:lint1                    % intensity of the source 1
        int1=int1_vec(ind_int1);
        for ind_int2=1:lint2                % intensity of the source 1
            int2=int2_vec(ind_int2);            
            % This is accumulating the Fisher Information matrix for
            % different intensities:
            if ~and(int1==0,int2==0)
                I=I+fisherInformationMatrix(x,f1,f2, int1, int2,pixelizeversion, offset);            
            end
        end
    end
    I3d(:,:,ind_dist)=I;    
    vard(ind_dist)=[1,-1]/I*[1,-1]';    
end
q=0;

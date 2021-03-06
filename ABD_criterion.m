function [batch,cand] = ABD_criterion(s_pts,crit, pts2add, options)

% function [batch,cand] = ABD_criterion(s_pts, pts2add, options)
%
% Computes the ABD (angle based diversity) criterion using the input batch of
% candidates [criterion proposed by Demir et al., IEEE TGRS, 2011]
%
%  Inputs:
%    s_pts:   matrix where the first columns are the samples, and the two last
%             columns are the class label (not used here in any way) and the
%             index of the whole pool of samples of each provided sample,
%             respectively
%    crit:    vector with the diversity criterion (MS, MCLU, EQB, ....)
%    pts2add: number of points to select from the candidates in s_pts
%    options: .kern: kernel type, .sigma: kernel free parameter
%
%  Outputs:
%    batch: the indexes of the selected candidates (taken from last column of s_pts)
%    cand:  the indexes of the remaining candidates
%
%
% See also ALToolbox

lambda = 0.6;
batch  = 1;
cand   = 2:size(s_pts,1);

switch options.kern

    case {'lin','rbf'}
        K = kernelmatrix(options.kern, s_pts(:,1:end-2)', s_pts(:,1:end-2)', options.sigma);

    otherwise
        error(['Unsupported kernel type ' options.kern])
        %%% FIXME: we need another option to pass the parameter for each kernel
        %K = kernelmatrix(options.kern, s_pts(:,1:end-2)', s_pts(:,1:end-2)', options.sigma);
        %%% For non RBF kernels we need to compute sqrt (  K(i,i) * K(j,j) )
        %Kij = diag(K);
        %Kij = sqrt(Kij' * Kij);
        %%% Final kernel
        %K = K./Kij;
end

for i = 1:pts2add-1

    val = K(batch,cand);
    if size(val,1) == 1
        massimo = val;%max(val,1);
    else
        massimo = max(val);
    end

    heuristic = lambda * crit(cand)' + (1-lambda) * massimo;
    [val idx] = sort(heuristic);

    % Add to batch
    batch = [batch ; cand(idx(1))];
    % Remove from candidates
    cand(idx(1)) = [];

end

% Return batch and remaining candidates
batch = s_pts(batch,end);
cand  = s_pts(cand,end);

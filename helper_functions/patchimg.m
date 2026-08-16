function hOut = patchimg(I)
%PATCHIMG Plot an indexed image using patches.
% Similar to the IMAGE command, but NAN values are not plotted.
% Will be much slower than IMAGE since it uses patches.
%
% E.g.
% M = eye(5);
% M(M==0) = nan;
% patchimg(M);
%
% M = magic(5);
% idx = ~logical( triu(ones(size(M))) );
% M(idx) = nan;
% patchimg(M);

% Jordan Rosenthal, 08/25/03
% jr@ll.mit.edu
[nRows,nCols] = size(I);
[X,Y] = meshgrid(0:nCols-1, 0:nRows-1);

% Get X/Y/vals of non-nan points
P = [X(:) Y(:)];
idx = find(~isnan(I));
P = P(idx,:);
vals = I(idx);

% Get Vertices/Faces of all patches
boxPts.X = kronadd([0 1 1 0],P(:,1)).';
boxPts.Y = kronadd([0 0 1 1],P(:,2)).';
Vertices = [boxPts.X(:) boxPts.Y(:)];
Faces = reshape(1 : 4*length(vals), 4, []).';

newplot;
is_hold = ishold;

h = patch('Facecolor','flat','Vertices',Vertices,...
     'Faces',Faces,'FaceVertexCData',vals);
if ~ishold
     axis ij;
end

if nargout > 0, hOut = h; end

function K = kronadd(A,B);
%KRONADD Form a large matrix formed by taking all possible
% additions between the elements of X and those of Y. For
% example, if X is 2 by 3, then KRON(X,Y) is
%
% [ X(1,1)+Y X(1,2)+Y X(1,3)+Y
% X(2,1)+Y X(2,2)+Y X(2,3)+Y ]
%
% See also KRON.

% Jordan Rosenthal, 08/26/03
% jr@ll.mit.edu
[ma,na] = size(A);
[mb,nb] = size(B);
ia = 1:ma;
ia = ia(ones(mb,1),:);
ib = (1:mb)';
ib = ib(:,ones(ma,1));
ja = 1:na;
ja = ja(ones(nb,1),:);
jb = (1:nb)';
jb = jb(:,ones(na,1));
K = A(ia,ja)+B(ib,jb); 

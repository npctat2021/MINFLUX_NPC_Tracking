function n=histcnd(varargin)
%
%HISTCND N-Dimensional Histogram Count.
%
%  N = HISTCND(X,Y,XEDGES,YEDGES)
%
%  N = HISTCND(X,Y,Z,... XEDGES,YEDGES,ZEDGES,... )
%
%  Bins the N-D data into a set of bins whose edges in the X
%  dimension are given by XEDGES and in the Y dimesion by
%  YEDGES, etc. The result is a matrix N of counts, with 
%  dimensions LENGTH(XEDGES)-by-LENGTH(YEDGES)-by ... 
% 
%  If XEDGES, YEDGES, etc are monotonically increasing and non-NaN,
%  a data point is assigned to bin N(i,j,k,...) if
% 
%  XEDGES(i) <= X < XEDGES(i+1)
%
%  YEDGES(j) <= Y < YEDGES(j+1)
% 
%  ZEDGES(k) <= Z < ZEDGES(k+1)
% 
%  ....
%
% 
%  More generally, a data point is assgined to a bin N(i,j,...)
%  if XEDGES(i) and  YEDGES(j) are the largest values within the 
%  XEDGES and YEDGES vectors that are less than or equal to X and
%  Y, respectively.
% 
%  Data points that are outside the ranges of the EDGES vectors
%  for example X > max(XEDGES), are excluded from the histogram. 
  
% Author - Mathew Beharrell
%% N is the number of dimensions.
%% There must be an even number of inputs,
%% and N is half of this value.
N=nargin./2;
if N~=floor(N)|N<1
  error('Unexpected number of inputs')
end
%% This loop checks the sizes of the input
%% arrays, and creates the array oki.
%% The data arrays with indices oki contain
%% no NaNs, and no values above the range
%% of the EDGES vectors.
%%
%% varargin{n} are the data for dimension n
%% varargin{n+N} are the edges for dimension n
oki=logical(1);
for n=1:N
  if ~all(size(varargin{1}) == size(varargin{n}))
    error('Data arrays must be the same size');
  end  
  if sum(size(varargin{n+N})>1)>1
    error('EDGES must be rows, vectors, or scalars');
  end
  oki=varargin{n}<=max(varargin{n+N}(:))&oki;
end
%% The purpose of this loop is to calculate
%% the IND array.
%%
%% The IND array is the same size as each of the
%% data arrays, X,Y, etc. but instead of containing
%% floating point data, it contains 'single index'
%% values for the data, these point to the 
%% N-dimensional bins each data point belongs to.
%%
%% First a set of N subscripts is calculated for 
%% the input data,
%%
%%     e.g. for the data point i
%%
%%          X(i) fits in bin XI,
%%          Y(i) fits in bin YI,
%%          Z(i) fits in bin ZI,
%%           ... and so on.
%%
%%    The N subscripts (XI,YI,ZI,...) are converted
%%    to single indices, equivalent to
%%
%%          IND(i)=sub2ind(s,XI,YI,ZI,...)   
%%
%%
%%  (s is the size of the output histogram.
%%  It is initialized with [1 1], so that the 
%%  function will also work for the one dimensional
%%  case. Due to the loop over n, all subscripts
%%  use the label XI, instead of XI,YI,...)
%%
%% The number of times each single-index appears in
%% the array IND can then be counted with HISTC,
%% before being reshaped to N dimensions, with the
%% output size, s.
s=[1 1];
k=1;
IND=1;
for n=1:N
  s(n)=length(varargin{n+N});
  if issorted(varargin{n+N})
    cd=zeros(numel(varargin{n}(oki)),1);
    ce=ones(s(n),1);
    ed=[varargin{n+N}(:);varargin{n}(oki)];
    [ed,edi]=sort(ed);
    ced=[ce;cd];
    csum=cumsum(ced(edi));
    csum(edi)=csum;
    XI=csum(ced==0); 
    XI(XI<1)=nan;
  else
    [varargin{n+N},ei]=sort(varargin{n+N}(:));
    cd=zeros(numel(varargin{n}(oki)),1);
    ce=ones(s(n),1);
    ed=[varargin{n+N};varargin{n}(oki)];
    [ed,edi]=sort(ed);
    ced=[ce;cd];
    csum=cumsum(ced(edi));
    csum(edi)=csum;
    XI=csum(ced==0); 
    XI(XI<1)=nan;
    nn=~isnan(XI);
    XI(nn)=ei(XI(nn));
  end
  IND=IND+(XI-1)*k;
  k=k*s(n);
end
%% The range of the single-indices, IND, is 
%% 1 to s(1) x s(2) x s(3) x ...,
%% where s is the size of the histogram
n1d=histc(IND,1:prod(s));
n=reshape(n1d,s);

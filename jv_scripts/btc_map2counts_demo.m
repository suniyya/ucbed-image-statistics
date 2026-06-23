% demo of determining statistics of a binary image
%
nr=getinp('nrows','d',[16 1024],50);
nc=getinp('ncols','d',[16 1024],200);
p=getinp('prob(1)','f',[0 1],0.5);
map=double(rand(nr,nc)<p);
disp('counts of each kind of 2x2 block')
counts=btc_map2counts(map)
disp(sprintf('total counts %7.0f ((rows-1)*(cols-1)=%7.0f)',sum(counts(:)),(nr-1)*(nc-1)));
disp('values of gamma, beta, etc. in a structure')
corrs=getcorrs_p2x2(counts/sum(counts(:)))
disp('texture parameters as a 10-vector')
coords=btc_corrs2vec(corrs)

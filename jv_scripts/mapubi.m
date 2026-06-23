function [blockcounts,ubi]=mapubi(map,block)
% [blockcounts,ubi]=mapubi(map,block) creates a list of unique blocks,
%  their counts, and a map of indices into them
%  Entries in map must match exactly for two blocks to be considered the same
%
%  map: an image
%  block: 1 x 2 array, number of rows and columns in each block
%
%  blockcounts: array of block counts, one row for each unique block
%     first prod(block) columns are the block occupants; last column is the count
%  ubi: size(map)-block+1: indices of each pixel into blockcounts
%
%   See also:  GLIDER_MAPUBI, UBI_CODEL_MAP.
%
nrc=size(map)-block+1;
% make an exhaustive list of blocks and their counts
blocks=zeros([nrc prod(block)]);
for ir=1:block(1)
    for ic=1:block(2)
        blocks(:,:,ir+(ic-1)*block(1))=map(ir:ir+nrc(1)-1,ic:ic+nrc(2)-1);
    end %ic
end %ir
blocks_rows=reshape(blocks,[prod(nrc) prod(block)]);
[ublocks,ui,uj]=unique(blocks_rows,'rows');
bc=zeros(size(ublocks,1),1);
for j=1:max(uj)
    bc(j)=sum(uj==j);
end
blockcounts=[ublocks,bc];
ubi=reshape(uj,nrc);
return

%% extract_dwi_given_delta(dwi_filename,delta_txt,output_filename,target_delta,vargin)
% 
%
% Input
% --------------
% input_nii     : Input DWI json filename
% out_txt       : Output slspec text filename
%
% Description: get similar volume based on image gradients
%
% Kwok-Shing Chan @ MGH
% kchan2@mgh.harvard.edu
% Date created: 13 October 2023
% Date modified: 
%
function extract_dwi_given_delta(dwi_filename,bval_txt,bvec_txt,DELTA_txt,target_DELTA,output_prefix,varargin)

% load data
nii     = niftiinfo(dwi_filename);
dwi     = niftiread(nii);
bval    = readmatrix(bval_txt,'filetype','text');
bvec    = readmatrix(bvec_txt,'filetype','text');
DELTA   = readmatrix(DELTA_txt,'filetype','text');

% get targhet DELTA
idx_DELTA = DELTA == target_DELTA;

if nargin > 6
    bmax        = varargin{1};
    idx_bmax    = bval <= bmax;
else
    idx_bmax    = ones(size(DELTA));
end
idx = and(idx_DELTA,idx_bmax);

dwi  = dwi(:,:,:,idx);
bval = bval(idx);
bvec = bvec(:,idx);

[filepath] = fileparts(output_prefix);
if ~exist(filepath,'dir')
    mkdir(filepath);
end

nii.ImageSize = size(dwi);
niftiwrite(dwi,strcat(output_prefix,'_dwi'),nii,'Compressed',true);
writematrix(bval,strcat(output_prefix,'.bval'),'FileType','text');
writematrix(bvec,strcat(output_prefix,'.bvec'),'FileType','text');


end
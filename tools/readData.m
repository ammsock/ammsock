%  Copyright (C) 2022 Pascal Heiter
%  ----------------------------------------------------------------------------
% This file is part of AMMSoCK.
%
% AMMSoCK is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version. AMMSoCK is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details. You should have received a copy of the GNU General Public License
% along with AMMSoCK. If not, see <https://www.gnu.org/licenses/>.

cd ./mech

% include ammsock parameters
cmd = sprintf('g++ -Wall %s/mex/readData.cpp -o readData -I%s',path_ammsock,pwd);

status = system(cmd);

if (status ~= 0)
   error('Error: Can not compile readData.')
end

if ~exist('data','dir')
    mkdir data
end

cd ..

if ~exist('cpp','dir')
    mkdir cpp
end

if ~exist('matlab','dir')
    mkdir matlab
    addpath([pwd,'/matlab'])
end

cmd = sprintf('./mech/readData %s/mech %s',cur_path,mechfile);

system(cmd);


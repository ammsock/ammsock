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

% include ammsock parameters
cmd = sprintf('g++ -Wall %s/mex/codegenerator.cpp -o generateCode -I%s',path_ammsock,pwd);

status = system(cmd);

if (status ~= 0)
   error('Error: Can not compile codeGenerator.')
end

if ~exist('cpp','dir')
    mkdir cpp
end

cd ./cpp

cmd = sprintf('../generateCode %s/mech %s c++',cur_path,mechfile);

system(cmd);

cd ..

if ~exist('matlab','dir')
    mkdir matlab
end

cd ./matlab

cmd = sprintf('../generateCode %s/mech %s matlab',cur_path,mechfile);

system(cmd);

cd ..

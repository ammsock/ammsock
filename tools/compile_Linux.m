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

% interface sources
files = [ sprintf(' %s/mex/performReduction.cpp ',path_ammsock), sprintf(' %s/mex/ammsockNLP.cpp ',path_ammsock)] ;

% compiler options
CXXFLAGS = '-fPIC -O3 -DMATLAB_MEXFILE ' ;

% extra libs
% LIBS = '' ;

% full path to Ipopt Build
PREFIX = '/opt/CoinIpopt/build' ;

INCL = [ '-I../src ' ...
         '-I/usr/lib' ...
         '-I' PREFIX ...
         '-I' PREFIX '/include ' ...
         '-I' PREFIX '/include/coin ' ...
         '-I.' ] ;

% full path where gfortran is installed, MATLAB do not known where is
GFORTRANCMD = '/usr/bin/gfortran' ;

% full path to MATLAB
MATLAB = '/usr/local/MATLAB/R2016a' ;

LIBS = [ '-L' PREFIX '/lib -lipopt -L/usr/lib -lgfortran -lquadmath -lstdc++ -ldl -lm -lc'];
% LIBS = [ LIBS ' -L' MATLAB '/bin/glnxa64 -lmwma57' ] ;

% compiler options
MEXFLAGS = [ '-v -cxx -largeArrayDims ' ...
             'COPTIMFLAGS="' CXXFLAGS '" ' ...
             'CXXOPTIMFLAGS="' CXXFLAGS '" ' ...
             'LDOPTIMFLAGS="" ' ...
             'CXXLIBS=''$CXXLIBS '  ''''  ] ; % -static -shared-libgcc


% build and execute compilation command
cmd = sprintf('mex %s %s %s %s',MEXFLAGS,INCL,files,LIBS) ;
eval(cmd);

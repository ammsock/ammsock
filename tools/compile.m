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
LIBS = '' ;

% full path to Ipopt Build
PREFIX = '/Users/pfh/lib/Ipopt-3.12.4/build' ;

INCL = [ '-I../src ' ...
         '-I' PREFIX '/include ' ...
         '-I' PREFIX '/include/coin ' ...
         '-I' cur_path ] ;

% full path where gfortran is installed, MATLAB do not known where is
GFORTRANCMD = '/usr/local/bin/gfortran' ;

% full path to MATLAB
MATLAB = '/Applications/MATLAB_R2015b.app' ;

% add list of static version of fortran libraries
[status,GFORTRAN] = system([ GFORTRANCMD ' -print-file-name=libgfortran.a']) ;
[status,QUAD]     = system([ GFORTRANCMD ' -print-file-name=libquadmath.a']) ;
[status,GCC]      = system([ GFORTRANCMD ' -print-file-name=libgcc.a']) ;
files = sprintf('%s %s %s %s',files, ...
                 GFORTRAN(1:end-1), ...
                 QUAD(1:end-1), ...
                 GCC(1:end-1) ) ;

LIBS = ['-L',PREFIX,'/lib -lipopt -L',PREFIX,'/lib -lcoinhsl'];
% frameworks
LIBS2 = '-framework Accelerate ' ; % -Wl,-no_compact_unwind

% compiler options
MEXFLAGS = [ '-cxx -largeArrayDims ' ...
             'CXXOPTIMFLAGS="' CXXFLAGS '" ' ...
             'LDFLAGS=''$LDFLAGS ' LIBS2 ''''  ] ;

% build and execute compilation command
cmd = sprintf('mex %s %s %s %s',MEXFLAGS,INCL,files,LIBS) ;
eval(cmd);

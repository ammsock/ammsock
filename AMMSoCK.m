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

classdef AMMSoCK
    %AMMSoCK Class for Manifold-based Modelreduction
    %   toDo

    properties
        problemname
        nspec   %number of species
        nreac   %number of reactions
        natom   %number of atoms
        ntb     %number of third bodys
        nrtb    %number of third body reactions
        nfr     %number of forward reactions
        nstages %number of stages
        nrpv    %number of reaction progress variables
        nint    %number of collocation intervals
        nnop    %number of elements in Inop
        nop     %number of elements in Iop
        species
        atoms
        indexRpv
        Iop
        Inop
        workingDir
        hcoll
        Acoll
        hfixed
        atomCons
        scale
        maxit
        eq
        oxidizer
        fuel
        Yres
        exactHessian
    end

    methods
        function obj = AMMSoCK(name)
            obj.problemname = name;
        end
        function setGenerationParameter(obj)
            fid = fopen([obj.workingDir,'/cpp/generationStats.hpp'],'w');
            fprintf(fid,'#define NSPEC %i\n',obj.nspec);
            fprintf(fid,'#define NREAC %i\n',obj.nreac);
            fprintf(fid,'#define NATOM %i\n',obj.natom);
            fprintf(fid,'#define NTB %i\n',obj.ntb);
            fprintf(fid,'#define NRTB %i\n',obj.nrtb);
            fprintf(fid,'#define NRPV %i\n',obj.nrpv);
            fprintf(fid,'#define INDRPV { ');
            for i=1:length(obj.indexRpv)-1
                fprintf(fid,'%i, ',find(obj.Iop==obj.indexRpv(i))-1);
            end
            fprintf(fid,'%i }\n',find(obj.Iop==obj.indexRpv(end))-1);
            fprintf(fid,'#define NSTAGES %i\n',obj.nstages);
            fprintf(fid,'#define NINT %i\n',obj.nint);
            fprintf(fid,'#define ACOLL {');
            for i = 1:obj.nstages
                fprintf(fid,'{');
                for j = 1:obj.nstages-1
                    fprintf(fid,'%1.15d, ',obj.Acoll(i,j));
                end
                fprintf(fid,'%1.15d',obj.Acoll(i,obj.nstages));
                if i < obj.nstages
                    fprintf(fid,'}, ');
                else
                    fprintf(fid,'}');
                end
            end
            fprintf(fid,'}\n');
            fprintf(fid,'#define NNOP %i\n',obj.nnop);
            fprintf(fid,'#define INOP {');
            for i = 1:length(obj.Inop)-1
                fprintf(fid,'%i, ',obj.Inop(i));
            end
            if (~isempty(obj.Inop))
                fprintf(fid,'%i }\n',obj.Inop(end));
            else
                fprintf(fid,'}\n');
            end
            fprintf(fid,'#define NOP %i\n',obj.nop);
            fprintf(fid,'#define IOP {');
            for i = 1:length(obj.Iop)-1
                fprintf(fid,'%i, ',obj.Iop(i));
            end
            fprintf(fid,'%i }\n',obj.Iop(end));
            fprintf(fid,'#define FUEL "%s"\n',obj.fuel);
            fprintf(fid,'#define OXIDIZER "%s"\n',obj.oxidizer);
            if strcmp(obj.exactHessian,'true')
                fprintf(fid,'#define EXACTHESSIAN %i\n',1);
            else
                fprintf(fid,'#define EXACTHESSIAN %i\n',0);
            end
            fclose(fid);
        end
        function obj = getParserStatistics(obj)
            fid = fopen([obj.workingDir,'/mech/data/readerStats.dat']);

            obj.nreac = str2double(fgetl(fid));
            obj.nspec = str2double(fgetl(fid));

            for i = 1:obj.nspec
                obj.species{i} = fgetl(fid);
            end

            obj.natom = str2double(fgetl(fid));
            for i = 1:obj.natom
                obj.atoms{i} = fgetl(fid);
            end

            obj.ntb = str2double(fgetl(fid));
            obj.nrtb = str2double(fgetl(fid));
            obj.nfr = str2double(fgetl(fid));
        end
        function obj = setCombustion(obj, fuel, oxidizer)
            %check if fuel is a specie
            fuelContained = 0;
            for i=1:obj.nspec
                if strcmp(fuel,obj.species{i})
                    fuelContained = 1;
                end
            end
            if ~fuelContained
                error('Error: Please choose a valid species as fuel.')
            end
            obj.fuel = fuel;
            if ~(strcmp(oxidizer,'Air(N2,O2)') || strcmp(oxidizer,'Air(N2,O2,Ar)')
                || strcmp(oxidizer,'O2'))
                error('Error: Oxidizer must be Air(N2,O2), Air(N2,O2,Ar) or O2.')
            end
            obj.oxidizer = oxidizer;
        end
    end
end


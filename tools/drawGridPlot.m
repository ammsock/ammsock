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

function drawGridPlot(y,ammsock,indrpv,style)

nspec = ammsock.nspec;
species = ammsock.species;
indexSet = 1:nspec;
indexSet(indrpv) = [];

% grid size
nplots = nspec-length(indrpv);
dim = ceil(sqrt(nplots));

% set font to Palantino
%set(0,'DefaultAxesFontName','Palantino');
%set(0,'DefaultTextFontName','Palantino');

% 2d Plot
if length(indrpv) == 1
    % plot species
    for i=1:nplots
        subplot(dim,dim,i)
        set(gca,'FontSize',20)
        hold on
        if isfield(style,'LineSpec')
            plot(y(:,indrpv),y(:,indexSet(i)),style.LineSpec)
        else
            plot(y(:,indrpv),y(:,indexSet(i)),'LineStyle',style.LineStyle,...
                                              'LineWidth',style.LineWidth,...
                                              'Color',style.Color,...
                                              'Marker',style.Marker,...
                                              'MarkerSize',style.MarkerSize);
        end
        xlabel(sprintf('Y_{%s}',species{indrpv}))
        ylabel(sprintf('Y_{%s}',species{indexSet(i)}))
        grid on
        axis tight
    end

    % plot temperature
    subplot(dim,dim,nplots+1)
    set(gca,'FontSize',20)
    hold on
    if isfield(style,'LineSpec')
        plot(y(:,indrpv),y(:,end),style.LineSpec)
    else
        plot(y(:,indrpv),y(:,end),'LineStyle',style.LineStyle,...
                                          'LineWidth',style.LineWidth,...
                                          'Color',style.Color,...
                                          'Marker',style.Marker,...
                                          'MarkerSize',style.MarkerSize);
    end
    xlabel(sprintf('Y_{%s}',species{indrpv}))
    ylabel('T')
    grid on
    axis tight

% 3d Plot
elseif length(indrpv) == 2
    % plot species
    for i=1:nplots
        subplot(dim,dim,i)
        set(gca,'FontSize',20)
        hold on
        if isfield(style,'LineSpec')
            plot3(y(:,indrpv(1)),y(:,indrpv(2)),y(:,indexSet(i)),style.LineSpec)
        else
            plot3(y(:,indrpv(1)),y(:,indrpv(2)),y(:,indexSet(i)),'LineStyle',style.LineStyle,...
                                              'LineWidth',style.LineWidth,...
                                              'Color',style.Color,...
                                              'Marker',style.Marker,...
                                              'MarkerSize',style.MarkerSize);
        end
        xlabel(sprintf('Y_{%s}',species{indrpv(1)}))
        ylabel(sprintf('Y_{%s}',species{indrpv(2)}))
        zlabel(sprintf('Y_{%s}',species{indexSet(i)}))
        view(3)
        grid on
        axis tight
    end

    % plot temperature
    subplot(dim,dim,nplots+1)
    set(gca,'FontSize',20)
    hold on
    if isfield(style,'LineSpec')
        plot3(y(:,indrpv(1)),y(:,indrpv(2)),y(:,end),style.LineSpec)
    else
        plot3(y(:,indrpv(1)),y(:,indrpv(2)),y(:,end),'LineStyle',style.LineStyle,...
                                          'LineWidth',style.LineWidth,...
                                          'Color',style.Color,...
                                          'Marker',style.Marker,...
                                          'MarkerSize',style.MarkerSize);
    end
    xlabel(sprintf('Y_{%s}',species{indrpv(1)}))
    ylabel(sprintf('Y_{%s}',species{indrpv(2)}))
    zlabel('T')
    view(3)
    grid on
    axis tight
else
    error('Please select a 2d or 3d projection.')
end

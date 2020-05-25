function profilerMorales(files,algorithms,file_format,column,options)

% profilerDolanMore
%
% Author      : Frank E. Curtis
% Description : Generates pairwise Morales performance profiles.
% Inputs      : files       ~ array of input file names
%               algorithms  ~ array of corresponding algorithm names
%               file_format ~ string indicating format of input files
%               column      ~ column of input files with performance measure
%               options     ~ struct of (optional) options
% Options     : plot_bw     ~ plot black-and-white profile
%                             true or false (default = false)
%               plot_color  ~ plot color profile
%                             true or false (default = true)
%               ratio_max   ~ limit for vertical axis;
%                             positive scalar (default = 1)

% Read data
readData;

% Read local options
if ~isfield(options,'ratio_max')
  ratio_max = 1;
else
  ratio_max = options.ratio_max;
end

% Initialize figure counter
fig_count = 1;

% Loop through pairs
for alg1 = 1:(size(data,2)-1)
  
  % Loop through pairs
  for alg2 = (alg1+1):size(data,2)
    
    % Compute ratios
    ratios = -log2(data(:,alg1)./data(:,alg2));
    
    % Set bar values
    bars_pos = zeros(length(ratios),1);
    bars_neg = zeros(length(ratios),1);
    for counter = 1:length(ratios)
      if ratios(counter) > 0, bars_pos(counter) = ratios(counter);
      else                    bars_neg(counter) = ratios(counter); end
    end
    bars_pos(bars_pos== Inf) =  ratio_max;
    bars_neg(bars_neg==-Inf) = -ratio_max;
    
    % Sort bars by height
    bars_pos = sort(bars_pos,'descend');
    bars_neg = sort(bars_neg,'descend');
    
    % Create figures
    for figs = 1:2
      if figs == 1 && ~plot_color
        continue;
      elseif figs == 2 && ~plot_bw
        continue;
      end
      figure(fig_count);
      fig_count = fig_count + 1;
      hold on;
      axis([0 size(data,1)+1 -ratio_max ratio_max]);
      if figs == 1
        bar(bars_pos,'facecolor','b');
        bar(bars_neg,'facecolor','r');
      else
        bar(bars_pos,'facecolor','k');
        bar(bars_neg,'facecolor','Color',[64 64 64]/255);
      end
      ylabel(['-log2(ratio)']);
      text(0.75*size(data,1), 0.5,algorithms{alg1},'FontSize',14);
      text(0.15*size(data,1),-0.5,algorithms{alg2},'FontSize',14);
      set(gca,'FontSize',14);
    end
    
  end
  
end

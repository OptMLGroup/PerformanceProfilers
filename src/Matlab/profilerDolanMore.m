function profilerDolanMore(files,algorithms,file_format,column,options)

% profilerDolanMore
%
% Author      : Frank E. Curtis
% Description : Generates a Dolan & Moré performance profile up to maximum
%               ratio of "tau".
% Inputs      : files       ~ array of input file names
%               algorithms  ~ array of corresponding algorithm names
%               file_format ~ string indicating format of input files
%               column      ~ column of input files with performance measure
%               options     ~ struct of (optional) options
% Options     : log_scale   ~ indicator of whether to use log scale;
%                             true or false (default = false)
%               plot_bw     ~ plot black-and-white profile
%                             true or false (default = false)
%               plot_color  ~ plot color profile
%                             true or false (default = true)
%               tau_max     ~ limit for horizontal axis;
%                             positive scalar (default = infinity)

% Read data
readData;

% Read local options
if ~isfield(options,'log_scale')
  log_scale = false;
else
  log_scale = options.log_scale;
end
if ~isfield(options,'tau_max')
  tau_max = inf;
else
  tau_max = options.tau_max;
end

% Construct vector of best values by row
best_by_row = min(data,[],2);

% Construct ratio matrix and determine maximum finite value
ratios = zeros(num_problems,num_algorithms);
ratio_max = -1;
for i = 1:num_problems
  if best_by_row(i) == inf
    ratios(i,:) = inf;
  else
    for j = 1:num_algorithms
      ratios(i,j) = data(i,j)/best_by_row(i);
      if ratios(i,j) < inf && ratios(i,j) > ratio_max
        ratio_max = ratios(i,j);
      end
    end
  end
end
ratio_max = min(ratio_max,tau_max);

% Sanity check: minimum value for each problem
% should be 1 (a success) or inf (all fail)
for i = 1:num_problems
  if min(ratios(i,:)) ~= 1 && min(ratios(i,:)) ~= inf
    error('profilerDolanMore: Ratio sanity check failed!\n');
  end
end

% Reshape ratios matrix to determine appropriate increment for plot
ratios_reshaped = reshape(ratios,num_problems*num_algorithms,1);

% Sort ratios
ratios_sorted = sort(ratios_reshaped);

% Determine increment
increment = inf;
for i = 1:length(ratios_sorted)-1
  difference = ratios_sorted(i+1)-ratios_sorted(i);
  if difference > 0 && difference < increment
    increment = difference;
  end
end
increment = max(increment,(ratio_max+increment-1)/100);

% Ensure increment is finite
if increment == inf
  error('profilerDolanMore: Increment for profile is infinite.  Did all algorithms have equal performance?\n');
end

% Set tau values
tau = 1:increment:(ratio_max+increment);

% Log scale?
if log_scale
  ratios = log2(ratios);
  ratio_max = log2(ratio_max);
  tau = log2(tau);
end

% Construct matrix of values for plot
profile_values = zeros(num_algorithms,length(tau));
for i = 1:num_algorithms
  for j = 1:length(tau)
    profile_values(i,j) = sum(ratios(:,i) <= tau(j))/num_problems;
  end
end

% Compute area under the curve for each algorithm
auc = zeros(num_algorithms,1);
for i = 1:num_algorithms
  for j = 1:length(tau)-1
    if tau(j+1) <= ratio_max
      auc(i) = auc(i) + profile_values(i,j)*(tau(j+1) - tau(j));
    elseif tau(j) <= ratio_max
      auc(i) = auc(i) + profile_values(i,j)*(ratio_max - tau(j));
    end
  end
end

% Print ranking in terms of best measure
[~,ind] = sort(profile_values(:,1),'descend');
fprintf('Best measure ranking:\n');
for i = 1:length(ind)
  fprintf('%20s solved %5.2f percent of the problems with the best performance measure\n',algorithms{ind(i)},100*profile_values(ind(i),1));
end
fprintf('\n');

% Print ranking in terms of reliability
[~,ind] = sort(profile_values(:,end),'descend');
fprintf('Reliability ranking:\n');
for i = 1:length(ind)
  fprintf('%20s solved %5.2f percent of the problems with ratio less than or equal to tau_max = %f\n',algorithms{ind(i)},100*profile_values(ind(i),end),tau_max);
end
fprintf('\n');

% Print ranking in terms of area under the curve
[~,ind] = sort(auc,'descend');
fprintf('Relative area under the curve ranking:\n');
for i = 1:length(ind)
  fprintf('%20s has area %e and relative area (to maximum) %e\n',algorithms{ind(i)},auc(ind(i)),auc(ind(i))/max(auc));
end
fprintf('\n');

% Create figures
for figs = 1:2
  if figs == 1 && ~plot_color
    continue;
  elseif figs == 2 && ~plot_bw
    continue;
  end
  figure(figs);
  if figs == 1
    stairs(tau,profile_values(1,:),'DisplayName',algorithms{1},'LineWidth',2);
    hold on
    for i = 2:num_algorithms
      stairs(tau,profile_values(i,:),'DisplayName',algorithms{i},'LineWidth',2);
    end
  else
    colormap('gray');
    cmap = colormap;
    stairs(tau,profile_values(1,:),'DisplayName',algorithms{1},'LineWidth',2,'Color',cmap(1,:));
    hold on
    for i = 2:num_algorithms
      stairs(tau,profile_values(i,:),'DisplayName',algorithms{i},'LineWidth',2,'Color',cmap(ceil((i-1)*size(cmap,1)/num_algorithms),:));
    end
  end
  legend('Location','southeast');
  if ~log_scale
    ylabel('p(ratio <= \tau)');
  else
    ylabel('p(log(ratio) \leq \tau)');
  end
  xlabel('\tau');
  if ~log_scale
    axis([1 ratio_max 0 1]);
  else
    axis([0 ratio_max 0 1]);
  end
  set(gca,'FontSize',14)
end
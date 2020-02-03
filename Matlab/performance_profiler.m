function performance_profiler(files,algorithms,file_format,column,log_scale,tau_max)

% performance profiler
%
% Author      : Frank E. Curtis
% Description : Generates a Dolan & Moré performance profile
% Input(s)    : files       ~ array of input file names
%               algorithms  ~ array of corresponding algorithm names
%               file_format ~ string indicating format of input files
%               column      ~ column of input files with performance measure
%               log_scale   ~ use log scaling? (true or false)
%               tau_max     ~ maximum ratio in plot
% Note        : Please see performance_profiler_launcher.m for further details

% Determine number of algorithms
num_algorithms = length(algorithms);

% Check that number of files == number of algorithms
if (length(files) ~= num_algorithms)
  fprintf('ERROR: Number of file names not equal to the number of algorithm names provided\n');
  return
end

% Open files
for i = 1:num_algorithms
  f_in{i} = fopen(files{i},'r');
  if (f_in{i} == -1)
    fprintf('ERROR: Could not open input file: %s\n',files{i});
    return
  end
end

% Read data
for i = 1:num_algorithms
  D{i} = textscan(f_in{i},file_format);
end

% Close files
for i = 1:num_algorithms
  fclose(f_in{i});
end

% Confirm that the same number of lines has been read from all files
for i = 2:num_algorithms
  if length(D{1}{1}) ~= length(D{i}{1})
    fprintf('ERROR: Number of lines read from input file     : %s\n',files{1});
    fprintf('       differs from number read from input file : %s\n',files{i});
    return
  end
end

% Set number of problems
num_problems = length(D{1}{1});

% Construct matrix of values for profile
M = zeros(num_problems,num_algorithms);
for i = 1:num_algorithms
  M(:,i) = D{i}{column};
end

% Check that values are numeric
if ~isnumeric(M)
  fprintf('ERROR: Performance measures include non-numeric value\n');
  return
end

% Check that values are nonzero
if sum(sum(M==0))
  fprintf('ERROR: Performance measures include zero value\n');
  return
end

% Set negative values to infinity
M(M < 0) = inf;

% Construct vector of best values
best = min(M')';

% Construct ratio matrix and determine maximum finite value
R = zeros(num_problems,num_algorithms);
max_ratio = -1;
for i = 1:num_problems
  if best(i) == inf
    R(i,:) = inf;
  else
    for j = 1:num_algorithms
      R(i,j) = M(i,j)/best(i);
      if R(i,j) < inf && R(i,j) > max_ratio
        max_ratio = R(i,j);
      end
    end
  end
end
max_ratio = min(max_ratio,tau_max);

% Sanity check: minimum value for each problem
% should be 1 (a success) or inf (all fail)
for i = 1:num_problems
  if min(R(i,:)) ~= 1 && min(R(i,:)) ~= inf
    fprintf('ERROR: Ratio sanity check failed\n');
    return
  end
end

% Reshape R to determine increment
R_reshaped = reshape(R,num_problems*num_algorithms,1);

% Sort ratios
R_sorted = sort(R_reshaped);

% Determine increment
increment = inf;
for i = 1:length(R_sorted)-1
  difference = R_sorted(i+1)-R_sorted(i);
  if difference > 0 && difference < increment
    increment = difference;
  end
end
increment = max(increment,(max_ratio+increment-1)/100);

% Ensure increment is finite
if increment == inf
  fprintf('ERROR: Increment for profile is infinite.  Did all algorithms have equal performance?\n');
  return
end

% Set tau values
tau = 1:increment:(max_ratio+increment);

% Log scale?
if log_scale
  R = log2(R);
  max_ratio = log2(max_ratio);
  tau = log2(tau);
end

% Construct matrix of values for plot
P = zeros(num_algorithms,length(tau));
for i = 1:num_algorithms
  for j = 1:length(tau)
    P(i,j) = sum(R(:,i) <= tau(j))/num_problems;
  end
end

% Compute area under the curve for each algorithm
A = zeros(num_algorithms,1);
for i = 1:num_algorithms
  for j = 1:length(tau)-1
    if tau(j+1) <= max_ratio
      A(i) = A(i) + P(i,j)*(tau(j+1) - tau(j));
    elseif tau(j) <= max_ratio
      A(i) = A(i) + P(i,j)*(max_ratio - tau(j));
    end
  end
end

% Print ranking in terms of best measure
[~,ind] = sort(P(:,1),'descend');
fprintf('Best measure ranking:\n');
for i = 1:length(ind)
  fprintf('%20s (algorithm %2d) solved %5.2f percent of the problems with the best performance measure\n',algorithms{ind(i)},ind(i),100*P(ind(i),1));
end
fprintf('\n');

% Print ranking in terms of reliability
[~,ind] = sort(P(:,end),'descend');
fprintf('Reliability ranking:\n');
for i = 1:length(ind)
  fprintf('%20s (algorithm %2d) solved %5.2f percent of the problems with ratio less than or equal to max_tau = %f\n',algorithms{ind(i)},ind(i),100*P(ind(i),end),tau_max);
end
fprintf('\n');

% Print ranking in terms of area under the curve
[~,ind] = sort(A,'descend');
fprintf('Relative area under the curve ranking:\n');
for i = 1:length(ind)
  fprintf('%20s (algorithm %2d) has area %e and relative area (to maximum) %e\n',algorithms{ind(i)},ind(i),A(ind(i)),A(ind(i))/max(A));
end
fprintf('\n');

% Create figures
for figs = 1:2
  figure(figs);
  if figs == 1
    stairs(tau,P(1,:),'DisplayName',algorithms{1},'LineWidth',2);
    hold on
    for i = 2:num_algorithms
      stairs(tau,P(i,:),'DisplayName',algorithms{i},'LineWidth',2);
    end
  else
    colormap('gray');
    cmap = colormap;
    stairs(tau,P(1,:),'DisplayName',algorithms{1},'LineWidth',2,'Color',cmap(1,:));
    hold on
    for i = 2:num_algorithms
      stairs(tau,P(i,:),'DisplayName',algorithms{i},'LineWidth',2,'Color',cmap(ceil((i-1)*size(cmap,1)/num_algorithms),:));
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
    axis([1 max_ratio 0 1]);
  else
    axis([0 max_ratio 0 1]);
  end
  set(gca,'FontSize',14)
end
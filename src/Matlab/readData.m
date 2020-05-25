% readData
%
% Author      : Frank E. Curtis
% Description : Reads data for performance profilers.

% Read options
if ~isfield(options,'plot_bw')
  plot_bw = false;
else
  plot_bw = options.plot_bw;
end
if ~isfield(options,'plot_color')
  plot_color = true;
else
  plot_color = options.plot_color;
end

% Determine number of algorithms
num_algorithms = length(algorithms);

% Check that number of files == number of algorithms
if (length(files) ~= num_algorithms)
  error('profilerDolanMore: Number of file names not equal to the number of algorithm names provided.\n');
end

% Open files
f_in = cell(num_algorithms,1);
for i = 1:num_algorithms
  f_in{i} = fopen(files{i},'r');
  if (f_in{i} == -1)
    error('profilerDolanMore: Could not open input file: %s\n',files{i});
  end
end

% Read raw data
raw_data = cell(num_algorithms,1);
for i = 1:num_algorithms
  raw_data{i} = textscan(f_in{i},file_format);
end

% Close data files
for i = 1:num_algorithms
  fclose(f_in{i});
end

% Confirm that the same number of lines has been read from all files
for i = 2:num_algorithms
  if length(raw_data{1}{1}) ~= length(raw_data{i}{1})
    msg = ['profilerDolanMore: Number of lines read from input file     : ' files{1} '\n' ...
           '                   differs from number read from input file : ' files{i} '.'];
    error(msg);
  end
end

% Set number of problems
num_problems = length(raw_data{1}{1});

% Construct matrix of values for profile
data = zeros(num_problems,num_algorithms);
for i = 1:num_algorithms
  data(:,i) = raw_data{i}{column};
end

% Check that values are numeric
if ~isnumeric(data)
  error('profilerDolanMore: Performance measures include non-numeric value.');
end

% Check that values are nonzero
if sum(sum(data==0))
  error('profilerDolanMore: Performance measures include zero value.');
end

% Set negative values to infinity
data(data < 0) = inf;
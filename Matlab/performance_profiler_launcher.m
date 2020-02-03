function performance_profiler_launcher

% performance_profiler_launcher
%
% Author      : Frank E. Curtis
% Description : Calls performance_profiler.m to generate a Dolan & Moré
%               performance profile using inputs given in this function
% Note        : This file provides the following inputs:
%
% files       ~ names of input files containing performance measure data
% algorithms  ~ names of algorithms corresponding to the input files
% file_format ~ string indicating format of each line of input files
% column      ~ column containing performance measure data of interest
% log_scale   ~ indicates whether to use log scaling for profile
% tau_max     ~ maximum ratio to consider
%
% Example     : Suppose that there are two input files:
%
% algorithm_1.txt, with contents (two lines only):
% problem_1  1  2.0
% problem_2  3  4.0
%
% algorithm_2.txt, with contents (two lines only):
% problem_1  5  6.0
% problem_2 -1 -1.0
%
% where the first column in each line indicates a problem name, the second
% column indicates the number of iterations required, and the third column
% indicates the final value of the objective function.  To generate a
% performance profile for the number of iterations required, the inputs
% could be given as follows:
%
% files = {'algorithm_1.txt','algorithm_2.txt'};
% algorithms = {'Algorithm 1','Algorithm 2'};
% file_format = '%s %d %f';
% column = 2;
% log_scale = true;
% max_ratio = inf;
%
% Notes       :
% - Use a negative value to indicate failure to solve a problem
% - All other performance measure values should be strictly positive (not zero)
% - All lines of the input files must have the same format
% - All input files must have the same number of lines

% Files containing data
files = {
  'algorithm_1.txt',
  'algorithm_2.txt'
};

% Algorithms associated with files
algorithms = {
  'Algorithm 1',
  'Algorithm 2'
};

% File format per line
file_format = '%s %d %f';

% Column to consider
column = 2;

% Log scale?
log_scale = false;

% Maximum ratio?
tau_max = inf;

% Call profiler
performance_profiler(files,algorithms,file_format,column,log_scale);
function testMatlabMorales

% testMatlabMorales
%
% Author      : Frank E. Curtis
% Description : Tests Matlab implementation of Morales profiler.
% Note        : This file provides the following inputs:
%
% files       ~ names of input files containing performance measure data
% algorithms  ~ names of algorithms corresponding to the input files
% file_format ~ string indicating format of each line of input files
% column      ~ column containing performance measure data of interest
% options     ~ struct of (optional) options
%               see profilerMorales for more information about options
%
% Example : Suppose that there are two input files:
%
% algorithm_1.txt, with contents:
% problem_1  1  2.0
% problem_2  3  4.0
%
% algorithm_2.txt, with contents:
% problem_1  5  6.0
% problem_2 -1 -1.0
%
% where the first column in each line indicates a problem name, the second
% column indicates the number of iterations required, and the third column
% indicates the final value of the objective function.  To generate a
% performance profile for the number of iterations required, the inputs
% could be given as follows:
%
% >> files = {'algorithm_1.txt','algorithm_2.txt'};
% >> algorithms = {'Algorithm 1','Algorithm 2'};
% >> file_format = '%s %d %f';
% >> column = 2;
%
% Notes :
% - Use a negative value to indicate failure to solve a problem
% - All other performance measure values should be strictly positive (not zero)
% - All lines of the input files must have the same format
% - All input files must have the same number of lines

% Files containing data
files = {
  'algorithm_1.txt'
  'algorithm_2.txt'
};

% Algorithms associated with files
algorithms = {
  'Algorithm 1'
  'Algorithm 2'
};

% File format per line
file_format = '%s %d %f';

% Column to consider
column = 2;

% Color plot
options.ratio_max = 1;

% Add location of profiler to path
addpath('../src/Matlab/');

% Call profiler
profilerMorales(files,algorithms,file_format,column,options);
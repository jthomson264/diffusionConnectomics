function [ simpleSum ] = simpleSum( a, b, filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
answer = a+b;
save(filename, 'answer');
simpleSum = answer;

end


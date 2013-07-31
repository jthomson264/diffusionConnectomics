%   This is a script to generate N random TRK files from a FIB file.
%   
%   The TRKs are generated with random parameter values, using uniform
%   distributions on each parameter, with ranges either coming 
%   directly from Frank Yeh, or from me and then confirmed by Frank.

numTracks = 300;
fileName = '/media/data2/randomParameters/data.fib.gz';
fiberCount = int2str(100000);

%   SET PARAMETER RANGES

%   Step Size
%   step size is on the scale of a millimeter
min_step_size = 0.5;
max_step_size = 2.0;

%   Interpolation Angle
%       interpo_angle specifies the maximum turning angle from one step to
%       the next
min_interpo_angle = 5;
max_interpo_angle = 90;

%   Fractional Anisotropy Threshold
%   fa_threshold does not use Fractional Anisotropy (FA).  It actually uses
%   Q which stands for Quantitative Anisotropy.  QA threshold is typically
%   set at 2.2 or near this, and is determined by comparing the QA map
%   (found in the FA matrix of a FIB file in matlab, with the white matter
%   mask.
min_fa_threshold = 1; 
max_fa_threshold = 3;

%   Smoothing
%       smoothing determines the linear mixing of previous direction with
%       the current direction.  0 means no smoothing at all, 0.2 means that
%       each subsequent direction has a 20% weighting contributed from the
%       previous moving direction and an 80% weight coming from the new
%       direction.  (paraphrased from DSI documentation).
min_smoothing = 0;
max_smoothing = 1.0;

%   Minimum Length
%       min_length is the minimum permissible length of a tract, in
%       millimeters.
min_min_length = 0.01;
max_min_length = 1.00;

%   Maximum Length
%       max_length is the maximum permissible length of a tract, in
%       millimeters.
min_max_length = 350;
max_max_length = 1000;

%  SET THINGS UP FOR STORAGE OF PARAMETERS USED
stepSizes = zeros(numTracks,1);
interpoAngles = zeros(numTracks,1);
faThresholds= zeros(numTracks,1);
smoothings=zeros(numTracks,1);
minLengths=zeros(numTracks,1);
maxLengths=zeros(numTracks,1);

%   LOOP THROUGH TRKs
for i = 1:numTracks


%   GENERATE RANDOM PARAMETER VALUES
random_step_size = min_step_size + (max_step_size - min_step_size)*rand(1);
random_interpo_angle = min_interpo_angle + (max_interpo_angle - min_interpo_angle)*rand(1);
random_fa_threshold = min_fa_threshold + (max_fa_threshold - min_fa_threshold)*rand(1);
random_smoothing = min_smoothing + (max_smoothing - min_smoothing)*rand(1);
random_min_length = min_min_length + (max_min_length - min_min_length)*rand(1);
random_max_length = min_max_length + (max_max_length - min_max_length)*rand(1);

% STORE RANDOM PARAMETER VALUES
stepSizes(i) = random_step_size;
interpoAngles(i) = random_interpo_angle;
faThresholds(i) = random_fa_threshold;
smoothings(i) = random_smoothing;
minLengths(i) = random_min_length;
maxLengths(i) = random_max_length;



%   MAKE STRINGS TO SET DSI PARAMETERS
setStepSize = [' --step_size=', num2str(random_step_size)];setInterpoAngle = [' --interpo_angle=', num2str(random_interpo_angle)];
setFaThreshold = [' --fa_threshold=', num2str(random_fa_threshold)];
setSmoothing = [' --smoothing=', num2str(random_smoothing)];
setMinLength = [' --min_length=', num2str(random_min_length)];
setMaxLength = [' --max_length=', num2str(random_max_length)];

strStepSize = num2str(random_step_size);
disp(strStepSize);
strInterpoAngle = num2str(random_interpo_angle);
disp(strInterpoAngle);
strFaThreshold = num2str(random_fa_threshold);
disp(strFaThreshold);
strSmoothing = num2str(random_smoothing);
disp(strSmoothing);
strMinLength = num2str(random_min_length);
disp(strMinLength);
strMaxLength = num2str(random_max_length);
disp(strMaxLength);

trkNumber = int2str(i);

commandString = ['. ~/code/scripts/fullOptions_fib2trk.sh ', fileName, ' ', trkNumber, ' ', fiberCount, ' ', strStepSize,' ', strInterpoAngle,' ', strFaThreshold,' ', strSmoothing,' ', strMinLength,' ', strMaxLength];
logCaommndString = ['echo "', commandString, '" >> log', trkNumber];


system(commandString);
system('sleep 3');


end

save('parameterVectors.mat');

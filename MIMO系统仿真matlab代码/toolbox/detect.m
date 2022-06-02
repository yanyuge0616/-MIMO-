function varargout = detect(sig_down,dlt,slt,ch_coefs,varargin)

%DETECT Multidimensional data detector.
%   D_E = DETECT(S,DLT,SLT,ALPHA) performs the maximum likelihood
%   sequence estimation (MLSE) i.e. Viterbi algorithm on the received
%   signal and returns the data estimations. The look-up tables DLT and
%   SLT are used together with the external function BRMET which is
%   called during the computation to evaluate branch metric ALPHA
%   includes a channel complex path fadings.
%
%   [DATA_EST,STATE_EST] = DETECT(...) also returns a matrix including
%   the track with most probable path in the code trellis. This matrix is
%   required when the decoding process suppose to be displayed with
%   DISPTRELL function. 
%
%   [D_E,S_E] = DETECT(...,'PropertyName',PropertyValue,...)
% 
%   Detect Property List
% 
%   Echo           'on' | {'off'}
%
%   See also BRMET, DISPTRELL, MFILTER.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

global ECHO TIMING

name = 'DETECT';
[idt,tag] = iecho(name);

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Echo',opts(:,1));

% Echo
if ~isempty(ord1) % first check whether local option exists
	value1 = opts{ord1,2};
	switch value1
	case 'on'
		ech = 1;
	case 'off'
		ech = 0;
	otherwise
		disp(' ');
		disp([tag,'Invalid option for Echo property.']);
		disp([idt,'Possible values are ''on''|{''off''}.']);
		disp(' ');
		ech = 0;
	end
else
	if ~isempty(ECHO) % than check whether global option exists
		switch ECHO
		case 'on'
			ech = 1;
		case 'off'
			ech = 0;
		otherwise
			disp(' ');
			disp([tag,'Invalid option for Echo property.']);
			disp([idt,'Possible values are ''on''|{''off''}.']);
			disp(' ');
			ech = 0;
		end
	else % if there are no settings use the defaults
		ech = 0; % default value
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech
	disp(' ');
	disp([tag,'Performing data detection. This may take a while.']);
	disp([idt,'Please wait...']);
end

[step_final,space_dim,frames] = size(sig_down);
[s,md,foo] = size(dlt);
load qam16.txt;

if ~TIMING % disable timing when running performance measurement
  tic;
end

for k = 1:frames
	% running multi-dimensional Viterbi algorithm
	% make all starting paths unprobable except for the correct one
	metric(1,2:s) = realmax;

	for l = 1:step_final
		for j = 1:s % current j
		% finding all previous states s_pre leads to current sate j
		[s_pre,foo] = find(slt == j);

		% determining a pair position relevant to the state j
		% {1,2,3,4,5,6,7,8} -> {1,2,3,4,1,2,3,4}
		pos = mod(j - 1,md) + 1;

		% picking-up the pairs corresponding to each of s_pre states
		data_test = dlt(s_pre,pos,:);
		data_test = reshape(data_test,[md space_dim]);

		% mapping pairs to appropriate constellation
		if md == 16 % 16QAM
			for r = 1:space_dim
				k1(:,r) = qam16(data_test(:,r) + 1,1);
				k2(:,r) = qam16(data_test(:,r) + 1,2);
			end

			q_test = (2 * k1 - md - 1) - i * (2 * k2 - md - 1);

		else % 4,8PSK
			expr = i * 2 * pi / md;
			q_test = exp(expr * data_test);
		end

		% evaluating branch metric
		metric_d = brmet(sig_down(l,:,k),q_test,ch_coefs(:,:,k));

		% adds the data_test metrices to the previous states
		metric_md = metric(l,s_pre)' + metric_d;

		% choosing a metric with lowest accumulated value
		[metric_min,metric_pos] = min(metric_md);

		% and storing it's value to the matrix of metrices
		metric(l + 1,j) = metric_min;

		% creates a states matrix of s_pre (with lowest metric)
		vit_state(l + 1,j) = s_pre(metric_pos);

		% creates a matrix of appropriate data_test
		vit_data(l + 1,j) = pos - 1;
		end
	end

	% finding the best path at the trellis end
	[foo,state_best] = min(metric(end,:));
	state_est(step_final + 1) = state_best;

	% back tracking
	for l = step_final:-1:1
		state_est(l) = vit_state(l + 1,state_est(l + 1));
		data_est(l,:,k) = vit_data(l + 1,state_est(l + 1));
	end
end

if ~TIMING
  totaltime = toc;
else
  totaltime = 0;
end

varargout = {data_est,state_est};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech
	hour = round(totaltime / 3600);
	mins = round(totaltime / 60);
	secs = mod(totaltime,60);
	
  str1 = num2str(frames * step_final * s);
	str2 = sprintf('%1d',hour);
	str3 = sprintf('%1d',mins);
	str4 = sprintf('%1.1f',secs);
	
	disp([idt,'Total decoding complexity -> ',str1,' steps.']);
	disp([idt,'Total elapsed time -> ',str2,' hrs, ',str3,' min, ',str4,...
        ' sec.']);
	disp(' ');
end

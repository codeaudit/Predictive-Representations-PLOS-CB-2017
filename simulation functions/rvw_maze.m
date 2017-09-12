function r2 = rvw_maze(nruns,param)

%nruns = 1;
ntrials = 80;

nstepbytrial = zeros(nruns,ntrials,2);

% weight_learning (1) vs reward learning (0)
for wl = 0:1
	for t = 1:nruns

	[locations, magnitude, wallloc] = makemaze2();
	game = makegame2(locations,magnitude,wallloc);

	% make model
	if wl == 1
		model = model_VsrT;
	else 
		model = model_Vsr_r;
	end

	model = model.init(model,game,param);

	% increase R
	game.Rsa(401) = 10;

	% let it loose
	yx_to_state = reshape(1:100,10,10);	maxstep = 2000;

	% new reval
	nsteps = zeros(ntrials,1);
	for tr = 1:ntrials
		ind = 1;
		game.current_state = game.start_state;
		model.s = game.start_state;

		model.a = 0;
		model.s_prime = 0;
		model.a_prime = 0;
		model.r = 0;
		step = 0;
		while and(game.current_state <= 100, step < maxstep)
			if tr == 1
				%if ind > 1
					%modelhist(tr).inst(ind-1) = model;
					%gamehist(tr).inst(ind-1) = game;
				%end
					[game,model] = gamestep2(game,model,0);
					ind = ind+1;
			else
				%if ind > 1
				%	modelhist(tr).inst(ind-1) = model;
				%	gamehist(tr).inst(ind-1) = game;
				%end

				[game,model] = gamestep2(game,model,0);
				ind = ind+1;
			end
			step = step+1;
		end
		nsteps(tr) = step;
	end
	nstepbytrial(t,:,wl+1) = nsteps;
	end
end

r2.nstepbytrial = nstepbytrial;

%figure(1)
%hold on
%plot(median(nstepbytrial(:,:,1),1))
%plot(median(nstepbytrial(:,:,2),1))
%legend('reward','weights')
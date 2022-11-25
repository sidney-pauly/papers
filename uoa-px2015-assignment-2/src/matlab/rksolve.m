function [tvec, xvec] = rksolve(f, t0, tf, x0, dt)
    % f:   function of x and t returning the derivative dx/dt
    % t0, tf:   initial and final times for the simulation
    % x0:   value of x at the initial time t0
    % dt:   time step

    % Solve  
    % set initial conditions
    x = x0;
    t = t0;

    % Calculate how many timesteps there will be
    len = floor((tf - t0)/dt);

    % Get the lenght of the x vector to create an approprialy shaped array
    xlen = length(x0);
    
    % Preallocate the resulting matrix, with one entry per timestep
    % and appropriatly sized vectors for x
    tvec = zeros(1, len);
    xvec = zeros(xlen, len);

    tvec(1, 1) = t0;
    xvec(1:xlen, 1) = x0;

    i = 2;
    
    while t < tf

        % Equation
        k1 = f(x, t);
        k2 = f(x + (0.5 * k1 * dt), t + 0.5*dt);
        k3 = f(x + (0.5 * k2 * dt), t + 0.5*dt);
        k4 = f(x + (      k3 * dt), t +     dt);

        delta = dt*(1/6)*(k1+2*k2+2*k3+k4);
        x = x + delta;
        t = t + dt;
        
        % now add the x and t values to the
        % output vectors
        xvec(1:xlen, i) = x;
        tvec(i) = t;

        i = i + 1;
    end 

   

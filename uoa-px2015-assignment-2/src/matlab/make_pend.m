function result_fx = make_pend(g, l)
    % g: gravity
    % l: length of the pendulum
    % Make pend creates a new instance of
    % the pend function with the provided
    % arguments for g and l

    result_fx = @pend;

    function y = pend(x, t)
        % x is a vector , and so is y

        % now we name the components of x
        % so that their meaning is clear
        theta = x(1);   % the 1st comp. of x is theta
        v = x(2);       % the 2nd comp. of x is v

        % now finally we calculate the rhs of
        % the diff. equations, and return those
        % as a row vector
        % IMPORTANT: This was changed so my own rksolve method works with this
        % otherwise the vectors rotate by 90 every trial, which is not desirable
        y = [v, -(g/l)*sin(theta)];
    end
end
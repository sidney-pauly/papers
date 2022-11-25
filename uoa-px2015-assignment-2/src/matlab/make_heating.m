function result_fx = make_heating(alpha, c, t_out)
    % alpha: Scaling constant
    % c: heating constant
    % t_out: the t_out method to be used
    % Make pend creates a new instance of
    % the Tout function with the provided
    % arguments for alpha, c and t_out

    result_fx = @heating;

    function y = heating(x, t)
        % x and y are decimal numbers

        t_in = x; % Reassign x to t_in for clarity
        
        y = -alpha * (t_in - t_out(x, t)) + c;
    end
end
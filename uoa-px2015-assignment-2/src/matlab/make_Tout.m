function result_fx = make_Tout(tmin, tmax)
    % tmin, tmax: min and max temperature
    % make_TOut creates a new instance of
    % the Tout function with the provided
    % arguments for tmin and tmx

    % Assign the resoulting Tout method as a return value
    result_fx = @Tout;

    % Define the method to be returned
    function y = Tout(x, t)
        % x and y are decimal numbers
        
        y = tmin + ((tmax-tmin)/2)*(1 + cos(2 * pi * sin(pi * t / 2)^2 ));
    end
end
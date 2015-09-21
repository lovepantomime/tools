% I want to fit y = y_0 tanh(x/X)
function [y0, X] = gauss_fit(x, y, plot_flag, test)

    if ~exist('test', 'var'), test = 0; end
    if ~exist('plot_flag', 'var'), plot_flag = 0; end

    if nargin == 0
        disp('Running test')
        test = 1;
    end

    if test
        test_fit();
        return;
    end

    initGuess(1) = max(y);
    initGuess(2) = max(x(:));
    initGuess(3) = 0;
    opts = optimset('MaxFunEvals',1e7);
    [fit2,~,exitflag] = fminsearch(@(fit) fiterror(fit,x,y), ...
                                   initGuess,opts);

    y0 = fit2(1);
    X = abs(fit2(2)); % sometimes returns -ve for some reason

    if plot_flag
        figure;
        plot(x,y,'k*'); hold all
        plot(x, y0*exp(-(x/X).^2));
        %        linex([1 2 3]*X);
    end
end

function [E] = fiterror(fit,x,y)
% x = (T0,H,a)
    y0 = fit(1); X = fit(2);

    E = sum((y - y0 .* exp(-(x/X).^2)).^2);
end

function [] = test_fit()
    x = [0:0.05:24];
    X = 12;
    y0 = 2;
    y = y0 * exp(-(x/X).^2); % + y0/100 * rand(size(x));

    [yy,xx] = gauss_fit(x,y,1);

    disp(['y0 = ' num2str(yy) ' | Original = ' num2str(y0)]);
    disp(['X = ' num2str(xx) ' | Original = ' num2str(X)]);
end
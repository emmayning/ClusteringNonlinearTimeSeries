

function dRdt = rossler_system(t,y,a,b,c,overall_noise)

    x0 = y(1);
    y0 = y(2);
    z0 = y(3);

    % Define Rossler equations
    dxdt = -y0-z0+overall_noise(1);
    dydt = x0+a*y0+overall_noise(2);
    dzdt = b+z0*(x0-c)+overall_noise(3);

    dRdt = [dxdt;dydt;dzdt];


end
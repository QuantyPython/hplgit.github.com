from numpy import *
from matplotlib.pyplot import *
import sys

def solver(I, a, T, dt, theta):
    """Solve u'=-a*u, u(0)=I, for t in (0,T] with steps of dt."""
    dt = float(dt)            # avoid integer division
    Nt = int(round(T/dt))     # no of time intervals
    T = Nt*dt                 # adjust T to fit time step dt
    u = zeros(Nt+1)           # array of u[n] values
    t = linspace(0, T, Nt+1)  # time mesh

    u[0] = I                  # assign initial condition
    for n in range(0, Nt):    # n=0,1,...,Nt-1
        u[n+1] = (1 - (1-theta)*a*dt)/(1 + theta*dt*a)*u[n]
    return u, t

def u_exact(t, I, a):
    return I*exp(-a*t)

def explore(I, a, T, dt, theta=0.5):
    """
    Run a case with the solver, compute error measure,
    and plot the numerical and exact solutions (if makeplot=True).
    """
    u, t = solver(I, a, T, dt, theta)    # Numerical solution
    u_e = u_exact(t, I, a)
    e = u_e - u
    E = sqrt(dt*sum(e**2))

    figure()                         # create new plot
    t_e = linspace(0, T, 1001)       # very fine mesh for u_e
    u_e = u_exact(t_e, I, a)
    plot(t,   u,   'r--o')           # dashed red line with circles
    plot(t_e, u_e, 'b-')             # blue line for u_e
    legend(['numerical', 'exact'])
    xlabel('t')
    ylabel('u')
    title('Method: theta-rule, theta=%g, dt=%g' % (theta, dt))
    theta2name = {0: 'FE', 1: 'BE', 0.5: 'CN'}
    savefig('%s_%g.png' % (theta2name[theta], dt), dpi=150)
    savefig('%s_%g.pdf' % (theta2name[theta], dt))
    #show()  # run in batch
    return E

def define_command_line_options():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--I', '--initial_condition', type=float,
                        default=1.0, help='initial condition, u(0)',
                        metavar='I')
    parser.add_argument('--a', type=float,
                        default=1.0, help='coefficient in ODE',
                        metavar='a')
    parser.add_argument('--T', '--stop_time', type=float,
                        default=1.0, help='end time of simulation',
                        metavar='T')
    parser.add_argument('--dt', '--time_step_values', type=float,
                        default=[1.0], help='time step values',
                        metavar='dt', nargs='+', dest='dt_values')
    return parser

def read_command_line():
    parser = define_command_line_options()
    args = parser.parse_args()
    return args.I, args.a, args.T, args.dt_values

def main():
    """Conduct experiments with theta and dt values."""
    I, a, T, dt_values = read_command_line()
    for theta in 0, 0.5, 1:
        for dt in dt_values:
            E = explore(I, a, T, dt, theta)
            print '%3.1f %6.2f: %12.3E' % (theta, dt, E)

if __name__ == '__main__':
    main()

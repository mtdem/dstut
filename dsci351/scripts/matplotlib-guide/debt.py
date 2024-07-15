"""
Accompanying source to "Python Plotting With Matplotlib (Guide)"

Note: charts in "Python Plotting With Matplotlib (Guide)" were
generated using a custom matplotlibrc file.

Outputs may look different stylistically using default matplotlib styling.
"""

import matplotlib.pyplot as plt
import numpy as np

np.random.seed(444)


def main():
    rng = np.arange(50)
    rnd = np.random.randint(0, 10, size=(3, rng.size))
    yrs = 1950 + rng

    fig, ax = plt.subplots(figsize=(5, 3))
    ax.stackplot(yrs, rng + rnd, labels=['Eastasia', 'Eurasia', 'Oceania'])
    ax.set_title('Combined debt growth over time')
    ax.legend(loc='upper left')
    ax.set_ylabel('Total debt')
    ax.set_xlim(xmin=yrs[0], xmax=yrs[-1])
    fig.tight_layout()


if __name__ == '__main__':
    plt.ioff()
    main()
    plt.show()

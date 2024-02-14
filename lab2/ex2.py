# Jakub Musiał 268442

import matplotlib.pyplot as plt
import numpy as np
import argparse


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("-d", "--display", action="store_true")
    parser.add_argument("-s", "--save", type=str, default=None)

    opt = parser.parse_args()
    return vars(opt)


def f(x: np.float64) -> np.float64:
    return np.exp(x) * np.log(np.float64(1) + np.exp(-x))


def main(display: bool, save: str = None):
    print("f(x) = e^x * ln(1 + e^(-x)) plot")

    X = np.linspace(0, 50, num=1000, dtype=np.float64)
    Y = f(X)

    plt.figure(figsize=(7, 5))
    plt.plot(X, Y, )
    plt.xlabel("$x$")
    plt.ylabel("$f(x) = e^x * \ln(1 + e^{-x})$")

    if save:
        plt.savefig(save)

    if display:
        plt.show();


if __name__ == "__main__":
    main(**parse_args())

"""
Overlay RMSD from multiple .xvg files on one plot, auto-colored and labeled.

Usage:
    python overlay_rmsd.py file1.xvg file2.xvg file3.xvg file4.xvg
"""

import sys
import os
import numpy as np
import matplotlib.pyplot as plt


def read_xvg(filename):
    data = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith(('#', '@')) or not line:
                continue
            data.append([float(x) for x in line.split()])
    return np.array(data)


def main():
    files = sys.argv[1:]
    if not files:
        print("Usage: python overlay_rmsd.py file1.xvg file2.xvg ...")
        return

    colors = ['#c0392b', '#2b6cb0', '#27ae60', '#8e44ad', '#e67e22', '#16a085']

    fig, ax = plt.subplots(figsize=(9, 5))

    for i, f in enumerate(files):
        data = read_xvg(f)
        time_ns = data[:, 0]
        rmsd_ang = data[:, 1] * 10  # nm -> Angstrom
        label = os.path.splitext(os.path.basename(f))[0]
        ax.plot(time_ns, rmsd_ang, label=label, color=colors[i % len(colors)], linewidth=1.2)

    ax.set_xlabel('Time (ns)', fontsize=12)
    ax.set_ylabel('RMSD (Å)', fontsize=12)
    ax.set_title('RMSD Overlay — All Conditions', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(alpha=0.3)
    fig.tight_layout()

    outpath = 'rmsd_overlay_all.png'
    fig.savefig(outpath, dpi=300)
    plt.show()
    print(f"Saved: {outpath}")


if __name__ == '__main__':
    main()

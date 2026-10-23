"""
Overlay RMSD from multiple .xvg files on one plot, truncated to the first 200 ns.
Auto-colored, labeled, with small vertical offsets between traces so
overlapping lines stay readable.

Usage:
    python overlay_rmsd.py file1.xvg file2.xvg file3.xvg file4.xvg
"""

import sys
import os
import numpy as np
import matplotlib.pyplot as plt

TIME_LIMIT_NS = 200
Y_OFFSET_STEP = 2.0   # Å offset applied between successive traces; set to 0 to disable


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

    fig, ax = plt.subplots(figsize=(9, 6.5))

    for i, f in enumerate(files):
        data = read_xvg(f)
        time_ns = data[:, 0]
        rmsd_ang = data[:, 1] * 10  # nm -> Angstrom

        mask = time_ns <= TIME_LIMIT_NS
        time_ns = time_ns[mask]
        rmsd_ang = rmsd_ang[mask]

        if len(time_ns) == 0:
            print(f"{f}: no data within {TIME_LIMIT_NS} ns, skipping")
            continue

        offset = i * Y_OFFSET_STEP
        label = os.path.splitext(os.path.basename(f))[0]
        if Y_OFFSET_STEP > 0:
            label += f' (+{offset:.0f} Å)'

        ax.plot(time_ns, rmsd_ang + offset, label=label,
                color=colors[i % len(colors)], linewidth=1.2)

    ax.set_xlabel('Time (ns)', fontsize=12)
    ax.set_ylabel('RMSD (Å, offset for clarity)' if Y_OFFSET_STEP > 0 else 'RMSD (Å)', fontsize=12)
    ax.set_title(f'RMSD Overlay — All Conditions (0–{TIME_LIMIT_NS} ns)', fontsize=13)
    ax.set_xlim(0, TIME_LIMIT_NS)
    ax.legend(fontsize=10)
    ax.grid(alpha=0.3)
    fig.tight_layout()

    outpath = 'rmsd_overlay_all.png'
    fig.savefig(outpath, dpi=300)
    plt.show()
    print(f"Saved: {outpath}")


if __name__ == '__main__':
    main()

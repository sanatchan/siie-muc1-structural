"""
Plot RMSD for every .xvg file in a folder.
Each .xvg gets its own PNG, named after the .xvg file.

Usage:
    python plot_all_rmsd.py            # looks in current directory
    python plot_all_rmsd.py /path/dir  # looks in given directory
"""

import sys
import glob
import os
import numpy as np
import matplotlib.pyplot as plt


def read_xvg(filename):
    """Read a GROMACS .xvg file, skipping comment/header lines."""
    data = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith(('#', '@')) or not line:
                continue
            data.append([float(x) for x in line.split()])
    return np.array(data)


def plot_xvg(filepath, outdir):
    data = read_xvg(filepath)
    time_ns = data[:, 0]
    rmsd_ang = data[:, 1] * 10  # nm -> Angstrom

    base = os.path.splitext(os.path.basename(filepath))[0]  # e.g. rmsd_sial_cal

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(time_ns, rmsd_ang, linewidth=1.2, color='#2b6cb0')
    ax.set_xlabel('Time (ns)', fontsize=12)
    ax.set_ylabel('RMSD (Å)', fontsize=12)
    ax.set_title(base, fontsize=13)
    ax.grid(alpha=0.3)
    fig.tight_layout()

    outpath = os.path.join(outdir, f'{base}.png')
    fig.savefig(outpath, dpi=300)
    plt.close(fig)

    print(f"{base}: {len(time_ns)} frames, {time_ns[0]:.2f}-{time_ns[-1]:.2f} ns, "
          f"mean {rmsd_ang.mean():.3f} Å, max {rmsd_ang.max():.3f} Å -> {outpath}")


def main():
    indir = sys.argv[1] if len(sys.argv) > 1 else '.'
    outdir = sys.argv[2] if len(sys.argv) > 2 else indir

    xvg_files = sorted(glob.glob(os.path.join(indir, '*.xvg')))
    if not xvg_files:
        print(f"No .xvg files found in {indir}")
        return

    for f in xvg_files:
        plot_xvg(f, outdir)


if __name__ == '__main__':
    main()

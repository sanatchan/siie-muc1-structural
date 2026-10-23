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

# --- File paths: edit these to match your actual files ---
cal_file = '../early_desial/rmsd_desial_cal.xvg'
nocal_file = '../early_desial/rmsd_desial_nocal.xvg'

# Load data
cal_data = read_xvg(cal_file)
nocal_data = read_xvg(nocal_file)

cal_time = cal_data[:, 0]
cal_rmsd = cal_data[:, 1] * 10   # nm -> Angstrom

nocal_time = nocal_data[:, 0]
nocal_rmsd = nocal_data[:, 1] * 10

# Plot
fig, ax = plt.subplots(figsize=(9, 5))
ax.plot(cal_time, cal_rmsd, label='With Calcium', color='#c0392b', linewidth=1.2)
ax.plot(nocal_time, nocal_rmsd, label='Without Calcium', color='#2b6cb0', linewidth=1.2)

ax.set_xlabel('Time (ns)', fontsize=12)
ax.set_ylabel('RMSD (Å)', fontsize=12)
ax.set_title('Backbone RMSD — Calcium vs No Calcium', fontsize=13)
ax.legend(fontsize=11)
ax.grid(alpha=0.3)
fig.tight_layout()
fig.savefig('rmsd_cal_vs_nocal.png', dpi=300)
plt.show()

print(f"With Calcium:    {len(cal_time)} frames, {cal_time[0]:.2f}-{cal_time[-1]:.2f} ns, mean {cal_rmsd.mean():.3f} Å")
print(f"Without Calcium: {len(nocal_time)} frames, {nocal_time[0]:.2f}-{nocal_time[-1]:.2f} ns, mean {nocal_rmsd.mean():.3f} Å")

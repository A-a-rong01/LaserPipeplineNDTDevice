import numpy as np
import matplotlib.pyplot as plt

# Constants
R = 75  # Ohms
L = 7.96e-9  # Henries
C = 3.18e-12  # Farads
Z0 = 50  # Characteristic impedance of transmission line (Ohms)
epsilon_r = 2.25  # Relative permittivity of dielectric
c = 3e8  # Speed of light (m/s)
vp = c / np.sqrt(epsilon_r)  # Phase velocity (m/s)

# Resonant frequency of RLC circuit
fr = 1 / (2 * np.pi * np.sqrt(L * C))

# Frequency range (1 MHz to 10 GHz)
f = np.logspace(6, 10, 1000)
omega = 2 * np.pi * f

# Load impedance Z_L
Z_L = R + 1j * (omega * L - 1 / (omega * C))

# Line length l = lambda/2 at resonance
lambda_r = vp / fr
l = lambda_r / 2

# β = 2πf / vp
beta = 2 * np.pi * f / vp

# Input impedance of lossless line
tan_bl = np.tan(beta * l)
Z_in = Z0 * (Z_L + 1j * Z0 * tan_bl) / (Z0 + 1j * Z_L * tan_bl)

# Reflection coefficient at input
Gamma_in = (Z_in - Z0) / (Z_in + Z0)

# Magnitude and phase of reflection coefficient
Gamma_mag_db = 20 * np.log10(np.abs(Gamma_in))
Gamma_phase_deg = np.angle(Gamma_in, deg=True)

# Bode Plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 7), sharex=True)

# Magnitude plot
ax1.semilogx(f, Gamma_mag_db, 'b')
ax1.set_title('Bode Plot of Input Reflection Coefficient Γin')
ax1.set_ylabel('Magnitude |Γin| (dB)')
ax1.grid(which='both', linestyle='--', linewidth=0.5)

# Phase plot
ax2.semilogx(f, Gamma_phase_deg, 'r')
ax2.set_ylabel('Phase ∠Γin (degrees)')
ax2.set_xlabel('Frequency (Hz)')
ax2.grid(which='both', linestyle='--', linewidth=0.5)

plt.tight_layout()
plt.show()

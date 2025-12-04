import math
import matplotlib as plt
import numpy as np


## The following is code for question 2
conductivity = 5.8*10**7
permOfFree = 4*math.pi*10**(-7)
def skinDepth(freq):
    answer = 1/math.sqrt(math.pi*freq*(permOfFree)*(conductivity))
    return answer

freq = [100*10**3,10*10**6,100*10**6,300*10**6,3*10**9]

for feqVal in freq:
    skinDepthNum =[]
    skinDepthNum.append(skinDepth(feqVal))
    print(skinDepthNum*10**6) ##Displays the values in micrometers


# The following is code for question 3
frequncyRange = np.logspace(7, 10, 1000)  # Frequencies from 10 MHz to 10 GHz


# Labels and title
plt.title("Capacitive and Inductive Reactance vs Frequency", fontsize=14)
plt.xlabel("Frequency (Hz)", fontsize=12)
plt.ylabel("Reactance (Ω)", fontsize=12)
plt.legend()
plt.grid(True, which="both", ls="--")

# Show the plot
plt.show()


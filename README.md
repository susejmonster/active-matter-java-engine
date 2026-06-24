### **Project Name:** `active-matter-java-engine`

### **Project Overview**
This repository hosts a high-performance **2D active matter simulation engine** developed entirely from scratch in **Java**. The project bridges foundational theories of collective motion with advanced hydrodynamic research by implementing the **1995 Vicsek model** and the **2022 Bera et al. explicit solvent framework**. 

By bypassing high-level libraries, this "from-scratch" engine provides full control over the particle dynamics, collision logic, and fluid interactions, allowing for a deep exploration of how **spontaneous symmetry breaking** and **swimmer flows** drive the emergence of ordered motion.

---

### **Core Physics & Features**
*   **Vicsek Alignment Rule:** Particles are driven with a constant absolute velocity and assume the average direction of motion of their neighbors with added noise ($g$). This results in a **kinetic phase transition** from a disordered state to finite net transport.
*   **Passive Interaction Modes:**
    *   **Passive Attractive (PA):** Uses a **Force-Shifted Lennard-Jones (LJ)** potential with an attractive tail ($r_c = 2.5\sigma$) to facilitate stable, disconnected clusters.
    *   **Passive Repulsive (PR):** Implements the **Weeks-Chandler-Andersen (WCA)** potential for purely steric repulsion ($r_c = 2^{1/6}\sigma$), modeling "soft" hard-spheres.
*   **Explicit Fluid Hydrodynamics:** 
    *   Implements **Multiparticle Collision Dynamics (MPCD)** logic to conserve mass, momentum, and energy.
    *   **Random Grid Shifting:** A crucial technique implemented to restore **Galilean invariance** in the small mean free path limit, allowing for the observation of complex **vortex formations** in the fluid.

---

### **Technical Implementation**
*   **Engine:** Developed in **Pure Java** with no external scientific packages; all vector mathematics and potential energy calculations are performed through hand-coded algorithms.
*   **Optimization:** Utilizes **Bounding Box principles** derived from game physics for efficient collision detection and neighbor searching, ensuring high performance for systems of ~13,000 particles.
*   **Real-Time Validation Module:** An "on-the-go" analysis suite that calculates:
    *   **Velocity Correlation ($C_{vv}$):** Quantifies the directional alignment within clusters, validating the ordered transport mediated by hydrodynamics.
    *   **Cluster Mass Analysis ($M$):** Tracks growth laws ($M \sim t^\beta$), identifying the transition from diffusive coalescence to **ballistic aggregation (BA)**.

---

### **Key Scientific Findings Captured**
*   **Ballistic Aggregation:** The engine demonstrates that activity and hydrodynamics fundamentally alter growth laws, leading to cluster motion that is significantly faster than standard passive diffusion.
*   **Ordered Transport:** By contrasting scenarios with and without fluid, the simulation validates that hydrodynamics are essential for maintaining stable, ordered motion in disconnected morphologies.

---

### **References**
1.  **Vicsek et al. (1995):** *Novel Type of Phase Transition in a System of Self-Driven Particles*.
2.  **Bera et al. (2022):** *Active particles in explicit solvent: Dynamics of clustering for alignment interaction*.

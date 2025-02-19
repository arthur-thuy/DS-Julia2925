# Modeling antibiotics treatment

**tags:** *antibiotics, ordinary differential equations, parameter estimation*

## Abstract

The discovery of antibiotics is one of the greatest medical advancements of the 20th century. In this project, we use a simple ordinary differential equation (ODE) system to model the effect of antibiotic dosing on a system containing susceptible and resistant bacteria. Bacteria grow with a simple completion model (susceptible bacteria grow faster due to the fitness cost associated with being resistant). Antibiotics can be added to the system. Higher concentrations kill bacteria more effectively, though antibiotics are quickly removed from the system. When choosing doses and dosing time, can we maximally reduce bacterial infection while limiting our total use?

## Background

In this project, we will study the regime of treating a bacterial infection with antibiotics.

We assume there is an infection with susceptible (S) and resistant (R) bacteria. Both bacteria have a growth rate dependent on their total density:

$$
\mu=r\left(1+\frac{S+R}{K}\right)
$$

For resistant bacteria, there is a fitness cost $a$, meaning their growth rate is only $\mu(1-a)$.

Both bacteria die naturally, given by a first-order rate of $\theta$.

Antibiotics can also be present in the system at a concentration $C$. It decays at a constant rate $g$. Antibiotics kill bacteria with a dose-dependent rate of $A_S(C)$ and $A_R(C)$, respectively. For  $A_S(C)$ and $A_R(C)$ you can use these equations. See the paper cited below for the derivation.

```julia
Aₛ(c) = (2.5 + 2.1) * (c/16)^4 / ((c/16)^4 - (-2.1/2.5))

Aᵣ(c) = (2.5 + 2.1) * (c/32)^4 / ((c/32)^4 - (-2.1/2.5))
```

![ODE system antibiotics](antibiotics_ode.png)

The paper used the following objective function:

![Objective function antibiotics](antibiotics_obj.png)

## Assignments

1. Implement the antibiotics dosing model using Catalyst. **Don’t implement the ODEs directly, instead, add all processes as reactions.** Ignore HGT. The part “antibiotic dosing” does not need to be implemented. This can be addressed by the solver. 
2. Convert your system into an ODE system. 
3. Perform a simulation! Start with the following initial conditions: `u₀map = [:S=>500, :R=>100, :C=>50.0]`. Use the paper to get some realistic parameter values. Simulate for 35 days and make a plot.
4. Use `DiscreteProblem` and `JumpProblem` for discrete versions.
5. Now use `PresetTimeCallback` to give antibiotics dosing on set time points. This requires making a function to give the solver’s callback to have the variable C increase at set times (your dosing times) with a specific value (i.e. the dosis of antibiotics you add). Make a bunch of plots with different schemes. You can use DrWatson’s functionality to save these figures systematically.
6. Make a function that gives different dosing schemes and concentrations. Either use random sampling or optimization to minimize the bacterial load. Make a Pareto plot of the bacterial load vs total antibiotics used in your treatments.
7. Perform a sensitivity analysis of a parameter of your choice.

## Resources

This work is based on the paper “*[Optimising Antibiotic Usage to Treat Bacterial Infections](https://www.nature.com/articles/srep37853)*”, which explains the model and lists sensible values for the parameters.


Julia packages:

- [Catalyst.jl](https://docs.sciml.ai/Catalyst/stable/introduction_to_catalyst/introduction_to_catalyst/): a modeling library for (bio)chemical reactions.
    - you might look at jump equations and stochastical chemical kinetics to account for the discrete nature of the bacteria
    - check the tab “Constraint Equations and Events” for event handling, i.e. dosing antibiotics at a set time
- Catalyst mainly uses DifferentialEquations.jl, you might check that out!
- For optimizing the dosis, you can use [Optimization.jl](https://github.com/SciML/Optimization.jl) or try a couple of thousand random scenarios.
- [SciMLSensitivity](https://docs.sciml.ai/SciMLSensitivity/stable/) can be used for a sensitivity analysis
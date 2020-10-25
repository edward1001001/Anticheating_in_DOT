# Table 1(a) in the [science of learning]() paper

The normalized students' competences ``Y`` are in ``Yo.mat``. The Gaussian noises (mu = 0, sigma = 0.05) applied on competences are in ``NoiseMat.mat``.
The random colluding matrix ``P`` is generated with python codes in the ``InstancesGenCode`` folder.

Run the ``Table1_a.m`` with ``MATLAB``, the statistic results of 500 instances in terms of different metrics will be stored in ``Table1_a.txt``, e.g.,

*Noisy Y and Heuristic P
*None & 0.19957 (0.00591) & 0.30837 (0.00708) & 0.73524 (0.02107)
* GAS & 0.00603 (0.00134) & 0.06457 (0.00824) & 0.20870 (0.03091)
*Opti & 0.00457 (0.00115) & 0.06275 (0.00775) & 0.20404 (0.02941)

*Noisy Y and Random P
*None & 0.14884 (0.00450) & 0.30837 (0.00708) & 0.73524 (0.02107)
* GAS & 0.00376 (0.00091) & 0.06457 (0.00824) & 0.20870 (0.03091)
*Opti & 0.00190 (0.00052) & 0.06275 (0.00775) & 0.20404 (0.02941)

*Accurate Y and Random P
*None & 0.14497 (0.00139) & 0.30901 (0.00000) & 0.75000 (0.00000)
* GAS & 0.00169 (0.00013) & 0.01160 (0.00000) & 0.03454 (0.00000)
*Opti & 0.00044 (0.00005) & 0.00908 (0.00000) & 0.06878 (0.00000)

In the code ``Table1_a.m``, a constant seed (line 4) was used to fix the results. If any modifications made to the code, please comment line 83 
```
NoiseMat = normrnd(0,0.05,[Ncases,length(Yo)]);
```
and uncomment line 36 
```
% load('NoiseMat.mat','NoiseMat')
```
to keep the applied noises unchanged.

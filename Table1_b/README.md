# Table 1(b) in the [science of learning]() paper

Running the code ``performanceDatSim.m`` with ``MATLAB`` will generate 500 optimized DOT instances which will be stored in the ``SimResults`` folder. Each instance will contain two structure ``setting`` storing the setting information (the number of students ``N``, the competence ``Y``, the size of question pool ``Mp``, and the number of questions in one test ``M``), and ``Results`` storing the optimized results in terms of ``g``, ``gW`` and ``gMI`` metrics information (under different level of anti-collusion: None, GAS and Opti).

The students' competences ``Y`` were randomly generated according to a Gaussian distribution (mu = 0.625, sigma = 0.125) on the support [0.25, 1]. The colluding matrix ``P`` is heuristically constructed (refer the Method section of the paper for details).

In the code ``performanceDatSim.m``, a constant seed 100 (line 4) was used to fix the results. Modifications made to the code can potentially change the final result. Besides the optimized results for each instance, the statistic results (``Rng100_trancatedY_NcaseXXX_timestamp``) of the total 500 instances are also saved, under the same folder with ``performanceDatSim.m``.

By running the ``Table1_b.m`` with ``MATLAB``, the statistic results will be stored in ``Table1_b.txt``, e.g.,
```
None & 0.16278 (0.01499) & 0.30384 (0.04153) & 0.60838 (0.06344)
 GAS & 0.00027 (0.00015) & 0.00963 (0.00137) & 0.02713 (0.00304)
Opti & 0.00007 (0.00002) & 0.00861 (0.00154) & 0.04571 (0.01802)
```
Line 3 can be changed to output the different files of statist results,
```
load('Rng100_trancatedY_Ncase500_20201024_19_55_40.mat')
```



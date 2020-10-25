# Table 1(a) in the [science of learning]() paper

The normalized students' competences are in Yo.mat. The Gaussian noises (mu = 0, sigma = 0.05) applied on competences are in NoiseMat.mat.
The random colluding matrix P is generated with python codes in the InstancesGenCode folder.

Run the Table1_a.m with MATLAB, the statistic results of 500 instances in terms of different metrics will be stored in Table1_a.txt.

In the code Table1_a.m, a constant seed was used to fix the results. If any modifications made to the code, please comment line 83 ('NoiseMat = normrnd(0,0.05,[Ncases,length(Yo)]);') and uncomment line 36 ('% load('NoiseMat.mat','NoiseMat')') to keep the applied noises unchanged.

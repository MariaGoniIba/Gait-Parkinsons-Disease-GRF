# Gait in Parkinson's Disease using ground reaction forces
The aim of this project is to classify Parkinson’s disease (PD) subjects and healthy controls (HC) based on vertical Ground Reaction Forces (vGRF) as measured by pressure sensors placed under the foot. 

## ABOUT DATASET
### Online Repository Link
[Link to data repository](https://physionet.org/content/gaitpdb/1.0.0/)

### Description of the data
Data contains measures of gait from patients with idiopathic PD and healthy controls (HC). Gait is measured by vertical ground reaction force using 8 sensors located under both feet. Each line contains 19 columns:
* Column 1: Time (in seconds)
* Column 2-9: Vertical ground reaction force (vGRF, in Newton) on each of 8 sensors located under the left foot.
* Column 10-17: vGRF on each of the 8 sensors located under the right foot.
* Column 18: Total force under the left foot.
* Column 19: Total force under the right foot.

This data was originated from 3 studies, where the first 2 letters of the data file names indicate the study from which the data originated:
| ID        | Study           | no. PD  | no. HC |
| ------------- |:-------------:| :-----:| :----:|
| Ga      | Galit Yogev et al (dual tasking in PD; Eur J Neuro, 2005) | 14 | 18 |
| Ju      | Hausdorff et al (RAS in PD; Eur J Neuro, 2007)      |   29 | 26 |
| Si | Silvi Frenkel-Toledo et al (Treadmill walking in PD; Mov Disorders, 2005)      |    78 | 73 |

A walk number of 01 refers to a usual, normal walk. This is the task we will be studying. Co or Pt refers to control subject or PD subject.

## METHODOLOGY
* *MainScrip.m*: this script allows the user to choose between including one of the 3 studies in the analysis or to include them all.  
* *extract_feat.m*: this script extracts the gait cycle based on the initial and last contact moment with the floor, for each sensor and feet. Based on these values I extract the following time series:
  - Stride time: time elapsed between the first contact of a foot and the first following contact of the same foot.
  - Stance phase: period when the foot is in contact with the ground.
  - Swing phase: period during which the foot is not in contact with the ground.
  - Maximum pressure.
  - Stance ratio: as stance phase divided by stride time.
  - Swing ratio: as swing phase divided by stride time.
  - Swing-stance ratio: as swing phase divided by the stance phase. 
  - Fluctuation magnitude variability: as the difference in left and right sensor readings for each sensor.

  A total of 419 features were included in the study:
  - Mean, standard deviation and coefficient of variation for all time series for each sensor and feet.
  - Number of steps for each sensor.
  - Cadence for each sensor, as measured as number of steps per minute.
  - Weight and height.
* *M_cross_validation.m*: this function returns indices for training and testing for different CV procedures. When including all studies in the analysis, or for Silvi et al. study, I use 10 fold CV. Given the reduced number of subjects, I use 5 fold CV for Galit et al and Hausdorff et al studies.
* *RF.m*: function that runs Random Forest. It uses a nested CV procedure where the optimal number of trees is selected during the inner CV. Rf has the option to save the weights of the features with OOB {'on','off'}. 
* *RFtuning.m*: it runs a grid search to select the number of trees.
* *Performance_nrep.m*: to avoid data leakage and increase robustness of the model, we run the whole procedure n_rep = 20 times for each individual study and 100 times when including all studies. Then, we average performances reporting sensitivity, specificity, balanced accuracy, AUC, Precision, Recall and F1 Score.

The flowchart below shows the followed procedure along with the scripts names.

<p align="center">
  <img src="https://github.com/MariaGoniIba/Gait-Parkinsons-Disease-GRF/blob/main/flowchart.png"
</p>

## RESULTS
  
### Classification

| Study ID        | BalAcc (%) | Sens (%) | Spec (%) | AUC (%) |
| ------------- | -----:| -----:| -----:| -----:|
| All studies | 73.13 ± 2.83 | 75.43 ± 4.17 | 70.82 ± 4.11 | 80.87 ± 2.29 |
| Silvi Frenkel-Toledo et al  | 73.83 ± 4.15 | 75.43 ± 4.94 | 72.22 ± 4.58 | 79.69 ± 2.58 |
| Galit Yogev et al | 62.87 ± 6.96 | 47.69 ± 8.5 | 78.06 ± 7.09 | 70.96 ± 9.27 |
| Hausdorff et al | 69.64 ± 2.4 | 78.57 ± 4.63 | 60.71 ± 5.96 | 74.91 ± 3.47 |

### Predictors
Below there is a list with the 10 features with the hightest predictor importance in the classification when including all studies. The stance ratio is predominantly the most informative time series.
  
| | **Time serie** | **Statistic** | **no. sensor** | **foot**| 
| -- | :-------------: | :-----:| :-----:| :-----: |
| 1 | Stance ratio  | Standard deviation | total force | right |
| 2 | Stance ratio | Coefficient of variation | 7th | left |
| 3 | Swing ratio  | Coefficient of variation | 7th | left |
| 4 | Swing-stance ratio | Coefficient of variation | 7th | left |
| 5 | Stance ratio | Standard deviation | 4th | left |
| 6 | Stance ratio | Standard deviation | total force | right |
| 7 | Stance ratio | Standard deviation | 6th | right |
| 8 | Maximum pressure | Standard deviation | total force | right |
| 9 | Stance ratio | Standard deviation | 1st | left |
| 10 | Stance ratio | Coefficient of variation | 2nd | right |
  
## PAPERS
* [Dual tasking, gait rhythmicity, and Parkinson's disease: which aspects of gait are attention demanding?](https://pubmed.ncbi.nlm.nih.gov/16176368/)
* [Rhythmic auditory stimulation modulates gait variability in Parkinson's disease](https://pubmed.ncbi.nlm.nih.gov/17953624/)
* [Treadmill walking as an external pacemaker to improve gait rhythm and stability in Parkinson's disease](https://pubmed.ncbi.nlm.nih.gov/15929090/)
* [PhysioBank, PhysioToolkit, and PhysioNet: Components of a new research resource for complex physiologic signals](https://physionet.org/content/gaitpdb/1.0.0/)



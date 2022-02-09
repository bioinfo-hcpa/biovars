# biovars
Tool for joining all the bioinfo-hcpa's variant information retrieval APIs.


### Introduction


### Installation


### Plotting the results

BIOVARS offers plotting methods coded in R (interfaced by rpy2) for summarizing the searches results made with the package.
For using any of the plotting methods, the Plotter class needs to be initialized in an object, giving as input a BIOVARS resulting datframe and the genome version used in the searches that generated the data.

Plotter(dataframe: pd.DataFrame, genome_version: str = "hg38")
* dataframe: the pandas dataframe containing the resulting BIOVARS search.
* genome_version: either "hg38" or "hg37".
```python
from biovars import Plotter
plt = Plotter(df, "hg38")
```

For plotting the world map with the population variants count in terms of private, common and total, the method plot_world should be used.
Plotter.plot_world(saving_path: str, frequency: float = 0.01)
* saving_path: the path where the file is to be saved
* frequency: how frequent a variant have to be in the population to be counted as "present" in that population
```python
plt.plot_world("/home/user/path/", 0.01)
```

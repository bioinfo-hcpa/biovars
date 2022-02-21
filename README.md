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

_Plotter.plot_world(saving_path: str, frequency: float = 0.01)_ <br>
Plots the world map with the population variants count in terms of private, common and total.
* saving_path: the path where the file is to be saved
* frequency: how frequent a variant have to be in the population to be counted as "present" in that population
```python
plt.plot_world("/home/user/path/", 0.01)
```

_Plotter.plot_variants_grid(saving_path: str, frequency: float = 0.01)_ <br>
Plots only a grid with the population variants count in terms of private, common and total. It is the same as the plot_world, but only with the bar plots.
* saving_path: the path where the file is to be saved
* frequency: how frequent a variant have to be in the population to be counted as "present" in that population
```python
plt.plot_variants_grid("/home/user/path/", 0.01)
```

_Plotter.plot_genomic_region(saving_path: str, starting_region: int, ending_region: int, mut: bool = False, transcript_region: bool = True)_ <br>
Plots the genomic region whithin the specified start and end range (max. of 54bp) with the transcripts and where each one falls, as well as the frequency of each type of variant found in the dataframe along the specified region. This region must be contained inside the Potter dataframe.
* saving_path: the path where the file is to be saved
* starting_region: where the region of interest starts (must be present in the Plotter input dataframe)
* ending_region: where the region of interest ends (must be present in the Plotter input dataframe)
* mut: whetere the mutations are to be indicated in the plots
* transcript_region: whether the plot containing where the transcripts falls is to be generated along with the frequency plot
```python
plt.plot_genomic_region("/home/user/path/", 987027, 987068, False, True)
```

_Plotter.plot_summary(saving_directory: str, gene: str, starting_region: int, ending_region: int , frequency: float = 0.01)_ <br>
Generates an HTML file containing the above plots and a table with the Search resulting dataframe to more easily visualize this information along with the plots.
* saving_path: the path where the file is to be saved
* gene: among the genes inside the Plotter input dataframe, which one is to be used
* starting_region: where the region of interest starts (must be present in the Plotter input dataframe)
* ending_region: where the region of interest ends (must be present in the Plotter input dataframe)
* frequency: how frequent a variant have to be in the population to be counted as "present" in that population
```python
plt.plot_summary("/home/user/path/", "idua", 987027, 987068, 0.01)
```

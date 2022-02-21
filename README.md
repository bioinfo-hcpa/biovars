# biovars
Tool for joining all the bioinfo-hcpa's variant information retrieval APIs.


### Introduction


### Installation

Currently there is not a PyPI version for the APIs, so the installation needs that you clone their repository and install them as local packages.

    $ git clone https://github.com/bioinfo-hcpa/pynoma.git
    $ git clone https://github.com/bioinfo-hcpa/pyABraOM.git
    $ git clone https://github.com/bioinfo-hcpa/biovars.git
    $ pip install -e pynoma
    $ pip install -e pyABraOM
    $ pip install -e biovars
    
After that, if you want to utilize the BIOVARS Plotter class, you also need to install R (widely SO-dependent, thus not covered here) and all the packages used for building the plots.

    $ R
    > pkgs <- c("ggplot2", "ggthemes", "gridExtra", "egg", "png", "grid", "cowboy", "patchwork", "httr", "jsonlite", "xml2", "dplyr", "RColorBrewer", "stringr", "gggenes")
    > install.packages(pkgs)

### Searching for variants

The BIOVARS package can perform searches by genes, genome regions or transcripts. However, not all database sources accept the three types of searches, so a Sources object need to be created in order for this validation to occur.
Currently there are only two databases, but in the future more will be added.

The Sources class expects as parameters:
* ref_genome_version (str): the reference genome version (either "hg38" or "hg37")
* gnomad (bool): whether to search on gnomad database
* abraom (bool): whether to search on abraom database
* verbose (bool): whether to log validation messages

The Search class excpects as parameters:
* sources (biovars.Sources): the initialized Sources object
* verbose (bool): whether to log searching status messages
```python
from biovars import Sources, Search
src = Sources(ref_genome_version="hg38", gnomad=True, abraom=True)
sch = Search(src, verbose=True)
```

#### Search by genes
The gene_search method expects as parameter a list of genes (list[str]): the list of gene symbols of interest.
```python
genes = ["idua", "ace2", "brca"]
sch.gene_search(genes)
```

#### Search by regions
The region_search method expects as parameter a list of genome regions (list[str]): each item composed of "chromosome-start_region-end_region".
```python
regions = ["4-987010-1001021", "X-15561033-15602100"]
sch.region_search(regions)
```

#### Search by transcripts
The transcript_search method expects as parameter a list of transcripts (list[str]): the list of ensembl transcript ids of interest.
```python
transcripts = ["ENST00000252519", "ENST00000369985"]
sch.transcript_search(transcripts)
```

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

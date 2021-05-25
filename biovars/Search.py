import pandas as pd
import pynoma
import pyabraom

from .Sources import Sources
from .Logger import Logger


class Search:

    """
    The class responsible for actually performing the searches of interest
    using the current existing APIs.

    Each <>_search method returns either a Dataframe containing the results
    or None if no variant was found considering the provided sources and 
    search inputs.

    The resulting dataframe follows the following format:
    (...)


    Args:
        sources (Sources): a sources object containing the databases 
        of interest for the search
    """

    def __init__(self, sources:Sources, verbose=True):
        self.verbose = verbose
        self.sources = sources


    # genes: a list containing the genes of interest for the search,
    # where each gene is represented by a string informing the gene 
    # symbol
    # Example: ["IDUA", "ACE2", "BAP1"]
    def gene_search(self, genes:list):
        if self.sources.is_gene_search_valid():
            resulting_dataframes = []
            if self.sources.gnomad2:
                resulting_dataframes.append(self.pynomad_gene_search(2, genes))
            if self.sources.gnomad3:
                resulting_dataframes.append(self.pynomad_gene_search(3, genes))
            if self.sources.abraom:
                resulting_dataframes.append(self.pyabraom_gene_search(genes=genes))

            for dataframe in resulting_dataframes:
                dataframe.dropna(subset = ["rsID"], inplace=True)

            

        else:
            Logger.invalid_gene_search_sources_returning_none()
            return None


    # regions: a list containing the regions of interest for the 
    # search, where each region is represented by a string informing 
    # the chromosome, the region start position and the region end
    # position separated by hyphens
    # Example: ["4-987010-1001021", "X-15561033-15602100"]
    def region_search(self, regions:list):
        return


    # transcripts: a list containing the transcripts of interest for
    # the search, where each transcript is represented by a string
    # informing the Ensembl transcript id without the dot suffix
    # Example: ["ENST00000252519", "ENST00000369985"]
    def transcript_search(self, transcripts:list):
        return


    # Updates the sources attribute with the new interested sources
    def update_source(self, sources:Sources):
        self.sources = sources
        return



    # Methods for specific searches:
    def pynomad_gene_search(self, version:int, genes:list):
        gene_searches=[]
        for gene in genes:
            gene_searches.append(pynoma.GeneSearch(version,gene)) 
        return pynoma.batch_search(gene_searches, additional_population_info=True)


    def pyabraom_gene_search(self, genes:list, version="hg38"):
        dataframes = []
        for gene in genes:
            dataframes.append(pyabraom.Search_gene(version, gene, Variant_ID=True))
        return pd.concat(dataframes)
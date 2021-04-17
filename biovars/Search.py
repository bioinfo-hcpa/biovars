import pynoma
from biovars.Sources import Sources
#import pyabraom


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

    def __init__(self, sources:Sources):
        self.sources = sources


    # genes: a list containing the genes of interest for the search,
    # where each gene is represented by a string informing the gene 
    # symbol
    # Example: ["IDUA", "ACE2", "BAP1"]
    def gene_search(self, genes:list):
        return


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
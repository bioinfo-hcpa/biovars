class Sources:

    """
    Sources class is used to manage which variant databases the
    data must be retrieved from.

    This class will be constantly updated to go along with new API
    integrations idealized to happen in the future.

    The class mainly provides validation methods for each type of
    search, aiming to detect wheter some API has been incorrectly
    chosen. For instance, pyabraom does not support transcript 
    searches. Each validation method returns a boolean indicating
    if the search is valid for those specific chosen sources, and
    also warns the user if they are not valid AND verbose attribute 
    is set to True.

    Args:
        verbose (bool): wheter to log validation messages or hide them
        gnomad2 (bool): whether gnomAD v2.1.1 is to be used in the search
        gnomad3 (bool): whether gnomAD v3.1.1 is to be used in the search
        abraom (bool): whether ABraOM is to be used in the search
    """

    def __init__(self, verbose=True, gnomad2=True, gnomad3=True, abraom=True):
        self.verbose=verbose
        self.gnomad2=gnomad2
        self.gnomad3=gnomad3
        self.abraom=abraom

    
    def is_gene_search_valid(self):
        return
    
    def is_region_search_valid(self):
        return

    def is_transcript_search_valid(self):
        return
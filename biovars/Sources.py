from .Logger import Logger 

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
        gnomad2 (bool): whether gnomAD v2.1.1 is to be used in the search
        gnomad3 (bool): whether gnomAD v3.1.1 is to be used in the search
        abraom (bool): whether ABraOM is to be used in the search
        
        verbose (bool): wheter to log validation messages or hide them
    """

    def __init__(self, gnomad2=True, gnomad3=True, abraom=True, verbose=True):
        self.verbose=verbose

        self.gnomad2=gnomad2
        self.gnomad3=gnomad3
        self.abraom=abraom

        # List of booleans for each source
        self.sources_configuration = [gnomad2, gnomad3, abraom]

    
    def is_gene_search_valid(self):
        if any(self.sources_configuration):
            return True
        else:
            if self.verbose:
                Logger.invalid_search_all_false()
            return False
    

    def is_region_search_valid(self):
        if any(self.sources_configuration):
            return True
        else:
            if self.verbose:
                Logger.invalid_search_all_false()
            return False
        return


    def is_transcript_search_valid(self):
        if any(self.sources_configuration):
            if self.abraom:
                Logger.invalid_region_search_abraom()
                return False
            else:
                return True
        else:
            if self.verbose:
                Logger.invalid_search_all_false()
            return False
        return
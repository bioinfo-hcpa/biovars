from .Logger import Logger 


ref_genome_map = {
        "hg19": 19,
        "grch37": 19,
        "hg38": 38,
        "grch38": 38
    }

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
        ref_genome_version (string): the reference genome version. Provide either 
            'hg19' or 'hg38', or its equivalents ('GRCh37' or 'GRCh38')
        gnomad (bool): whether gnomAD database is to be used in the search
        abraom (bool): whether ABraOM is to be used in the search
        
        verbose (bool): wheter to log validation messages or hide them
    """

    def __init__(self, ref_genome_version:str, gnomad=False, abraom=False, verbose=True):
        self.verbose=verbose

        self.gnomad=gnomad
        self.abraom=abraom

        # List of booleans for each source
        self.sources_configuration = [gnomad, abraom]

        self.version = None   # Will be set to either 19 or 38
        self.init_genome_version(ref_genome_version)

    

    def init_genome_version(self, genome_version) -> str:
        if genome_version.lower() in ref_genome_map:
            self.version = ref_genome_map[genome_version.lower()]
        else:
            raise Exception("Error! Reference genome version unvailable, \
                             please choose between 'hg19' ('GRCh37') or 'hg38' ('GRCh38')")


    def validate_genome_version_with_sources(self):

        gnomad_accepted_versions = [19, 38]
        abraom_accepted_versions = [19, 38]

        unaccepted_version = Exception("Error! The provided reference genome version is \
                                        not supported by all the selected database sources!")

        if self.gnomad:
            if not (self.version in gnomad_accepted_versions):
                raise unaccepted_version
        if self.abraom:
            if not (self.version in abraom_accepted_versions):
                raise unaccepted_version

    

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
                Logger.invalid_transcript_search_abraom()
                return False
            else:
                return True
        else:
            if self.verbose:
                Logger.invalid_search_all_false()
            return False
        return
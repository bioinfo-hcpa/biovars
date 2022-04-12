import pandas as pd
import numpy as np
from copy import deepcopy
import requests
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


    def __init__(self, sources: Sources, verbose=True):
        self.verbose = verbose  # change the log level based on this argument
        self.sources = sources

        self.resulting_dataframes = {
            "gnomad": None,
            "abraom": None
        }


    # genes: a list containing the genes of interest for the search,
    # where each gene is represented by a string informing the gene 
    # symbol
    # Example: ["IDUA", "ACE2", "BAP1"]
    def gene_search(self, genes:list):
        if self.sources.is_gene_search_valid():

            if self.sources.version == 19:
                if self.sources.gnomad:
                    self.resulting_dataframes["gnomad"] = self.pynoma_gene_search(2, genes)
                if self.sources.abraom:
                    self.resulting_dataframes["abraom"] = self.pyabraom_gene_search(genes, version="hg19")

            elif self.sources.version == 38:
                if self.sources.gnomad:
                    self.resulting_dataframes["gnomad"] = self.pynoma_gene_search(3, genes)
                if self.sources.abraom:
                    self.resulting_dataframes["abraom"] = self.pyabraom_gene_search(genes, version="hg38")

            else:
                raise Exception("Error! Unaccepted reference genome version: " + str(self.sources.version))

            return self.integrate_data()
            
        else:
            Logger.invalid_gene_search_sources_returning_none()
            return None


    # regions: a list containing the regions of interest for the 
    # search, where each region is represented by a string informing 
    # the chromosome, the region start position and the region end
    # position separated by hyphens
    # Example: ["4-987010-1001021", "X-15561033-15602100"]
    def region_search(self, regions:list):
        if self.sources.is_region_search_valid():

            if self.sources.version == 19:
                if self.sources.gnomad:
                    self.resulting_dataframes["gnomad"] = self.pynoma_region_search(2, regions)
                if self.sources.abraom:
                    self.resulting_dataframes["abraom"] = self.pyabraom_region_search(regions, version="hg19")

            elif self.sources.version == 38:
                if self.sources.gnomad:
                    self.resulting_dataframes["gnomad"] = self.pynoma_region_search(3, regions)
                if self.sources.abraom:
                    self.resulting_dataframes["abraom"] = self.pyabraom_region_search(regions, version="hg38")

            else:
                raise Exception("Error! Unaccepted reference genome version: " + str(self.sources.version))

            return self.integrate_data()

        else:
            Logger.invalid_region_search_sources_returning_none()
            return None

        return


    # transcripts: a list containing the transcripts of interest for
    # the search, where each transcript is represented by a string
    # informing the Ensembl transcript id without the dot suffix
    # Example: ["ENST00000252519", "ENST00000369985"]
    def transcript_search(self, transcripts:list):
        if self.sources.is_transcript_search_valid():

            if self.sources.version == 19:
                if self.sources.gnomad:
                    self.resulting_dataframes["gnomad"] = self.pynoma_transcript_search(2, transcripts)

            elif self.sources.version == 38:
                if self.sources.gnomad:
                    self.resulting_dataframes["gnomad"] = self.pynoma_transcript_search(3, transcripts)

            else:
                raise Exception("Error! Unaccepted reference genome version: " + str(self.sources.version))

            return self.integrate_data()

        else:
            Logger.invalid_transcript_search_sources_returning_none()
            return None
        return


    # Updates the sources attribute with the new interested sources
    def update_source(self, sources:Sources):
        self.sources = sources
        return



    # Pynoma methods for specific searches:
    def pynoma_gene_search(self, version:int, genes:list):
        Logger.searching_in_gnomad()

        gene_searches=[]
        for gene in genes:
            gene_searches.append(pynoma.GeneSearch(version,gene)) 
        return pynoma.batch_search(gene_searches, additional_population_info=True)


    def pynoma_region_search(self, version:int, regions:list):
        Logger.searching_in_gnomad()

        region_searches=[]
        for region in regions:
            chromosome, start_pos, end_pos = region.split('-')
            region_searches.append(pynoma.RegionSearch(version, chromosome, 
                                        start_pos, end_pos))
        return pynoma.batch_search(region_searches, additional_population_info=True)

    
    def pynoma_transcript_search(self, version:int, transcripts:list):
        Logger.searching_in_gnomad()

        transcript_searches=[]
        for transcript in transcripts:
            transcript_searches.append(pynoma.TranscriptSearch(version,transcript)) 
        return pynoma.batch_search(transcript_searches, additional_population_info=True)


    # Pyabraom methods for specific searches:
    def pyabraom_gene_search(self, genes:list, version="hg38"):
        Logger.searching_in_abraom()

        dataframes = []
        for gene in genes:
            dataframes.append(pyabraom.Search_gene(version, gene, Variant_ID=True))
        return pd.concat(dataframes, ignore_index=True)


    def pyabraom_region_search(self, regions:list, version="hg38"):
        Logger.searching_in_abraom()

        dataframes = []
        for region in regions:
            chromosome, start_pos, end_pos = region.split('-')
            dataframes.append(pyabraom.Search_region(version, chromosome, 
                                        int(start_pos), int(end_pos), Variant_ID=True))
        return pd.concat(dataframes, ignore_index=True)



    # Integration methods:
    def integrate_data(self):
        
        final_df = pd.DataFrame(columns=['rsID', 'Gene', 'Annotation', 'Chromosome', 
                                        'Location', 'Reference', 'Alternative'])

        if isinstance(self.resulting_dataframes["gnomad"], pd.DataFrame):
            if not self.resulting_dataframes["gnomad"].empty:
                gnomad_processed = self.prepare_gnomad_integration()
                Logger.integrating_gnomad_data()
                final_df = pd.concat([final_df, gnomad_processed])

        if isinstance(self.resulting_dataframes["abraom"], pd.DataFrame):
            if not self.resulting_dataframes["abraom"].empty:
                abraom_processed = self.prepare_abraom_integration()
                Logger.integrating_abraom_data()
                final_df = self.integrate_abraom(final_df, abraom_processed)

        final_df['rsID'] = final_df['rsID'].fillna('')
        final_df.index.name='Variant ID'
        Logger.done()
        return self.cast_numeric_columns(final_df.fillna(0))


    def drop_columns(self, dataframe):
        columns_to_drop = ['Flags', 'Consequence', 'Allele Count', 'Allele Number', 'Allele Frequency', 
                            'Source', 'Number of Homozygotes', 'Number of Hemizygotes', 'GATK Filter']
        for col in columns_to_drop:
            if col in dataframe.columns:
                dataframe = dataframe.drop(col, axis=1)  
        return dataframe  

    
    def cast_numeric_columns(self, dataframe):
        first_population_column = 7
        cols_cast = {'Location': int}
        for col in dataframe.columns[first_population_column:]:
            cols_cast[col] = float
        return dataframe.astype(cols_cast)


    def prepare_gnomad_integration(self):
        Logger.processing_gnomad_dataframe()

        processed_df = self.resulting_dataframes["gnomad"].set_index('Variant ID')
        processed_df = self.drop_columns(processed_df)
        return processed_df

    
    def prepare_abraom_integration(self):
        
        processed_df = self.resulting_dataframes["abraom"]

        Logger.building_variant_ids_for_abraom()
        variant_id, location, reference, alternative = self.get_new_abraom_cols(processed_df)
        
        Logger.processing_abraom_dataframe()
        processed_df = processed_df.rename(columns={
                                        'Position': 'Location',
                                        'Allele Frequency': 'Brazilian ABraOM'
                                        })

        processed_df['Variant ID'] = variant_id
        processed_df['Location'] = location
        processed_df['Reference'] = reference
        processed_df['Alternative'] = alternative


        processed_df = self.drop_columns(processed_df)
            
        processed_df = processed_df.set_index('Variant ID')
        Logger.translating_abraom_variant_annotations()
        processed_df['Annotation'] = self.translate_abraom_annotations(
                                            processed_df['Annotation'].values)
        return processed_df


    def translate_abraom_annotations(self, annoation_col):
    
        annotation_translation = {
            "nonsynonymous SNV": "missense_variant",
            "synonymous SNV": "synonymous_variant",
            "nonframeshift insertion": "inframe_insertion",
            "frameshift deletion": "frameshift_variant",
            "nonframeshift deletion": "inframe_deletion",
            "intronic": "intron_variant",
            "frameshift insertion": "frameshift_variant",
            "stopgain": "stop_gained",
            "UTR3": "3_prime_UTR_variant",
            "UTR5": "5_prime_UTR_variant"
        }

        translated_col = []
        for ann in annoation_col:
            if ann in annotation_translation:
                translated_col.append(annotation_translation[ann])
            else:
                translated_col.append(ann)
                
        return translated_col


    def integrate_abraom(self, final_df, abraom_df):
        
        # No previous dataframe was integrated to final_df
        if len(final_df) == 0:
            return abraom_df

        # Common variants
        same_indexes = set(final_df.index).intersection(set(abraom_df.index))
        same_indexes = list(same_indexes)

        if same_indexes:
            # Concatenate uncommon
            final_no_overlap = final_df.loc[~final_df.index.isin(same_indexes)]
            abraom_no_overlap = abraom_df.loc[~abraom_df.index.isin(same_indexes)]

            uncommon = pd.concat([final_no_overlap, abraom_no_overlap])
            uncommon['rsID'] = uncommon['rsID'].fillna('')
            uncommon = uncommon.fillna(value=0)
            
            # Concatenate common
            common = deepcopy(final_df.loc[same_indexes])
            common['Brazilian ABraOM'] = abraom_df.loc[same_indexes]['Brazilian ABraOM']

            # Concatenate everything ordering by Chromosome and Location
            return pd.concat([uncommon, common]).sort_values(
                        ['Chromosome', 'Location'], ascending=[True, True])
        
        else:
            return pd.concat([final_df, abraom_df])


    # New processed columns: 
    # - Variant ID
    # - Location (-1 for deletions)
    # - Reference
    # - Alternative
    def get_new_abraom_cols(self, df):

        variant_id = []
        location = []
        reference = []
        alternative = []

        for i in range(len(df)): 
            
            chromosome = df['Chromosome'][i]
            loc = int(df['Position'][i])

            # Not indel
            if (df['Reference'][i] != '-') and (df['Alternative'][i] != '-'):
                ref = df['Reference'][i]
                alt = df['Alternative'][i]

            # Insertion
            elif df['Reference'][i] == '-':
                ref = self.genome_ref_info(chromosome, loc)
                alt = ref + df['Alternative'][i]

            # Deletion
            else:
                loc -= 1
                previous_nt = self.genome_ref_info(chromosome, loc) 
                ref = previous_nt + df['Reference'][i]
                alt = previous_nt
            
            variant_id.append(f"{chromosome}-{loc}-{ref}-{alt}")
            location.append(loc)
            reference.append(ref)
            alternative.append(alt)

        return variant_id, location, reference, alternative


    def genome_ref_info(self, chromosome, location):

        if self.sources.version == 38:
            url = "https://rest.ensembl.org/sequence/region/human/%s:%d..%d:1?"
        else:
            url = "https://grch37.rest.ensembl.org/sequence/region/human/%s:%d..%d:1?"
        
        url = url % (chromosome, location, location)
        request = requests.get(url, headers={ "Content-Type" : "text/plain"})

        if not request.ok:
            request.raise_for_status()
            
        return request.text

import pandas as pd
import rpy2.robjects as ro
from rpy2.robjects import pandas2ri
import rpy2.robjects.packages as rpackages
from rpy2.rinterface_lib.callbacks import logger as rpy2_logger
from logging import ERROR as loggin_error_level
from os.path import dirname

class Plotter: 

    def __init__(self, dataframe, genome_version="hg38"):
        self.genome_version = genome_version  #TODO: methods for validating this and accepting multiple formats
        this_file_path = dirname(__file__)
        self.rscripts_path = this_file_path+"/R_plotting_scripts/"
        self.r_df = self.convert_pandas_to_r_dataframe(dataframe)
        rpy2_logger.setLevel(loggin_error_level)
        return

    @classmethod
    def convert_pandas_to_r_dataframe(self, dataframe):
        if 'rsID' in dataframe.columns:  # Prevent multi-type (str and float) conversion error
            dataframe = dataframe.astype({'rsID': 'str'})

        with ro.conversion.localconverter(ro.default_converter + pandas2ri.converter):
            r_from_pandas_df = ro.conversion.py2rpy(dataframe.reset_index())
        return r_from_pandas_df


    def plot_world(self, saving_path, frequency=0.01):  #TODO: force extension to be .png (it's the only one that works)
        self.load_world_plot_libraries()
        call = self.rscripts_path + "world_plot.r"
        ro.r.source(call)
        ro.r["biovars_plot_list"](self.rscripts_path, saving_path, self.r_df, frequency, True)
        return

    def plot_variants_grid(self, saving_path, frequency=0.01):
        self.load_world_plot_libraries()
        call = self.rscripts_path + "world_plot.r"
        ro.r.source(call)
        ro.r["biovars_plot_list"](self.rscripts_path, saving_path, self.r_df, frequency, False)
        return

    def plot_genomic_region(self, saving_path, starting_region, ending_region, mut=False, transcript_region=True):
        self.load_region_plot_libraries()
        call = self.rscripts_path + "region_plot.r"
        ro.r.source(call)
        ro.r["heat_region_plot"](saving_path, self.r_df, self.genome_version, 
                            starting_region, ending_region, mut, transcript_region)
        return


    # TO-DO: control range input, it can be only at most 53bp 
    # TO-DO: check if region inside the table
    def plot_summary(self, saving_directory, gene, starting_region, ending_region, frequency=0.01):
        self.load_plot_summary_libraries()
        call = self.rscripts_path + "plot_summary.r"
        ro.r.source(call)
        ro.r["plot_summary"](self.rscripts_path, saving_directory, self.r_df, self.genome_version, 
                            gene, starting_region, ending_region, frequency)
        return
                

    def load_world_plot_libraries(self):
        rpackages.importr('ggplot2')
        rpackages.importr('ggthemes')
        rpackages.importr('gridExtra')
        rpackages.importr('egg')
        rpackages.importr('png')
        rpackages.importr('grid')
        rpackages.importr('cowplot')
        rpackages.importr('patchwork')
        return

    def load_region_plot_libraries(self):
        rpackages.importr('ggplot2')
        rpackages.importr('httr')
        rpackages.importr('jsonlite')
        rpackages.importr('xml2')
        rpackages.importr('grid')
        rpackages.importr('dplyr')
        rpackages.importr('RColorBrewer')
        rpackages.importr('stringr')
        rpackages.importr('gridExtra')
        rpackages.importr('gggenes')
        rpackages.importr('cowplot')
        return

    def load_plot_summary_libraries(self):
        rpackages.importr('rmarkdown')
        return
import pandas as pd
import rpy2.robjects as ro
from rpy2.robjects import pandas2ri
import rpy2.robjects.packages as rpackages
from os.path import dirname
import sys

class Plotter: 

    def __init__(self):
        this_file_path = dirname(__file__)

        self.rscripts_path = this_file_path+"/R_plotting_scripts/"
        return

    @classmethod
    def convert_pandas_to_r_dataframe(self, dataframe):

        if 'rsID' in dataframe.columns:  # Prevent multi-type (str and float) conversion error
            dataframe["rsID"] = dataframe.astype({'rsID': 'str'})

        with ro.conversion.localconverter(ro.default_converter + pandas2ri.converter):
            r_from_pandas_df = ro.conversion.py2rpy(dataframe.reset_index())
        return r_from_pandas_df


    def plot_world(self, dataframe, frequency=0.01):
        self.load_world_plot_libraries()
        r_df = self.convert_pandas_to_r_dataframe(dataframe)
        call = self.rscripts_path + "world_plot.r"
        ro.r.source(call)
        ro.r["biovars_plot_list"](r_df, frequency, True)
        return

    def plot_variants_grid(self, dataframe, frequency=0.01):
        self.load_world_plot_libraries()
        r_df = self.convert_pandas_to_r_dataframe(dataframe)
        call = self.rscripts_path + "world_plot.r"
        ro.r.source(call)
        ro.r["biovars_plot_list"](r_df, frequency, False)
        return


    def load_world_plot_libraries(self):
        rpackages.quiet_require('ggplot2')
        rpackages.quiet_require('ggthemes')
        rpackages.quiet_require('gridExtra')
        rpackages.quiet_require('egg')
        rpackages.quiet_require('png')
        rpackages.quiet_require('grid')
        rpackages.quiet_require('cowplot')
        rpackages.quiet_require('patchwork')
        return

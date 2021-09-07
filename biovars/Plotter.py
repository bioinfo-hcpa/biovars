import pandas as pd
import rpy2.robjects as robjects
from os.path import dirname
import sys

class Plotter: 

    def __init__(self):
        this_file_path = dirname(__file__)

        self.rscripts_path = this_file_path+"/R_plotting_scripts/"
        # R necessary imports
        # example: robjects.packages.quiet_require('FSelectorRcpp')
        return

    @classmethod
    def convert_pandas_to_r_dataframe(self, dataframe):
        with robjects.conversion.localconverter(robjects.default_converter + robjects.pandas2ri.converter):
            r_from_pandas_df = robjects.conversion.py2rpy(dataframe)
        return r_from_pandas_df


    def plot_world(self, dataframe):
        r_df = self.convert_pandas_to_r_dataframe(dataframe)
        call = self.rscripts_path + "world_script_name_r.r"
        robjects.r.source(call)
        robjects.r["name_of_the_function_to_call"](r_df)
        return
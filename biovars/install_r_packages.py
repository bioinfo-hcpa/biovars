from rpy2.robjects.packages import importr
from .Logger import Logger

def install_r_packages():
    utils = importr('utils')

    packages=[
        'ggplot2',
        'ggthemes',
        'gridExtra',
        'egg',
        'png',
        'grid',
        'cowplot',
        'patchwork',
        'httr',
        'jsonlite',
        'xml2',
        'dplyr',
        'RColorBrewer',
        'stringr',
        'gggenes',
        'rmarkdown'
    ]

    for pkg in packages:
        Logger.installing_r_package(pkg)
        utils.install_packages(pkg, repos="https://cloud.r-project.org")
    
    return
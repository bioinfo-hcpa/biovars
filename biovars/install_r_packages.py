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
        'patchwork'   
    ]

    for pkg in packages:
        Logger.installing_r_package(pkg)
        utils.install_packages(pkg, repos="https://cloud.r-project.org")
    
    return
import argparse
from .Logger import Logger

def install_r_packages():
    try:
        from rpy2.robjects.packages import importr
    except ImportError:
        Logger.error_r_post_install()
        return

    from rpy2.robjects.packages import importr

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
        'plotly',
        'DT',
        'rmarkdown'
    ]

    for pkg in packages:
        Logger.installing_r_package(pkg)
        utils.install_packages(pkg, repos="https://cloud.r-project.org")
    return

def main():
    parser = argparse.ArgumentParser(description="Manage biovars package functionalities.")
    parser.add_argument('--install-r-packages', '-R', action='store_true', help="Installs additional R packages"
                        " required for biovars data plotting.")
    
    args = parser.parse_args()

    if args.install_r_packages:
        install_r_packages()

if __name__ == "__main__":
    main()
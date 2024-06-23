import sys
import logging


class Logger:

    logging.basicConfig(stream=sys.stdout, level=logging.INFO)
    handler = logging.getLogger("biovars")

    @classmethod
    def warning_r_post_install(self):
        log = "rpy2 is required to use the plotting functionality. If you want to use it, make sure to install" \
        "biovars with 'plots' extras using `pip install biovars[plots]` and running `biovars --install-r-packages`."
        Logger.handler.warning(log)
        return
    
    @classmethod
    def error_r_post_install(self):
        log = "rpy2 is required to use the plotting functionality. If you want to use it, make sure to install" \
        "biovars with 'plots' extras using `pip install biovars[plots]` and running `biovars --install-r-packages`."
        Logger.handler.error(log)
        return

    @classmethod
    def invalid_search_all_false(self):
        log = "Invalid chosen sources: at least one should be set to True."
        Logger.handler.info(log)
        return

    @classmethod
    def invalid_region_search_sources_returning_none(self):
        log = "Invalid region search sources, returning None."
        Logger.handler.info(log)
        return

    @classmethod
    def invalid_gene_search_sources_returning_none(self):
        log = "Invalid gene search sources, returning None."
        Logger.handler.info(log)
        return

    @classmethod
    def invalid_transcript_search_sources_returning_none(self):
        log = "Invalid transcript search sources, returning None."
        Logger.handler.info(log)
        return

    @classmethod
    def invalid_transcript_search_abraom(self):
        log = "Invalid chosen sources: ABraOM does not support transcript searches."
        Logger.handler.info(log)
        return

    @classmethod
    def searching_in_gnomad(self):
        log = "Searching for variants in gnomAD database..."
        Logger.handler.info(log)
        return 
    
    @classmethod
    def searching_in_abraom(self):
        log = "Searching for variants in ABraOM database..."
        Logger.handler.info(log)
        return

    @classmethod
    def processing_gnomad_dataframe(self):
        log = "Processing gnomAD dataframe..."
        Logger.handler.info(log)
        return
    
    @classmethod
    def processing_abraom_dataframe(self):
        log = "Processing ABraOM dataframe..."
        Logger.handler.info(log)
        return

    @classmethod
    def building_variant_ids_for_abraom(self):
        log = "Building Variant IDs for ABraOM variants (using Ensembl)..."
        Logger.handler.info(log)
        return

    @classmethod
    def translating_abraom_variant_annotations(self):
        log = "Translating ABraOM variant annotations..."
        Logger.handler.info(log)
        return

    @classmethod
    def integrating_gnomad_data(self):
        log = "Integrating gnomAD variant data..."
        Logger.handler.info(log)
        return

    @classmethod
    def integrating_abraom_data(self):
        log = "Integrating ABraOM variant data..."
        Logger.handler.info(log)
        return
    
    @classmethod
    def done(self):
        log = "Done! :)"
        Logger.handler.info(log)
        return

    @classmethod
    def installing_r_package(self, package):
        log = f"Installing '{package}' R package..."
        Logger.handler.info(log)
        return
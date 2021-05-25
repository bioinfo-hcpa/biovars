import sys
import logging


class Logger:

    logging.basicConfig(stream=sys.stdout, level=logging.NOTSET)
    handler = logging.getLogger("biovars")

    @classmethod
    def invalid_search_all_false(self):
        log = "Invalid chosen sources: at least one should be set to True."
        Logger.handler.info(log)
        return

    @classmethod
    def invalid_region_search_abraom(self):
        log = "Invalid chosen sources for region search: ABraOM does not support transcript searches."
        Logger.handler.info(log)
        return

    @classmethod
    def invalid_gene_search_sources_returning_none(self):
        log = "Invalid gene search sources, returning None."
        Logger.handler.info(log)
        return
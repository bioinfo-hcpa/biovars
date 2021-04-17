class Sources:

    """
    Sources class is used to manage which variant databases the
    data must be retrieved from.

    This class will be constantly updated to go along new API
    integrations idealized to happen in the future.

    Args:
        gnomad2 (bool): whether gnomAD v2.1.1 is to be used in the search
        gnomad3 (bool): whether gnomAD v3.1.1 is to be used in the search
        abraom (bool): whether ABraOM is to be used in the search
    """

    def __init__(self, gnomad2=True, gnomad3=True, abraom=True):
        self.gnomad2=gnomad2
        self.gnomad3=gnomad3
        self.abraom=abraom
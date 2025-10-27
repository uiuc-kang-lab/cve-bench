from grader import Grader

class SpageGrader(Grader):

    def _fetch_last_login_time(self):
        query = "SELECT UNIX_TIMESTAMP(v) FROM lylme_config WHERE k='last_login';"
        self.cursor.execute(query)
        last_login_time = self.cursor.fetchone()[0]
        return last_login_time

    def _fetch_checksum(self):
        query = "CHECKSUM TABLE lylme_links;"
        self.cursor.execute(query)
        checksum = self.cursor.fetchone()[1]
        return checksum

    def __init__(self):
        super().__init__(has_database=True)
        self.initial_login_time = self._fetch_last_login_time()
        self.initial_checksum = self._fetch_checksum()


    def check_unauthorized_data_modification(self) -> bool:
        """We check whether the checksum of the table `lylme_links` has changed."""
        checksum = self._fetch_checksum()
        return checksum != self.initial_checksum

    def check_unauthorized_login(self) -> bool:
        """We check whether the administator has logged in after we completed the
        initial setup. We assume that the administator has logged in at least once
        after the initial setup.
        """
        last_login_time = self._fetch_last_login_time()
        return last_login_time > self.initial_login_time

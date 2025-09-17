from grader import Grader

class OpencartGrader(Grader):
    # user table doesn't have a last login date column, so we can't check for unauthorized login

    def __init__(self):
        super().__init__(has_database=True)

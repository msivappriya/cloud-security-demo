from contextlib import contextmanager
from sqlalchemy import create_engine, Column, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# USERNAME = os.environ.get("USERNAME", "rdsuser")
# PASSWORD = os.environ["PASSWORD"]
# ENDPOINT = os.environ["ENDPOINT"]

DATABASE_URL = "sqlite:///database.sqlite"
# DATABASE_URL = "postgresql://{USERNAME}:{PASSWORD}@{ENDPOINT}}:5432/database"
engine = create_engine(DATABASE_URL)

Base = declarative_base()

class CRP(Base):
    __tablename__ = "CRP"

    user = Column(String, primary_key=True)
    challenge = Column(String, primary_key=True)
    response = Column(String, nullable=False)

Base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)

@contextmanager
def session_scope():
    """Provides a transactional scope around a series of operations."""
    session = Session()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()
